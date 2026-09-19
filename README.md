# 🏥 Clinics Mobile

> **Aplicativo móvel para agregação e comparação de preços de exames médicos e consultas em Surubim - PE, com agendamento direto via WhatsApp.**

---

## 👥 Integrantes da Dupla
- **Aluno 1:** [Inserir Nome e Matrícula]
- **Aluno 2:** [Inserir Nome e Matrícula]

---

## 📋 Contexto do Projeto

O **Clinics** é uma solução móvel desenvolvida para dar transparência aos custos de saúde na cidade de Surubim (Pernambuco). O aplicativo permite que a população consulte, compare valores praticados por diferentes clínicas e laboratórios locais, verifique preparos obrigatórios (como tempo de jejum e entrega de laudos) e entre em contato diretamente com a recepção da clínica escolhida via WhatsApp com mensagens pré-formatadas.

---

## 📱 Telas Implementadas (Entrega 01 - Avaliação)

Conforme os requisitos da **Entrega 01** (mínimo de 6 interfaces estilizadas e com navegação funcional):

1. **Tela de Autenticação / Login (`/login`)**:
   - Alternador segmentado "Entrar" e "Cadastrar".
   - Seletor de método de login: Telefone (com máscara de DDD 81) ou E-mail.
   - Botões de acesso rápido com Gov.br e Google.
   - Opção de entrada rápida como visitante para consulta imediata.

2. **Tela Inicial e Busca Centralizada (`/home`)**:
   - Barra de busca com atalho para busca por voz e filtros avançados.
   - Trilho horizontal de filtros por categoria: *Sangue*, *Raio-X*, *Consultas*, *Cardio*, *Ultrassom*.
   - Seção de exames em alta na semana em Surubim (ex: Hemograma, Ultrassom, ECG).
   - Banner de agendamento garantido via WhatsApp.
   - Barra de navegação inferior (*Início*, *Busca*, *Perfil*).

3. **Menu Lateral Drawer (Navegação Global)**:
   - Identificação do usuário logado (foto, nome, telefone e selo de Paciente).
   - Acesso rápido a Início, Busca e Comparação, Clínicas Parceiras, Perfil, Painel da Clínica e Sair.

4. **Tela de Resultados de Busca & Comparação de Preços (`/search`)**:
   - Comparação lado a lado de exames entre clínicas concorrentes em Surubim.
   - Ordenação dinâmica por Menor Preço ou Melhor Avaliação.
   - Destaque claro de preços, formas de pagamento (à vista, cartão, pix) e tempo de resultado.
   - Botão direto de WhatsApp em cada card de clínica.

5. **Tela de Detalhes do Exame (`/exam/:id`)**:
   - Descrição clínica do procedimento.
   - Guia completo de preparo (horas de jejum, ingestão de água, orientações para laudo).
   - Bloco de informações da clínica com endereço físico e horários de funcionamento.
   - Ação fixa inferior (CTA) para agendamento direto pelo WhatsApp.

6. **Tela do Perfil Público da Clínica (`/clinic/:id`)**:
   - Cabeçalho estético com avaliação, quantidade de exames e total de pacientes atendidos.
   - Abas estilo Instagram:
     - **Exames**: Tabela completa de exames oferecidos pela clínica com preços e atalhos.
     - **Estrutura**: Galeria de fotos do ambiente (recepção, sala de coleta, aparelhos).
     - **Horários**: Horários de funcionamento, convênios aceitos e localização.

7. **Tela de Perfil do Usuário (`/profile`)**:
   - Dados cadastrais do paciente (Nome, WhatsApp, E-mail, Cidade de Referência).
   - Preferências de notificações de ofertas e segurança.
   - Botão de logout com redirecionamento de volta ao login.

---

## 🛠️ Tecnologias Utilizadas

- **Linguagem & Framework:** Flutter (Dart 3)
- **Design System:** Baseado em tokens do protótipo com fontes *Plus Jakarta Sans* e *Inter* via `google_fonts`.
- **Roteamento:** `go_router` (rotas declarativas e navegação parametrizada).
- **Gerenciamento de Estado:** `flutter_riverpod`.
- **Integração Externa:** `url_launcher` para abertura do protocolo do WhatsApp (`https://wa.me/...`).

---

## 🚀 Como Executar o Aplicativo

### Pré-requisitos
- Flutter SDK instalado (versão 3.13+ ou superior).
- Emulador Android, simulador iOS ou dispositivo físico conectado.

### Execução

```bash
# 1. Navegue até a pasta do aplicativo Flutter
cd clinics

# 2. Instale as dependências
flutter pub get

# 3. Execute os testes unitários e de widget
flutter test

# 4. Inicie o aplicativo no emulador ou dispositivo
flutter run
```

---

## 📂 Estrutura de Pastas do Projeto

```
clinics/
├── lib/
│   ├── core/
│   │   ├── router/          # Configuração de rotas (GoRouter)
│   │   ├── theme/           # Tokens de cores e tema (AppTheme & AppColors)
│   │   └── utils/           # Helper para acionamento do WhatsApp
│   ├── features/
│   │   ├── auth/            # Tela de Login e Cadastro
│   │   ├── search/          # Início, Busca, Comparação e Entidades (Exam, Clinic, MockData)
│   │   ├── exam/            # Tela de Detalhes e Preparo do Exame
│   │   ├── clinic/          # Perfil Público da Clínica (Tabs: Exames, Fotos, Horários)
│   │   └── profile/         # Perfil do Paciente e Menu Lateral (AppDrawer)
│   └── main.dart            # Ponto de entrada do app Flutter
└── test/
    └── widget_test.dart     # Testes automatizados de interface
```
