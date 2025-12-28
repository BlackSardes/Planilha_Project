# 📱 Controle de Gastos - Google Sheets

Aplicativo Flutter para Android que automatiza o registro de gastos mensais em uma planilha do Google Sheets.

## 📋 Sobre o Projeto

Este aplicativo permite adicionar gastos diretamente na planilha "Gastos do Mês" do Google Sheets de forma rápida e intuitiva. Os gastos são automaticamente organizados por mês nas respectivas abas da planilha.

### ✨ Funcionalidades

- ✅ Autenticação OAuth 2.0 com Google
- ✅ Detecção automática do mês pela data selecionada
- ✅ Inserção automática nas colunas corretas (K-O)
- ✅ Formatação automática de datas (DD/MM) e valores (R$ XX,XX)
- ✅ Interface Material Design 3 moderna e intuitiva
- ✅ Suporte completo ao português brasileiro
- ✅ Cache de credenciais para acesso mais rápido
- ✅ Feedback visual em todas as operações

## 📊 Estrutura da Planilha

A planilha deve ter a seguinte estrutura:

- **Abas**: Janeiro, Fevereiro, Março, Abril, Maio, Junho, Julho, Agosto, Setembro, Outubro, Novembro, Dezembro
- **Seção "Gastos do Mês"**: Colunas K a O, começando na linha 9
  - **Coluna K**: Nome da compra
  - **Coluna L**: Data (DD/MM)
  - **Coluna M**: Tipo/Meio de pagamento
  - **Coluna N**: Categoria
  - **Coluna O**: Valor (R$)

## 📱 Especificações do Dispositivo Alvo

- **Dispositivo**: Poco F7
- **Sistema**: Android 14 (HyperOS)
- **Tela**: AMOLED 6.67"
- **SDK Mínimo**: Android 6.0 (API 23)
- **SDK Alvo**: Android 14 (API 34)

## 🚀 Pré-requisitos

Antes de começar, você precisará:

1. **Flutter SDK** instalado (versão 3.10.4 ou superior)
2. **Android SDK** configurado
3. **Conta Google** com acesso à planilha
4. **Google Cloud Project** com Google Sheets API habilitada
5. **Credenciais OAuth 2.0** configuradas

## 📦 Instalação

### 1. Clone o repositório

```bash
git clone https://github.com/BlackSardes/Planilha_Project.git
cd Planilha_Project
```

### 2. Configure o Google Cloud

Siga o guia detalhado em [SETUP.md](SETUP.md) para:
- Criar projeto no Google Cloud Console
- Habilitar Google Sheets API
- Configurar tela de consentimento OAuth
- Criar credenciais OAuth 2.0
- Baixar o arquivo credentials.json

### 3. Adicione o arquivo de credenciais

1. Baixe o arquivo `credentials.json` do Google Cloud Console
2. Copie para `assets/credentials.json`

```bash
cp /caminho/para/seu/credentials.json assets/credentials.json
```

**⚠️ IMPORTANTE**: Nunca commite o arquivo `credentials.json`! Ele já está no `.gitignore`.

### 4. Configure o ID da planilha

Edite `lib/config/sheets_config.dart` e substitua:

```dart
static const String spreadsheetId = 'SEU_ID_DA_PLANILHA_AQUI';
```

Para obter o ID:
1. Abra sua planilha no Google Sheets
2. Copie o ID da URL: `https://docs.google.com/spreadsheets/d/[ID_AQUI]/edit`

### 5. Instale as dependências

```bash
flutter pub get
```

### 6. Execute o aplicativo

```bash
flutter run
```

## 🎯 Como Usar

### Primeiro Acesso

1. Abra o aplicativo
2. Aguarde a tela de autenticação do Google
3. Faça login com sua conta Google
4. Autorize o aplicativo a acessar sua planilha
5. Aguarde a confirmação de conexão

### Adicionando um Gasto

1. Na tela inicial, toque no botão "Adicionar Gasto"
2. Preencha os campos:
   - **Nome da compra**: Ex: "Supermercado"
   - **Data**: Selecione a data (define automaticamente o mês)
   - **Meio de pagamento**: Selecione da lista
   - **Categoria**: Selecione da lista
   - **Valor**: Digite o valor (ex: 150.00)
3. Toque em "SALVAR GASTO"
4. Aguarde a confirmação

O gasto será automaticamente adicionado na aba do mês correspondente à data selecionada.

### Opções Disponíveis

**Meios de Pagamento**:
- Inter - D / C
- Caixa - D / C
- Pago - D / C
- PicPay - D / C
- Nubank - D / C

**Categorias**:
- Assinaturas
- Necessidades
- Alimentação
- Transporte
- Lazer
- Saúde
- Educação
- Outros

## 🏗️ Estrutura do Código

```
lib/
├── config/
│   └── sheets_config.dart          # Configurações da planilha e OAuth
├── models/
│   └── expense.dart                # Modelo de dados do gasto
├── providers/
│   └── expense_provider.dart       # Gerenciamento de estado
├── screens/
│   ├── home_screen.dart            # Tela principal
│   └── add_expense_screen.dart     # Tela de adicionar gasto
├── services/
│   └── google_sheets_service.dart  # Integração com Google Sheets
└── main.dart                       # Ponto de entrada da aplicação

assets/
└── credentials.json                # Credenciais OAuth (não commitado)

docs/
├── GOOGLE_CLOUD_SETUP.md          # Guia visual do Google Cloud
└── SHA1_GUIDE.md                  # Guia para obter SHA-1
```

## 🔧 Troubleshooting

### Erro: "Falha na autenticação"

**Solução**:
1. Verifique se o arquivo `credentials.json` está em `assets/`
2. Confirme se o `client_id` e `client_secret` estão corretos
3. Verifique se adicionou o redirect URI correto no Google Cloud Console: `com.blacksardes.expense_tracker://oauth`

### Erro: "Permissão negada"

**Solução**:
1. Compartilhe a planilha com a conta Google que você está usando
2. Verifique se a Google Sheets API está habilitada no projeto
3. Confirme se os escopos OAuth estão corretos

### Erro: "Planilha não encontrada"

**Solução**:
1. Verifique se o `spreadsheetId` em `sheets_config.dart` está correto
2. Confirme se a planilha existe e você tem acesso
3. Verifique se as abas dos meses estão nomeadas corretamente (Janeiro, Fevereiro, etc.)

### Erro ao compilar

**Solução**:
```bash
flutter clean
flutter pub get
flutter run
```

### Problemas com OAuth no Android

**Solução**:
1. Verifique se as permissões estão corretas no `AndroidManifest.xml`
2. Confirme o deep link: `com.blacksardes.expense_tracker://oauth`
3. Para credenciais Android, adicione o SHA-1 do certificado (veja [docs/SHA1_GUIDE.md](docs/SHA1_GUIDE.md))

## 🔐 Segurança

- ✅ OAuth 2.0 para autenticação segura
- ✅ Credenciais armazenadas localmente com `SharedPreferences`
- ✅ Tokens de acesso renovados automaticamente
- ✅ Arquivo `credentials.json` não commitado no git
- ✅ Apenas escopos necessários solicitados

## 🎨 Design

- **Framework**: Material Design 3
- **Cor Primária**: Azul (#1976D2)
- **Bordas**: Arredondadas (12px)
- **Elevação**: Sutil (2dp)
- **Tema**: Claro
- **Ícones**: Material Icons
- **Tipografia**: Roboto

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para:

1. Fazer fork do projeto
2. Criar uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commitar suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. Fazer push para a branch (`git push origin feature/MinhaFeature`)
5. Abrir um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 👨‍💻 Autor

**BlackSardes**

- GitHub: [@BlackSardes](https://github.com/BlackSardes)

## 📞 Suporte

Se você encontrar algum problema ou tiver dúvidas:

1. Verifique a seção [Troubleshooting](#-troubleshooting)
2. Consulte [SETUP.md](SETUP.md) para configuração detalhada
3. Abra uma [issue](https://github.com/BlackSardes/Planilha_Project/issues) no GitHub

---

Feito com ❤️ para facilitar o controle de gastos pessoais

