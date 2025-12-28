import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';
import 'google_auth_client.dart';

void main() {
  runApp(const ExpenseApp());
}

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense -> Sheets',
      home: const ExpenseFormPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ExpenseFormPage extends StatefulWidget {
  const ExpenseFormPage({super.key});
  @override
  State<ExpenseFormPage> createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends State<ExpenseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _dateCtl = TextEditingController();
  final _valueCtl = TextEditingController();
  String _meio = 'PicPay';
  String _categoria = 'Necessidades';

  GoogleSignInAccount? _currentUser;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/spreadsheets',
    ],
  );

  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
  }

  Future<http.Client> _getAuthedHttpClient() async {
    if (_currentUser == null) {
      _currentUser = await _googleSignIn.signIn();
    }
    final headers = await _currentUser!.authHeaders;
    return GoogleAuthClient(headers);
  }

  Future<void> _appendToSheet({
    required String nome,
    required DateTime data,
    required String meio,
    required String categoria,
    required String valor,
  }) async {
    setState(() => _sending = true);
    try {
      final client = await _getAuthedHttpClient();
      final sheetsApi = sheets.SheetsApi(client);

      // A aba é "Janeiro" e os dados devem começar na linha 9 em colunas K:O
      // Usamos append no intervalo K9:O para adicionar novas linhas após a última.
      final range = 'Janeiro!K9:O';

      final formattedDate = DateFormat('dd/MM/yyyy').format(data);

      final valueRange = sheets.ValueRange.fromJson({
        'values': [
          [nome, formattedDate, meio, categoria, valor]
        ]
      });

      await sheetsApi.spreadsheets.values.append(
        valueRange,
        kSpreadsheetId,
        range,
        valueInputOption: 'USER_ENTERED',
        insertDataOption: 'INSERT_ROWS',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro enviado para a planilha.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar: $e')),
        );
      }
    } finally {
      setState(() => _sending = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      _dateCtl.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _dateCtl.dispose();
    _valueCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = _currentUser != null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar gasto -> Google Sheets'),
        actions: [
          if (!signedIn)
            TextButton(
              onPressed: () => _googleSignIn.signIn(),
              child: const Text('Login Google', style: TextStyle(color: Colors.white)),
            )
          else
            TextButton(
              onPressed: () => _googleSignIn.signOut(),
              child: const Text('Logout', style: TextStyle(color: Colors.white)),
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtl,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) => (v == null || v.isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dateCtl,
                readOnly: true,
                onTap: _pickDate,
                decoration: const InputDecoration(labelText: 'Data (toque para escolher)'),
                validator: (v) => (v == null || v.isEmpty) ? 'Informe a data' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _meio,
                      items: ['PicPay', 'Caixa', 'Nubank', 'Inter', 'Pago'].map((e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),
                      onChanged: (v) => setState(() => _meio = v!),
                      decoration: const InputDecoration(labelText: 'Meio'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _categoria,
                      items: ['Necessidades', 'Assinaturas', 'Lazer', 'Outros'].map((e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),
                      onChanged: (v) => setState(() => _categoria = v!),
                      decoration: const InputDecoration(labelText: 'Categoria'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _valueCtl,
                decoration: const InputDecoration(labelText: 'Valor (ex: 85.00)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => (v == null || v.isEmpty) ? 'Informe o valor' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _sending
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        // parse date
                        DateTime parsedDate;
                        try {
                          parsedDate = DateFormat('dd/MM/yyyy').parse(_dateCtl.text);
                        } catch (_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Data inválida')),
                          );
                          return;
                        }

                        await _appendToSheet(
                          nome: _nameCtl.text.trim(),
                          data: parsedDate,
                          meio: _meio,
                          categoria: _categoria,
                          valor: _valueCtl.text.trim(),
                        );
                      },
                child: _sending ? const CircularProgressIndicator(color: Colors.white) : const Text('Enviar para o mês (Janeiro)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
