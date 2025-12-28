import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import 'add_expense_screen.dart';

/// Tela principal do aplicativo
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Inicializa a conexão ao carregar a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ExpenseProvider>();
      if (!provider.isInitialized) {
        provider.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Gastos'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Status da conexão
                  _buildStatusWidget(provider),
                  const SizedBox(height: 32),
                  
                  // Informações
                  if (provider.isInitialized) ...[
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 80,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Conectado ao Google Sheets!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Toque no botão "+" abaixo para adicionar um novo gasto.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  
                  // Botão de tentar novamente em caso de erro
                  if (provider.errorMessage != null && !provider.isLoading) ...[
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => provider.initialize(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar Novamente'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          if (!provider.isInitialized || provider.isLoading) {
            return const SizedBox.shrink();
          }
          
          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddExpenseScreen(),
                ),
              );
            },
            backgroundColor: const Color(0xFF1976D2),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Gasto'),
          );
        },
      ),
    );
  }

  /// Constrói o widget de status da conexão
  Widget _buildStatusWidget(ExpenseProvider provider) {
    if (provider.isLoading) {
      return Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
          ),
          const SizedBox(height: 16),
          Text(
            'Conectando ao Google Sheets...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (provider.errorMessage != null) {
      return Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 80,
          ),
          const SizedBox(height: 16),
          const Text(
            'Erro na Conexão',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              provider.errorMessage!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red[900],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
