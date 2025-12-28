# 🔐 Guia SHA-1 - Obter Fingerprint do Certificado Android

Este guia explica como obter o SHA-1 fingerprint do seu certificado Android, necessário para criar credenciais OAuth 2.0 para Android no Google Cloud Console.

## 📋 O que é SHA-1?

SHA-1 (Secure Hash Algorithm 1) é uma impressão digital única do certificado usado para assinar seu aplicativo Android. O Google usa isso para verificar a autenticidade do seu app.

## 🔑 Tipos de Certificado

### 1. Debug Keystore (Desenvolvimento)

Usado durante o desenvolvimento e testes. É gerado automaticamente pelo Flutter/Android SDK.

**Localização**:
- **Linux/Mac**: `~/.android/debug.keystore`
- **Windows**: `C:\Users\[SEU_USUARIO]\.android\debug.keystore`

### 2. Release Keystore (Produção)

Usado para publicar o app na Play Store. Você precisa criar manualmente.

---

## 🛠️ Método 1: Usando keytool (Recomendado)

### Para Debug Keystore

#### Linux/Mac

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

#### Windows

```cmd
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### Para Release Keystore

```bash
keytool -list -v -keystore /caminho/para/seu/keystore.jks -alias seu_alias
```

**Nota**: Você precisará digitar a senha do keystore.

### Saída Esperada

```
Alias name: androiddebugkey
Creation date: Jan 1, 2024
Entry type: PrivateKeyEntry
Certificate chain length: 1
Certificate[1]:
Owner: C=US, O=Android, CN=Android Debug
Issuer: C=US, O=Android, CN=Android Debug
Serial number: 1
Valid from: Mon Jan 01 00:00:00 BRT 2024 until: Wed Dec 25 00:00:00 BRT 2054
Certificate fingerprints:
         SHA1: A1:B2:C3:D4:E5:F6:01:02:03:04:05:06:07:08:09:0A:0B:0C:0D:0E  ← Este é o SHA-1
         SHA256: ...
Signature algorithm name: SHA1withRSA
Subject Public Key Algorithm: 2048-bit RSA key
Version: 1
```

**📝 Copie o valor após "SHA1:"**
```
A1:B2:C3:D4:E5:F6:01:02:03:04:05:06:07:08:09:0A:0B:0C:0D:0E
```

---

## 🛠️ Método 2: Usando Gradle (Alternativo)

### Passo 1: Adicionar Task no build.gradle

Crie ou edite o arquivo `android/app/build.gradle.kts` e adicione:

```kotlin
// No final do arquivo
tasks.register("getSigningReport") {
    doLast {
        val config = android.buildTypes.getByName("debug").signingConfig
        println("SHA-1: ${config?.storeFile}")
    }
}
```

### Passo 2: Executar a Task

No terminal, execute:

```bash
cd android
./gradlew signingReport
```

### Saída Esperada

```
> Task :app:signingReport
Variant: debug
Config: debug
Store: /home/user/.android/debug.keystore
Alias: AndroidDebugKey
MD5: A1:B2:C3:D4:E5:F6:01:02:03:04:05:06:07:08:09:0A
SHA1: A1:B2:C3:D4:E5:F6:01:02:03:04:05:06:07:08:09:0A:0B:0C:0D:0E  ← Este
SHA-256: ...
Valid until: Wednesday, December 25, 2054
```

---

## 🛠️ Método 3: Usando Android Studio

### Passo 1: Abrir o Projeto

1. Abra Android Studio
2. Open → Selecione a pasta `android/` do seu projeto

### Passo 2: Acessar Gradle Tasks

1. No menu lateral direito, clique em **Gradle**
2. Navegue para: **app** > **Tasks** > **android** > **signingReport**
3. Clique duas vezes em **signingReport**

### Passo 3: Visualizar o Output

No terminal do Android Studio, você verá a saída com o SHA-1.

---

## 📦 Criar Release Keystore (Produção)

Se você ainda não tem um release keystore, crie um:

```bash
keytool -genkey -v -keystore ~/release-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release
```

**Preencha as informações solicitadas**:
```
Enter keystore password: [DIGITE_UMA_SENHA_FORTE]
Re-enter new password: [REPITA_A_SENHA]
What is your first and last name?
  [Unknown]:  Seu Nome
What is the name of your organizational unit?
  [Unknown]:  Seu Departamento
What is the name of your organization?
  [Unknown]:  Sua Empresa
What is the name of your City or Locality?
  [Unknown]:  Sua Cidade
What is the name of your State or Province?
  [Unknown]:  Seu Estado
What is the two-letter country code for this unit?
  [Unknown]:  BR
Is CN=Seu Nome, OU=..., correct?
  [no]:  yes

Generating 2,048 bit RSA key pair and self-signed certificate (SHA256withRSA) with a validity of 10,000 days
        for: CN=Seu Nome, ...
Enter key password for <release>
        (RETURN if same as keystore password):  [PRESSIONE ENTER]
[Storing ~/release-keystore.jks]
```

**⚠️ IMPORTANTE**: 
- Guarde a senha em local seguro
- Faça backup do arquivo `.jks`
- Se perder, não poderá atualizar o app na Play Store

---

## 🔧 Configurar Release Keystore no Flutter

### Passo 1: Criar key.properties

Crie o arquivo `android/key.properties`:

```properties
storePassword=SUA_SENHA_DO_KEYSTORE
keyPassword=SUA_SENHA_DA_CHAVE
keyAlias=release
storeFile=/caminho/absoluto/para/release-keystore.jks
```

**⚠️ Adicione ao .gitignore**:
```
android/key.properties
*.jks
```

### Passo 2: Atualizar build.gradle.kts

Edite `android/app/build.gradle.kts`:

```kotlin
// No topo, antes de android {}
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // ... configurações existentes ...

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

---

## 🌐 Adicionar SHA-1 no Google Cloud Console

### Passo 1: Acessar Credentials

1. Vá para [Google Cloud Console](https://console.cloud.google.com/)
2. Selecione seu projeto
3. Menu > **APIs & Services** > **Credentials**

### Passo 2: Criar Credencial Android

1. Clique em **+ CREATE CREDENTIALS**
2. Selecione **OAuth client ID**
3. **Application type**: Android
4. Preencha:

```
Name: Android Client - Expense Tracker
Package name: com.blacksardes.expense_tracker
SHA-1 certificate fingerprint: [COLE_SEU_SHA-1_AQUI]
```

5. Clique em **CREATE**

### Visual:

```
┌────────────────────────────────────────────┐
│ Create OAuth client ID                     │
├────────────────────────────────────────────┤
│                                            │
│ Application type                           │
│ Android                            ▼       │
│                                            │
│ Name                                       │
│ Android Client - Expense Tracker           │
│                                            │
│ Package name *                             │
│ com.blacksardes.expense_tracker            │
│                                            │
│ SHA-1 certificate fingerprint *            │
│ A1:B2:C3:D4:E5:F6:01:02:03:04:05:06:...    │
│                                            │
│         [CANCEL]  [CREATE]                 │
└────────────────────────────────────────────┘
```

---

## ✅ Verificação

Para verificar se o SHA-1 está correto:

### Debug Build

```bash
flutter run --debug
```

Se o app conseguir fazer login, o SHA-1 debug está correto.

### Release Build

```bash
flutter build apk --release
flutter install
```

Se o app conseguir fazer login, o SHA-1 release está correto.

---

## 🔍 Troubleshooting

### ❌ "keytool: command not found"

**Causa**: Java JDK não instalado ou não está no PATH

**Solução**:

**Linux**:
```bash
sudo apt-get install openjdk-11-jdk
```

**Mac**:
```bash
brew install openjdk@11
```

**Windows**:
1. Baixe o JDK em https://www.oracle.com/java/technologies/downloads/
2. Instale e adicione ao PATH

### ❌ "Keystore was tampered with, or password was incorrect"

**Causa**: Senha incorreta

**Solução**:
- Para debug keystore, a senha é sempre `android`
- Para release keystore, use a senha que você definiu ao criar

### ❌ "App não autentica mesmo com SHA-1 correto"

**Soluções**:

1. Verifique se o package name está correto:
   ```kotlin
   // android/app/build.gradle.kts
   applicationId = "com.blacksardes.expense_tracker"
   ```

2. Certifique-se de que adicionou AMBOS os SHA-1:
   - SHA-1 do debug keystore (para desenvolvimento)
   - SHA-1 do release keystore (para produção)

3. Aguarde alguns minutos para as alterações propagarem

4. Limpe e reconstrua o app:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

## 📱 SHA-1 para Diferentes Ambientes

### Desenvolvimento Local

```
SHA-1: [Debug Keystore]
Package: com.blacksardes.expense_tracker
```

### Play Store (Produção)

```
SHA-1: [Release Keystore]
Package: com.blacksardes.expense_tracker
```

### Google Play App Signing

Se você usar o Google Play App Signing:

1. Vá para Play Console
2. Seu App > Setup > App integrity
3. Copie o SHA-1 do **App signing certificate**
4. Adicione esse SHA-1 também no Google Cloud Console

---

## 🎯 Checklist

- [ ] SHA-1 do debug keystore obtido
- [ ] SHA-1 adicionado no Google Cloud Console (Android)
- [ ] Package name correto: `com.blacksardes.expense_tracker`
- [ ] App testado e autenticando corretamente
- [ ] (Opcional) Release keystore criado
- [ ] (Opcional) SHA-1 do release keystore obtido e adicionado
- [ ] (Opcional) Configuração de assinatura no build.gradle.kts

---

## 🚀 Próximos Passos

Após obter e configurar o SHA-1:

1. ✅ Credenciais Android criadas no Google Cloud Console
2. ➡️ Volte para [SETUP.md](../SETUP.md) para continuar a configuração
3. 🚀 Execute o app e teste a autenticação

---

**Precisa de ajuda?** Consulte o [Troubleshooting](../SETUP.md#8-troubleshooting) ou abra uma [issue](https://github.com/BlackSardes/Planilha_Project/issues)
