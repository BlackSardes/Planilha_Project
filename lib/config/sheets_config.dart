// Configuração da integração com Google Sheets
class SheetsConfig {
  // ID da planilha do Google Sheets
  // Para obter: abra a planilha e copie o ID da URL
  // Exemplo: https://docs.google.com/spreadsheets/d/SEU_ID_AQUI/edit
  static const String spreadsheetId = 'SEU_ID_DA_PLANILHA_AQUI';
  
  // Nomes das abas dos meses
  static const List<String> months = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];
  
  // Configuração das colunas na planilha
  static const String startColumn = 'K'; // Coluna inicial (Nome da compra)
  static const String endColumn = 'O';   // Coluna final (Valor)
  static const int startRow = 9;         // Linha inicial dos dados
  
  // Retorna o range completo para um mês específico
  // Exemplo: "Janeiro!K9:O" para janeiro
  static String getRangeForMonth(int month) {
    if (month < 1 || month > 12) {
      throw ArgumentError('Mês deve estar entre 1 e 12');
    }
    final monthName = months[month - 1];
    return '$monthName!$startColumn$startRow:$endColumn';
  }
  
  // URI de redirecionamento para OAuth 2.0
  static const String redirectUri = 'com.blacksardes.expense_tracker://oauth';
  
  // Escopos necessários para acessar o Google Sheets
  static const List<String> scopes = [
    'https://www.googleapis.com/auth/spreadsheets',
  ];
}
