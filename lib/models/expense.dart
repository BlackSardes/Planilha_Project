// Modelo de dados para um gasto
import 'package:intl/intl.dart';

class Expense {
  final String name;          // Nome da compra (Coluna K)
  final DateTime date;        // Data da compra (Coluna L)
  final String paymentMethod; // Meio de pagamento (Coluna M)
  final String category;      // Categoria (Coluna N)
  final double value;         // Valor (Coluna O)

  Expense({
    required this.name,
    required this.date,
    required this.paymentMethod,
    required this.category,
    required this.value,
  });

  // Converte o objeto para JSON (para persistência local se necessário)
  Map<String, dynamic> toJson() => {
    'name': name,
    'date': date.toIso8601String(),
    'paymentMethod': paymentMethod,
    'category': category,
    'value': value,
  };

  // Cria um objeto a partir de JSON
  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    name: json['name'] as String,
    date: DateTime.parse(json['date'] as String),
    paymentMethod: json['paymentMethod'] as String,
    category: json['category'] as String,
    value: (json['value'] as num).toDouble(),
  );

  // Retorna o mês da data (1-12)
  int get month => date.month;

  // Retorna a data formatada como DD/MM
  String get formattedDate {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month';
  }

  // Retorna o valor formatado como R$ XX,XX usando formatação de moeda
  String get formattedValue {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(value).replaceAll('.', ',');
  }
}
