# 🛠️ Guia de Configuração - Google Cloud Console

Este guia detalha todos os passos necessários para configurar o Google Cloud Console e obter as credenciais OAuth 2.0 para o aplicativo.

## 📋 Índice

1. [Criar Projeto no Google Cloud](#1-criar-projeto-no-google-cloud)
2. [Habilitar Google Sheets API](#2-habilitar-google-sheets-api)
3. [Configurar Tela de Consentimento OAuth](#3-configurar-tela-de-consentimento-oauth)
4. [Criar Credenciais OAuth 2.0](#4-criar-credenciais-oauth-20)
5. [Baixar Arquivo credentials.json](#5-baixar-arquivo-credentialsjson)
6. [Obter ID da Planilha](#6-obter-id-da-planilha)
7. [Verificar Estrutura da Planilha](#7-verificar-estrutura-da-planilha)
8. [Troubleshooting](#8-troubleshooting)

---

## 1. Criar Projeto no Google Cloud

### Passos:

1. Acesse [Google Cloud Console](https://console.cloud.google.com/)
2. Faça login com sua conta Google
3. Clique em **"Select a project"** (ou **"Selecionar um projeto"**) no topo da página
4. Clique em **"NEW PROJECT"** (ou **"NOVO PROJETO"**)
5. Preencha:
   - **Project name**: `expense-tracker` (ou nome de sua preferência)
   - **Organization**: Deixe em branco (ou selecione se houver)
   - **Location**: Deixe em branco
6. Clique em **"CREATE"** (ou **"CRIAR"**)
7. Aguarde alguns segundos até o projeto ser criado
8. Selecione o projeto recém-criado na lista

---

## 2. Habilitar Google Sheets API

### Passos:

1. No menu lateral, clique em **"APIs & Services"** > **"Library"** (ou **"APIs e serviços"** > **"Biblioteca"**)
2. Na barra de pesquisa, digite: `Google Sheets API`
3. Clique no resultado **"Google Sheets API"**
4. Clique em **"ENABLE"** (ou **"ATIVAR"**)
5. Aguarde alguns segundos até a API ser habilitada

---

## 3. Configurar Tela de Consentimento OAuth

### Passos:

1. No menu lateral, clique em **"APIs & Services"** > **"OAuth consent screen"** (ou **"Tela de consentimento OAuth"**)
2. Selecione **"External"** (Externo)
3. Clique em **"CREATE"** (ou **"CRIAR"**)

### 3.1. App information (Informações do aplicativo)

Preencha os campos:

- **App name**: `Controle de Gastos`
- **User support email**: Seu email
- **App logo**: (Opcional) Adicione um logo se desejar
- **Application home page**: (Opcional)
- **Application privacy policy link**: (Opcional)
- **Application terms of service link**: (Opcional)
- **Authorized domains**: (Deixe em branco por enquanto)
- **Developer contact information**: Seu email

Clique em **"SAVE AND CONTINUE"** (ou **"SALVAR E CONTINUAR"**)

### 3.2. Scopes (Escopos)

1. Clique em **"ADD OR REMOVE SCOPES"** (ou **"ADICIONAR OU REMOVER ESCOPOS"**)
2. Na caixa de pesquisa, digite: `sheets`
3. Marque a opção:
   - ✅ `https://www.googleapis.com/auth/spreadsheets` - Ver, editar, criar e excluir todas as suas planilhas do Google
4. Clique em **"UPDATE"** (ou **"ATUALIZAR"**)
5. Clique em **"SAVE AND CONTINUE"** (ou **"SALVAR E CONTINUAR"**)

### 3.3. Test users (Usuários de teste)

Se o app estiver em modo de teste:

1. Clique em **"ADD USERS"** (ou **"ADICIONAR USUÁRIOS"**)
2. Adicione o email da conta Google que você usará para testar
3. Clique em **"ADD"** (ou **"ADICIONAR"**)
4. Clique em **"SAVE AND CONTINUE"** (ou **"SALVAR E CONTINUAR"**)

### 3.4. Summary (Resumo)

Revise as informações e clique em **"BACK TO DASHBOARD"** (ou **"VOLTAR AO PAINEL"**)

---

## 4. Criar Credenciais OAuth 2.0

### 4.1. Credenciais Desktop (para desenvolvimento)

1. No menu lateral, clique em **"APIs & Services"** > **"Credentials"** (ou **"Credenciais"**)
2. Clique em **"+ CREATE CREDENTIALS"** (ou **"+ CRIAR CREDENCIAIS"**)
3. Selecione **"OAuth client ID"** (ou **"ID do cliente OAuth"**)
4. Em **"Application type"** (Tipo de aplicativo), selecione **"Desktop app"** (Aplicativo para computador)
5. Em **"Name"**, digite: `Desktop Client - Expense Tracker`
6. Clique em **"CREATE"** (ou **"CRIAR"**)
7. Uma janela aparecerá com seu `Client ID` e `Client Secret`
8. Clique em **"DOWNLOAD JSON"** (ou **"FAZER DOWNLOAD DO JSON"**)
9. Salve o arquivo (será usado no próximo passo)
10. Clique em **"OK"**

### 4.2. Credenciais Android (para produção - opcional)

Se você planeja distribuir o app:

1. Obtenha o SHA-1 do seu certificado (veja [docs/SHA1_GUIDE.md](docs/SHA1_GUIDE.md))
2. No menu lateral, clique em **"APIs & Services"** > **"Credentials"**
3. Clique em **"+ CREATE CREDENTIALS"** > **"OAuth client ID"**
4. Em **"Application type"**, selecione **"Android"**
5. Preencha:
   - **Name**: `Android Client - Expense Tracker`
   - **Package name**: `com.blacksardes.expense_tracker`
   - **SHA-1 certificate fingerprint**: Cole o SHA-1 obtido
6. Clique em **"CREATE"**

---

## 5. Baixar Arquivo credentials.json

### Passos:

1. O arquivo JSON baixado no passo 4.1 é o seu `credentials.json`
2. Renomeie o arquivo para `credentials.json` (se necessário)
3. Copie o arquivo para a pasta `assets/` do projeto:

```bash
cp ~/Downloads/client_secret_*.json assets/credentials.json
```

### Verificar o conteúdo

O arquivo deve ter esta estrutura:

```json
{
  "installed": {
    "client_id": "SEU_CLIENT_ID.apps.googleusercontent.com",
    "project_id": "seu-projeto",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_secret": "SEU_CLIENT_SECRET",
    "redirect_uris": ["http://localhost"]
  }
}
```

### Configurar o Redirect URI

**IMPORTANTE**: Você precisa adicionar o redirect URI personalizado:

1. Volte para **"APIs & Services"** > **"Credentials"**
2. Clique na credencial Desktop que você criou
3. Em **"Authorized redirect URIs"**, adicione:
   ```
   com.blacksardes.expense_tracker://oauth
   ```
4. Clique em **"SAVE"** (ou **"SALVAR"**)

**OU** edite manualmente o `credentials.json`:

```json
{
  "installed": {
    ...
    "redirect_uris": [
      "http://localhost",
      "com.blacksardes.expense_tracker://oauth"
    ]
  }
}
```

---

## 6. Obter ID da Planilha

### Passos:

1. Abra sua planilha do Google Sheets
2. Copie a URL da planilha
3. O ID é a parte entre `/d/` e `/edit`:

```
https://docs.google.com/spreadsheets/d/[SEU_ID_AQUI]/edit
```

**Exemplo**:
```
https://docs.google.com/spreadsheets/d/1A2B3C4D5E6F7G8H9I0J/edit
```
ID: `1A2B3C4D5E6F7G8H9I0J`

4. Copie o ID
5. Abra `lib/config/sheets_config.dart`
6. Substitua:

```dart
static const String spreadsheetId = '1A2B3C4D5E6F7G8H9I0J';
```

---

## 7. Verificar Estrutura da Planilha

### Requisitos:

Sua planilha deve ter:

#### 7.1. Abas dos Meses

Crie 12 abas com os seguintes nomes (exatamente como abaixo):

- Janeiro
- Fevereiro
- Março
- Abril
- Maio
- Junho
- Julho
- Agosto
- Setembro
- Outubro
- Novembro
- Dezembro

#### 7.2. Colunas (em cada aba)

A partir da **linha 9**, configure as colunas **K a O**:

| Coluna | Nome | Tipo de Dado |
|--------|------|--------------|
| K | Nome da compra | Texto |
| L | Data | DD/MM |
| M | Tipo (Meio) | Texto |
| N | Categoria | Texto |
| O | Valor | R$ XX,XX |

**Exemplo**:

```
| K              | L     | M          | N           | O         |
|----------------|-------|------------|-------------|-----------|
| Supermercado   | 15/01 | PicPay - D | Alimentação | R$ 150,00 |
| Netflix        | 10/01 | Nubank - C | Assinaturas | R$ 39,90  |
```

#### 7.3. Permissões

Certifique-se de que a conta Google que você usará no app tem permissão de **Editor** na planilha:

1. Abra a planilha
2. Clique em **"Compartilhar"** (canto superior direito)
3. Adicione sua conta Google como **Editor**
4. Clique em **"Enviar"**

---

## 8. Troubleshooting

### ❌ Erro: "Access blocked: This app's request is invalid"

**Causa**: Redirect URI não configurado corretamente

**Solução**:
1. Volte para o Google Cloud Console
2. Vá em **Credentials** > Clique na sua credencial Desktop
3. Adicione `com.blacksardes.expense_tracker://oauth` aos Redirect URIs
4. Salve

### ❌ Erro: "The OAuth client was not found"

**Causa**: Client ID ou Client Secret incorretos

**Solução**:
1. Baixe novamente o `credentials.json` do Google Cloud Console
2. Substitua o arquivo em `assets/credentials.json`
3. Execute `flutter pub get` e `flutter run`

### ❌ Erro: "This app isn't verified"

**Causa**: O app está em modo de teste

**Solução (para testes)**:
1. Adicione seu email como usuário de teste (veja passo 3.3)
2. Na tela de aviso, clique em **"Advanced"** > **"Go to [App Name] (unsafe)"**

**Solução (para produção)**:
1. Siga o processo de verificação do Google
2. Isso requer revisão e pode levar alguns dias

### ❌ Erro: "Access denied. You don't have permission to access this app"

**Causa**: Conta não está na lista de usuários de teste

**Solução**:
1. Adicione sua conta Google como usuário de teste (passo 3.3)
2. Ou publique o app (mude de "Testing" para "In production")

### ❌ Erro: "The API returned an error: 404"

**Causa**: ID da planilha incorreto ou planilha não existe

**Solução**:
1. Verifique o ID da planilha em `sheets_config.dart`
2. Confirme que a planilha existe e você tem acesso
3. Verifique se compartilhou a planilha com a conta correta

### ❌ Erro: "The caller does not have permission"

**Causa**: Google Sheets API não habilitada ou conta sem permissão

**Solução**:
1. Verifique se a Google Sheets API está habilitada (passo 2)
2. Compartilhe a planilha com a conta Google que você está usando
3. Verifique se os escopos estão corretos (passo 3.2)

---

## ✅ Checklist Final

Antes de executar o app, verifique:

- [ ] Projeto criado no Google Cloud Console
- [ ] Google Sheets API habilitada
- [ ] Tela de consentimento OAuth configurada
- [ ] Credenciais OAuth 2.0 criadas (Desktop)
- [ ] Arquivo `credentials.json` em `assets/`
- [ ] Redirect URI `com.blacksardes.expense_tracker://oauth` adicionado
- [ ] ID da planilha configurado em `sheets_config.dart`
- [ ] Planilha com 12 abas (Janeiro a Dezembro)
- [ ] Colunas K-O configuradas a partir da linha 9
- [ ] Conta Google adicionada como Editor na planilha
- [ ] Conta Google adicionada como usuário de teste (se em modo de teste)

---

## 🎉 Próximos Passos

Após completar todos os passos acima:

1. Execute `flutter pub get`
2. Execute `flutter run`
3. Faça login quando solicitado
4. Teste adicionando um gasto

Se encontrar problemas, consulte a seção [Troubleshooting no README.md](README.md#-troubleshooting).

---

**Precisa de ajuda?** Abra uma [issue no GitHub](https://github.com/BlackSardes/Planilha_Project/issues)
