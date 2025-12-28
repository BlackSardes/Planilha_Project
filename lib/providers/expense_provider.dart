import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../services/google_sheets_service.dart';

/// Provider para gerenciar o estado da aplicação
class ExpenseProvider with ChangeNotifier {
  final GoogleSheetsService _sheetsService = GoogleSheetsService();
  
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;
  List<List<dynamic>>? _currentMonthExpenses;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<List<dynamic>>? get currentMonthExpenses => _currentMonthExpenses;

  /// Inicializa a conexão com Google Sheets
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _sheetsService.initialize();
      _isInitialized = true;
      _errorMessage = null;
    } catch (e) {
      _isInitialized = false;
      _errorMessage = 'Erro ao conectar: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adiciona um novo gasto
  Future<bool> addExpense(Expense expense) async {
    if (!_isInitialized) {
      _errorMessage = 'Serviço não inicializado';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _sheetsService.addExpense(expense);
      
      // Atualiza a lista de gastos do mês atual se estiver carregada
      if (_currentMonthExpenses != null) {
        await loadExpensesForMonth(expense.month);
      }
      
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao adicionar gasto: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carrega os gastos de um mês específico
  Future<void> loadExpensesForMonth(int month) async {
    if (!_isInitialized) {
      _errorMessage = 'Serviço não inicializado';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentMonthExpenses = await _sheetsService.getExpensesForMonth(month);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erro ao carregar gastos: ${e.toString()}';
      _currentMonthExpenses = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Faz logout e limpa as credenciais
  Future<void> logout() async {
    await _sheetsService.clearCredentials();
    _isInitialized = false;
    _currentMonthExpenses = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpa mensagens de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sheetsService.dispose();
    super.dispose();
  }
}
