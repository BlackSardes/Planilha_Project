import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import '../config/sheets_config.dart';
import '../models/expense.dart';

/// Serviço para integração com Google Sheets usando OAuth 2.0
class GoogleSheetsService {
  sheets.SheetsApi? _sheetsApi;
  AutoRefreshingAuthClient? _authClient;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Inicializa o serviço de autenticação e conexão com Google Sheets
  Future<void> initialize() async {
    try {
      // Carrega as credenciais OAuth do arquivo
      final credentials = await _loadCredentials();
      
      // Tenta obter credenciais salvas
      final savedCreds = await _loadSavedCredentials();
      
      AccessCredentials accessCredentials;
      
      if (savedCreds != null) {
        // Usa credenciais salvas
        accessCredentials = savedCreds;
      } else {
        // Faz o fluxo de autenticação OAuth
        accessCredentials = await _authenticateUser(credentials);
        // Salva as credenciais para uso futuro
        await _saveCredentials(accessCredentials);
      }
      
      // Cria o cliente HTTP autenticado
      _authClient = autoRefreshingClient(
        credentials,
        accessCredentials,
        http.Client(),
      );
      
      // Inicializa a API do Sheets
      _sheetsApi = sheets.SheetsApi(_authClient!);
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  /// Carrega as credenciais OAuth do arquivo credentials.json
  Future<ClientId> _loadCredentials() async {
    try {
      final jsonString = await rootBundle.loadString('assets/credentials.json');
      final json = jsonDecode(jsonString);
      
      // Tenta carregar credenciais desktop/instaladas primeiro
      if (json['installed'] != null) {
        final credentials = json['installed'];
        return ClientId(
          credentials['client_id'] as String,
          credentials['client_secret'] as String? ?? '',
        );
      }
      
      // Tenta carregar credenciais web
      if (json['web'] != null) {
        final credentials = json['web'];
        return ClientId(
          credentials['client_id'] as String,
          credentials['client_secret'] as String? ?? '',
        );
      }
      
      throw Exception(
        'Formato de credenciais não suportado. '
        'O arquivo credentials.json deve conter "installed" ou "web".'
      );
    } catch (e) {
      throw Exception(
        'Erro ao carregar credentials.json. Verifique se o arquivo existe em assets/ '
        'e está configurado no pubspec.yaml. Erro: $e'
      );
    }
  }

  /// Carrega credenciais salvas do armazenamento local
  Future<AccessCredentials?> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credsJson = prefs.getString('google_credentials');
      
      if (credsJson == null) return null;
      
      final json = jsonDecode(credsJson) as Map<String, dynamic>;
      
      final accessToken = AccessToken(
        json['type'] as String,
        json['data'] as String,
        DateTime.parse(json['expiry'] as String),
      );
      
      final refreshToken = json['refreshToken'] as String?;
      final scopes = (json['scopes'] as List<dynamic>).cast<String>();
      
      return AccessCredentials(accessToken, refreshToken, scopes);
    } catch (e) {
      // Se houver erro ao carregar, retorna null para fazer novo login
      return null;
    }
  }

  /// Salva as credenciais no armazenamento local
  Future<void> _saveCredentials(AccessCredentials credentials) async {
    final prefs = await SharedPreferences.getInstance();
    
    final json = {
      'type': credentials.accessToken.type,
      'data': credentials.accessToken.data,
      'expiry': credentials.accessToken.expiry.toIso8601String(),
      'refreshToken': credentials.refreshToken,
      'scopes': credentials.scopes,
    };
    
    await prefs.setString('google_credentials', jsonEncode(json));
  }

  /// Limpa as credenciais salvas (logout)
  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('google_credentials');
    _authClient?.close();
    _authClient = null;
    _sheetsApi = null;
    _isInitialized = false;
  }

  /// Realiza o fluxo de autenticação OAuth 2.0
  Future<AccessCredentials> _authenticateUser(ClientId clientId) async {
    try {
      // Cria a URL de autenticação
      final authUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
        'client_id': clientId.identifier,
        'redirect_uri': SheetsConfig.redirectUri,
        'response_type': 'code',
        'scope': SheetsConfig.scopes.join(' '),
        'access_type': 'offline',
        'prompt': 'consent',
      });

      // Abre o navegador para autenticação
      final result = await FlutterWebAuth.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: 'com.blacksardes.expense_tracker',
      );

      // Extrai o código de autorização da URL de callback
      final code = Uri.parse(result).queryParameters['code'];
      
      if (code == null) {
        throw Exception('Código de autorização não recebido');
      }

      // Troca o código por tokens de acesso
      final httpClient = http.Client();
      try {
        final tokenResponse = await httpClient.post(
          Uri.parse('https://oauth2.googleapis.com/token'),
          body: {
            'code': code,
            'client_id': clientId.identifier,
            'client_secret': clientId.secret,
            'redirect_uri': SheetsConfig.redirectUri,
            'grant_type': 'authorization_code',
          },
        );

        if (tokenResponse.statusCode != 200) {
          throw Exception('Erro ao obter tokens: ${tokenResponse.body}');
        }

        final tokens = jsonDecode(tokenResponse.body);
        
        final accessToken = AccessToken(
          tokens['token_type'] as String? ?? 'Bearer',
          tokens['access_token'] as String,
          DateTime.now().add(Duration(seconds: tokens['expires_in'] as int)),
        );

        return AccessCredentials(
          accessToken,
          tokens['refresh_token'] as String?,
          SheetsConfig.scopes,
        );
      } finally {
        httpClient.close();
      }
    } catch (e) {
      throw Exception('Erro na autenticação: $e');
    }
  }

  /// Adiciona um gasto na planilha
  Future<void> addExpense(Expense expense) async {
    if (!_isInitialized || _sheetsApi == null) {
      throw Exception('Serviço não inicializado. Chame initialize() primeiro.');
    }

    try {
      // Determina o range baseado no mês da data
      final range = SheetsConfig.getRangeForMonth(expense.month);
      
      // Prepara os dados no formato correto
      final values = [
        [
          expense.name,                    // Coluna K: Nome
          expense.formattedDate,           // Coluna L: Data (DD/MM)
          expense.paymentMethod,           // Coluna M: Meio de pagamento
          expense.category,                // Coluna N: Categoria
          expense.formattedValue,          // Coluna O: Valor (R$ XX,XX)
        ]
      ];

      final valueRange = sheets.ValueRange(values: values);

      // Adiciona a linha na planilha
      await _sheetsApi!.spreadsheets.values.append(
        valueRange,
        SheetsConfig.spreadsheetId,
        range,
        valueInputOption: 'USER_ENTERED',
        insertDataOption: 'INSERT_ROWS',
      );
    } catch (e) {
      throw Exception('Erro ao adicionar gasto na planilha: $e');
    }
  }

  /// Busca os gastos de um mês específico
  Future<List<List<dynamic>>> getExpensesForMonth(int month) async {
    if (!_isInitialized || _sheetsApi == null) {
      throw Exception('Serviço não inicializado. Chame initialize() primeiro.');
    }

    try {
      final range = SheetsConfig.getRangeForMonth(month);
      
      final response = await _sheetsApi!.spreadsheets.values.get(
        SheetsConfig.spreadsheetId,
        range,
      );

      return response.values ?? [];
    } catch (e) {
      throw Exception('Erro ao buscar gastos: $e');
    }
  }

  /// Libera recursos
  void dispose() {
    _authClient?.close();
    _authClient = null;
    _sheetsApi = null;
    _isInitialized = false;
  }
}
