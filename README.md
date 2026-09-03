# My Finance

Aplicação de controle financeiro pessoal desenvolvida com **Flutter** e sincronização em tempo real via **Firebase** (Auth + Cloud Firestore).

O app organiza suas finanças em três módulos principais: **Gastos (Dashboard)**, **Compras** e **Viagens**, oferecendo uma interface responsiva (desktop/mobile) com barra lateral.

---

## Visão geral

My Finance foi criado para controlar despesas pessoais com foco em simplicidade e sincronização entre dispositivos. Ele usa autenticação anônima do Firebase para armazenar dados por usuário em collections isoladas.

Principais objetivos:
- Monitorar gastos mensais e acompanhar progresso em relação a um limite configurável.
- Registrar compras com categorização e histórico por mês.
- Planejar viagens e rastrear gastos por viagem com suporte a moeda local.

---

## Funcionalidades (resumido)

1. Painel inicial — "Minhas Finanças" (Gastos)
   - Exibe mês e ano atuais, total gasto no mês em destaque e progresso em relação ao limite mensal.
   - Permite definir/editar um limite mensal de gastos; mostra barra de progresso e alerta visual quando ultrapassado.
   - Bloqueio do cadastro de novas compras na tela de Compras quando o limite é atingido.
   - Gráfico de barras com os gastos dos últimos 6 meses (usando `fl_chart`) com tooltip de valores.
   - Lista das compras do mês atual e atualização via pull-to-refresh e botão de refresh.

2. Módulo de Compras
   - Navegação entre meses (não permite avançar para meses futuros).
   - Cartão com total gasto no mês selecionado.
   - Cadastro/edição/exclusão de compras (com confirmação) para o mês atual.
   - Formulário com nome, valor, categoria (Alimentação, Roupas, Entretenimento, Outros) e data.
   - Validações: máscara de valor que aceita vírgula/ponto e normaliza para 2 casas decimais; data limitada entre o primeiro dia do mês e hoje.
   - Sincronização em tempo real via streams do Firestore.

3. Módulo de Viagens
   - Lista de viagens com destino, período, moeda e total gasto por viagem.
   - Cadastro de viagem com destino, moeda local (lista sincronizada do Firestore com fallback local), datas e observações.
   - Exclusão de viagem remove também os gastos associados (com confirmação).

4. Detalhe de viagem e gastos por viagem
   - Cabeçalho com destino, período e total gasto na moeda da viagem.
   - Cadastro de gasto de viagem com descrição, valor, data e categoria (Alimentação, Transporte, Hospedagem, Lazer, Compras, Outros).
   - Listagem dos gastos da viagem com ícones e cores por categoria.

---

## Infraestrutura e comportamento

- Responsividade: em desktop (largura ≥ 980px) exibe barra lateral fixa com opção de recolher/expandir; em telas menores usa AppBar com drawer.
- Sincronização em tempo real: streams do Cloud Firestore mantêm a UI atualizada automaticamente quando os dados mudam.
- Armazenamento por usuário: cada usuário tem seus dados em `users/{uid}/...`. O app usa autenticação anônima no Firebase Auth.
- Tratamento centralizado de erros com hierarquia de exceções (`AppException`) e tela de erro na inicialização.
- Moedas: base de moedas (latino-americanas) carregada do Firestore com semeadura automática e fallback local.

---

## Tecnologias e dependências

| Recurso | Tecnologia |
| --- | --- |
| Framework | Flutter (Dart SDK `^3.8.1`) |
| Backend | Firebase (Core, Auth, Cloud Firestore) |
| Gráficos | `fl_chart` |
| Aplicação | `my_finance 1.0.0+1` |

---

## Plataformas suportadas

O projeto inclui pastas de plataforma para: **Android**, **iOS**, **macOS**, **Windows**, **Web** e **Linux**.

Observação: o Firebase é inicializado nas plataformas Web, Android, iOS, macOS e Windows. Em Linux, a inicialização do Firebase lança uma exceção de configuração não suportada (tratada pela aplicação).

---

## Estrutura do projeto (principal)

```text
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
- Um projeto no Firebase Console com:
  - Authentication com o provedor Anonymous habilitado.
  - Cloud Firestore criado e regras que restringem acesso por usuário.

---

## Configurando o Firebase

As credenciais não são versionadas. O app lê as configurações a partir de variáveis definidas em tempo de compilação.

1. Crie o arquivo `env.json` na raiz do projeto (não versionado). Preencha com as credenciais do seu projeto Firebase. Exemplo do formato esperado:

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

2. Execute a aplicação passando o arquivo de configurações:

```bash
flutter run --dart-define-from-file=env.json
```

3. Para executar em uma plataforma/dispositivo específico:

```bash
flutter run --dart-define-from-file=env.json -d chrome   # Web
flutter run --dart-define-from-file=env.json -d windows  # Windows
```

---

## Mapa de dados no Firestore

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

## Contribuição

Se quiser contribuir ou abrir issues/PRs, por favor descreva a mudança proposta e inclua passos para reproduzir ou testar a alteração.
