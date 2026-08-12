# my_finance

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Configuracao segura do Firebase

Este projeto esta preparado para nao versionar credenciais e arquivos de configuracao local do Firebase no GitHub.

1. Copie `env.example.json` para `env.json`.
2. Preencha os campos `FIREBASE_*` no `env.json`.
3. Rode o app usando:

```bash
flutter run --dart-define-from-file=env.json
```

No codigo, as configuracoes sao carregadas por `lib/config/firebase_env_options.dart`.

Notas importantes de seguranca:

- Nao commite `env.json`, `google-services.json` e `GoogleService-Info.plist`.
- Restrinja o uso da API key no Google Cloud (Android package, SHA-1, iOS bundle e dominio web).
- Mantenha regras de seguranca do Firestore/Realtime Database bem fechadas.
