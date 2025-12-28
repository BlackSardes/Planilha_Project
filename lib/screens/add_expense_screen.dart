import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../config/sheets_config.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';

/// Tela para adicionar um novo gasto
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String _selectedPaymentMethod = 'Inter - D';
  String _selectedCategory = 'Necessidades';
  
  bool _isSaving = false;

  // Opções de meio de pagamento
  static const List<String> paymentMethods = [
    'Inter - D',
    'Caixa - D',
    'Pago - D',
    'PicPay - D',
    'Nubank - D',
    'PicPay - C',
    'Nubank - C',
    'Pago - C',
    'Caixa - C',
    'Inter - C',
  ];

  // Opções de categoria
  static const List<String> categories = [
    'Assinaturas',
    'Necessidades',
    'Alimentação',
    'Transporte',
    'Lazer',
    'Saúde',
    'Educação',
    'Outros',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  /// Helper para validar e parsear o valor monetário
  double? _parseValue(String text) {
    final valueText = text.trim().replaceAll(',', '.');
    final value = double.tryParse(valueText);
    return (value != null && value > 0) ? value : null;
  }

  /// Mostra o seletor de data
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1976D2),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Valida e salva o gasto
  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Valida o valor usando o helper
    final value = _parseValue(_valueController.text);
    
    if (value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira um valor válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final expense = Expense(
        name: _nameController.text.trim(),
        date: _selectedDate,
        paymentMethod: _selectedPaymentMethod,
        category: _selectedCategory,
        value: value,
      );

      final provider = context.read<ExpenseProvider>();
      final success = await provider.addExpense(expense);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gasto adicionado em ${SheetsConfig.months[_selectedDate.month - 1]}!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Erro ao salvar gasto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthName = SheetsConfig.months[_selectedDate.month - 1];
    final dateFormatted = DateFormat('dd/MM/yyyy', 'pt_BR').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Gasto'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Informação sobre onde será salvo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF1976D2)),
                    const SizedBox(height: 8),
                    Text(
                      'Este gasto será adicionado na aba "$monthName"',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Colunas K a O, a partir da linha 9',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),

              // Nome da compra
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome da compra',
                  hintText: 'Ex: Supermercado',
                  prefixIcon: const Icon(Icons.shopping_bag),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, informe o nome da compra';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Data
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Data',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  child: Text(
                    dateFormatted,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Meio de pagamento
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                decoration: InputDecoration(
                  labelText: 'Meio de pagamento',
                  prefixIcon: const Icon(Icons.payment),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: paymentMethods.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPaymentMethod = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // Categoria
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Categoria',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // Valor
              TextFormField(
                controller: _valueController,
                decoration: InputDecoration(
                  labelText: 'Valor',
                  hintText: 'Ex: 150.00',
                  prefixIcon: const Icon(Icons.attach_money),
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, informe o valor';
                  }
                  if (_parseValue(value) == null) {
                    return 'Por favor, informe um valor válido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Botão salvar
              ElevatedButton(
                onPressed: _isSaving ? null : _saveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'SALVAR GASTO',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
