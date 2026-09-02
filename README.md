# My Finance

Aplicação de controle financeiro pessoal desenvolvida com **Flutter**, com dados sincronizados em tempo real via **Firebase** (Auth + Cloud Firestore).

O app organiza suas finanças em três módulos principais: **Gastos (Dashboard)**, **Compras** e **Viagens**, em uma interface responsiva com barra lateral.

---

## Funcionalidades

### Painel inicial — "Minhas Finanças" (Gastos)

- Boas-vindas com o mês e ano atuais.
- **Total gasto no mês corrente** em destaque.
- **Limite mensal de gastos** editável:
  - Define um limite e acompanha o progresso por barra de progresso.
  - Aviso em vermelho quando o limite é ultrapassado.
  - Quando o limite é atingido, o cadastro de novas compras é **bloqueado** na tela de Compras.
- **Gráfico de barras** dos gastos dos últimos 6 meses (`fl_chart`), com tooltip de valores.
- Lista das **compras do mês atual**.
- Atualização manual (botão de refresh) e *pull-to-refresh*.

### Módulo de Compras

- Navegação entre meses com seletor de mês (não permite avançar para um mês futuro).
- Cartão com o **total gasto no mês**.
- **Cadastro de compras** com nome, valor, categoria e data:
  - Categorias: Alimentação, Roupas, Entretenimento e Outros.
  - Validação e máscara de valor (aceita vírgula, converte ponto, limita a 2 casas decimais).
  - Data limitada entre o primeiro dia do mês atual e hoje.
- **Edição** e **exclusão** de compras (com confirmação), disponíveis para o mês atual.
- Atualização em tempo real sempre que os dados mudam no Firestore.

### Módulo de Viagens

- Lista de viagens com destino, período, moeda e **total gasto** em cada viagem.
- **Cadastro de viagem** com:
  - Destino.
  - Moeda local (lista de moedas armazenadas no Firestore e sincronizadas, com fallback local).
  - Datas de início e término.
  - Observações opcionais.
- **Exclusão** de viagem (remove também todos os gastos associados, com confirmação).

### Detalhe de viagem e gastos de viagem

- Cabeçalho com destino, período e **total gasto na viagem** na moeda da viagem.
- **Cadastro de gasto de viagem** com descrição, valor, data e categoria:
  - Categorias: Alimentação, Transporte, Hospedagem, Lazer, Compras e Outros.
- Lista dos gastos da viagem com ícones e cores por categoria.

### Infraestrutura geral

- **Responsividade**: no desktop (largura ≥ 980px) exibe barra lateral fixa com opção de recolher/expandir; em telas menores usa AppBar com menu drawer.
- **Sincronização em tempo real**: dados mantidos via *streams* do Cloud Firestore (compras, viagens e gastos de viagem atualizam automaticamente na UI).
- **Armazenamento por usuário**: autenticação anônima no Firebase Auth; cada usuário possui seus próprios dados em `users/{uid}/...`.
- **Tratamento centralizado de erros** com hierarquia de exceções (`AppException`) e tela de erro na inicialização.
- **Moedas**: base de moedas (latino-americanas) carregada do Firestore com semeadura automática e fallback local.

---

## Tecnologias e dependências

| Recurso | Tecnologia |
| --- | --- |
| Framework | Flutter (Dart SDK `^3.8.1`) |
| Backend | Firebase (Core, Auth, Cloud Firestore) |
| Gráficos | `fl_chart` |
| Aplicação | `my_finance 1.0.0+1` |

## Plataformas

O projeto inclui as pastas de plataforma para: **Android**, **iOS**, **macOS**, **Windows**, **Web** e **Linux**.

> Observação: o Firebase só é carregado para Web, Android, iOS, macOS e Windows. Em Linux, a inicialização lança uma exceção de configuração não suportada.

---

## Estrutura do projeto

```
lib/
├── main.dart                     # Inicialização (Firebase, auth anônimo) e rotas
├── config/
│   └── firebase_env_options.dart # Configurações do Firebase via --dart-define
├── data/
│   ├── expense_repository.dart   # Repositório de compras no Firestore
│   ├── expense_data.dart         # Estado e streams das compras
│   ├── travel_data.dart          # Estado e streams das viagens/gastos
│   ├── settings_data.dart        # Limite mensal de gastos
│   └── currency_data.dart        # Moedas do Firestore (com seed e fallback)
├── models/
│   ├── expense_item.dart         # Compra
│   ├── purchase_category.dart    # Categorias de compra
│   ├── trip_item.dart            # Viagem
│   ├── travel_expense.dart       # Gasto de viagem
│   └── currency.dart             # Moeda
├── pages/
│   ├── homepage.dart             # Dashboard / Gastos
│   ├── compras_page.dart         # Módulo de compras
│   ├── trips_page.dart           # Lista de viagens
│   ├── trip_detail_page.dart     # Detalhe da viagem
│   ├── create_trip_page.dart     # Cadastro de viagem
│   └── add_travel_expense_page.dart  # Cadastro de gasto de viagem
├── widgets/
│   ├── sidebar.dart              # Barra lateral de navegação
│   ├── responsive_sidebar_scaffold.dart  # Layout responsivo (desktop/mobile)
│   ├── home/                     # Widgets do dashboard (limite, gráfico, lista)
│   ├── compras/                  # Formulário, lista e seletor de mês de compras
│   ├── trips/                    # Cards de viagem e gastos de viagem
│   └── common/                   # Estados vazios e diálogos de confirmação
└── utils/
    ├── date_formatters.dart      # Formatação de datas e moeda (BRL)
    ├── currencies.dart           # Lista padrão de moedas e helpers
    └── exceptions/               # Hierarquia de exceções da aplicação
```

---

## Pré-requisitos

- Flutter SDK (`^3.8.1`) instalado.
- Um projeto no [Firebase Console](https://console.firebase.google.com/) com:
  - **Authentication** com o sinalizador *Anonymous* habilitado.
  - **Cloud Firestore** criado, com regras de segurança restritas por usuário.

## Configurando o Firebase

As credenciais não são versionadas. O app lê as configurações a partir de variáveis definidas em tempo de compilação.

1. Crie o arquivo `env.json` na raiz do projeto (não versionado). O arquivo que o projeto espera seguir o formato abaixo — preencha os valores com os do seu projeto Firebase:

```json
{
  "FIREBASE_WEB_API_KEY": "",
  "FIREBASE_WEB_APP_ID": "",
  "FIREBASE_WEB_MESSAGING_SENDER_ID": "",
  "FIREBASE_WEB_PROJECT_ID": "",
  "FIREBASE_WEB_AUTH_DOMAIN": "",
  "FIREBASE_WEB_STORAGE_BUCKET": "",
  "FIREBASE_WEB_MEASUREMENT_ID": "",
  "FIREBASE_ANDROID_API_KEY": "",
  "FIREBASE_ANDROID_APP_ID": "",
  "FIREBASE_ANDROID_MESSAGING_SENDER_ID": "",
  "FIREBASE_ANDROID_PROJECT_ID": "",
  "FIREBASE_ANDROID_STORAGE_BUCKET": "",
  "FIREBASE_IOS_API_KEY": "",
  "FIREBASE_IOS_APP_ID": "",
  "FIREBASE_IOS_MESSAGING_SENDER_ID": "",
  "FIREBASE_IOS_PROJECT_ID": "",
  "FIREBASE_IOS_STORAGE_BUCKET": "",
  "FIREBASE_IOS_BUNDLE_ID": "",
  "FIREBASE_MACOS_API_KEY": "",
  "FIREBASE_MACOS_APP_ID": "",
  "FIREBASE_MACOS_MESSAGING_SENDER_ID": "",
  "FIREBASE_MACOS_PROJECT_ID": "",
  "FIREBASE_MACOS_STORAGE_BUCKET": "",
  "FIREBASE_MACOS_BUNDLE_ID": "",
  "FIREBASE_WINDOWS_API_KEY": "",
  "FIREBASE_WINDOWS_APP_ID": "",
  "FIREBASE_WINDOWS_MESSAGING_SENDER_ID": "",
  "FIREBASE_WINDOWS_PROJECT_ID": "",
  "FIREBASE_WINDOWS_AUTH_DOMAIN": "",
  "FIREBASE_WINDOWS_STORAGE_BUCKET": "",
  "FIREBASE_WINDOWS_MEASUREMENT_ID": ""
}
```

2. Rode a aplicação passando o arquivo de configurações:

```bash
flutter run --dart-define-from-file=env.json
```

3. Para rodar com um dispositivo/plataforma específico:

```bash
flutter run --dart-define-from-file=env.json -d chrome   # Web
flutter run --dart-define-from-file=env.json -d windows  # Windows
```

### Mapa de dados no Firestore

| Coleção | Uso |
| --- | --- |
| `users/{uid}/expenses` | Compras do usuário |
| `users/{uid}/trips` | Viagens do usuário |
| `users/{uid}/travel_expenses` | Gastos de viagem do usuário |
| `users/{uid}/settings/spending` | Limite mensal de gastos |
| `currencies` | Moedas disponíveis (base global) |

---

## Executando os testes

```bash
flutter test
```

A suíte inclui testes de widget para o seletor de mês, a lista de compras e o formulário de compra (validações, máscara de valor e modos nova/edição).

---

