# Roadmap das Entregas 2 e 3 (`ROADMAP_ENTREGAS.md`)

> **Para o agente de IA:** este arquivo registra as decisões tomadas com o usuário e é a fonte de verdade do que entra em cada entrega. Leia antes de começar a Entrega 3. Ao concluir um item, marque-o com `[x]`.
> Fonte dos requisitos: `docs/avaliacao.pdf`.

## 0. Decisões já tomadas

- **Escopo:** só a visão do **paciente**. A visão da clínica (telas 7 e 8, UCs de `clinic_manager`) fica para depois. O usuário não quer limitar-se ao mínimo do PDF.
- **Pastas e repositórios separados**, irmãos do repo atual:
  - `~/Repositorio/clinics-mobile` → app Flutter (`clinics/`) + documentação (`docs/`)
  - `~/Repositorio/clinics-backend` → API Spring Boot (git próprio)
- **Back-end:** Spring Boot (substitui o Go previsto em `AGENTS.md`, `MVP_specification.md` e `docs/ARCHITECTURE.md`; atualizar esses docs).
- **Stack e arquitetura (padrão proposto, o usuário não contestou; confirmar se houver dúvida):** Java 21, Maven, Spring Boot 3.x, arquitetura hexagonal por feature (`domain` / `application` / `infrastructure`). Bibliotecas: Spring Web, Data JPA, Security + jjwt, Flyway, Bean Validation, MapStruct, springdoc OpenAPI, Testcontainers + JUnit 5, Docker Compose (PostgreSQL).
- **Dados iniciais:** seed via migração Flyway com cerca de 6 clínicas e 30 exames realistas de Surubim-PE.
- **Perguntar ao usuário** nas decisões ambíguas. O usuário tem conhecimento de desenvolvimento e quer práticas de engenharia profissional.
- **Convenções:** identificadores em inglês, textos ao usuário em pt-BR, tokens de design em `docs/DESIGN_SYSTEM.md`.

## 1. Análise tela a tela → casos de uso

| Tela | Casos de uso derivados |
|---|---|
| 1. Login/Cadastro | UC01 Cadastrar paciente · UC02 Autenticar (JWT + refresh) · UC03 Recuperar senha · UC04 Aceitar termos LGPD |
| 2. Início | UC05 Listar categorias · UC06 Ver exames em alta · UC07 Busca por voz (recurso de dispositivo, não UC de back-end) |
| 3. Drawer | UC08 Gerenciar preferências (tema, notificações) · UC09 Consultar FAQ |
| 4. Resultados | UC10 Buscar e comparar exames · UC11 Registrar histórico de busca |
| 5. Detalhes | UC12 Ver detalhes do exame · UC13 Contatar clínica via WhatsApp (registra o clique e calcula a economia) |
| 6. Perfil | UC14 Editar perfil (inclui foto) · UC15 Alterar senha · UC16 Favoritar exames · UC17 Ver histórico de buscas · UC18 Exportar meus dados · UC19 Excluir conta |
| 9. Ficha da clínica | UC21 Ver perfil da clínica · UC22 Avaliar clínica · UC23 Ver rota no mapa (recurso de dispositivo) |

## 2. Entrega 2 (em andamento)

**Pontuação:** documentação 2,0 · back-end e API 3,0 · banco 2,0 · app 2,0 · recurso do dispositivo 1,0.

### 2.1. Casos de uso no back-end (8 grupos, com endpoints)

| UC | Endpoints | Notas |
|---|---|---|
| UC01 Cadastrar paciente | `POST /api/v1/auth/register` | Senha com BCrypt (custo ≥ 10); telefone único |
| UC02 Autenticar | `POST /api/v1/auth/login`, `POST /api/v1/auth/refresh` | JWT com `user_id`, `role`, `exp` |
| UC10 Buscar e comparar exames | `GET /api/v1/exams/search?query&category&sort_by&lat&lng` | Devolve preço médio local e a economia em relação à média |
| UC12 Ver detalhes do exame | `GET /api/v1/exams/{id}` | Inclui dados da clínica e se está aberta agora |
| UC06 Ver exames em alta | `GET /api/v1/exams/trending` | Ordenado por contagem de contatos e visualizações na semana |
| UC16 Favoritar exames | `PUT /api/v1/me/favorites/{examId}`, `DELETE /api/v1/me/favorites/{examId}`, `GET /api/v1/me/favorites` | Idempotente |
| UC22 Avaliar clínica | `POST /api/v1/clinics/{id}/reviews`, `GET /api/v1/clinics/{id}/reviews` | Uma avaliação por usuário e clínica; recalcula a nota média |
| UC13 Contatar via WhatsApp | `POST /api/v1/exams/{id}/contacts` | Registra o evento; devolve a URL `wa.me` e a economia estimada |
| UC14/UC15 Perfil e senha | `GET/PUT /api/v1/me`, `PUT /api/v1/me/password`, `PUT /api/v1/me/avatar` | O avatar vem da câmera ou galeria |
| UC21 Ver perfil da clínica | `GET /api/v1/clinics/{id}` | Já descrito em `API_SPECIFICATION.md` |

### 2.2. Banco PostgreSQL (7 tabelas, migrações Flyway)

`users` · `clinics` · `exams` · `favorites` · `reviews` · `price_history` · `contact_events`
(`price_history` alimenta o alerta de queda de preço; `contact_events` alimenta "Em alta" e "R$ economizados".)

### 2.3. Recursos do dispositivo (4, decididos com o usuário)

| Recurso | Pacote | Onde |
|---|---|---|
| GPS: distância até a clínica e filtro "Mais Próximo" | `geolocator` | Telas 2, 4 e 5 |
| Voz na busca | `speech_to_text` | Tela 2 (ícone do microfone) |
| Câmera/galeria: foto de perfil | `image_picker` | Tela 6 (botão no avatar) |
| Notificações locais: alerta de menor preço de favoritos e lembrete de jejum | `flutter_local_notifications` | Tela 3 (toggle) e tela 5 |

### 2.4. Documentação
- [ ] Atualizar o documento de casos de uso (≥ 4 novos; registrar todos os UCs da seção 1, indicando o status de cada)
- [ ] Diagrama de classes do domínio do back-end
- [ ] Diagrama ER (opcional) e OpenAPI via springdoc
- [ ] README dos dois repositórios com os nomes da dupla (Márcio Ferreira Lima e Lucas Nascimento Barros) e as instruções de execução

### 2.5. App
- [ ] Substituir os mocks por repositórios que chamam a API (camada `data/`, Riverpod)
- [ ] Login e cadastro reais; token guardado de forma segura
- [ ] Busca, detalhes, favoritos, avaliação e perfil integrados
- [ ] Os 4 recursos do dispositivo

## 3. Entrega 3 (planejada, para fazer depois)

**Pontuação:** back-end +4 UCs (3,0) · banco +3 tabelas (1,0) · app (2,0) · +1 recurso do dispositivo (1,0) · deploy `.apk`/`.aab` assinado (2,0) · documentação refatorada + README (1,0) · **bônus JWT + RBAC (1,0)**.

### 3.1. Casos de uso reservados (≥ 4 obrigatórios; sobram para escolha)

| UC | Endpoints previstos | Tabela nova |
|---|---|---|
| UC03 Recuperar senha | `POST /auth/forgot-password`, `POST /auth/reset-password` | `password_reset_tokens` |
| UC11/UC17 Histórico de buscas | `GET /me/search-history`, `DELETE /me/search-history` | `search_history` |
| UC04 Consentimento LGPD | `POST /me/consents`, `GET /me/consents` | `consents` |
| UC18 Exportar meus dados | `GET /me/export` | (reaproveita as tabelas existentes) |
| UC19 Excluir conta | `DELETE /me` | (anonimização) |
| UC08 Preferências | `GET/PUT /me/preferences` | `user_preferences` |
| UC09 FAQ | `GET /faq` | `faq_items` |
| UC05 Categorias | `GET /categories` | `categories` |

Sugestão: UC03, UC17, UC04, UC18 (4 UCs) mais UC19 e UC08 se sobrar tempo. Tabelas novas: `password_reset_tokens`, `search_history`, `consents` (3, que bate com o mínimo).

### 3.2. Bônus JWT + RBAC
O JWT já existe desde a Entrega 2. Na Entrega 3 acrescentar o RBAC: `@PreAuthorize` por papel (`patient`, `clinic_manager`, `admin`), um endpoint exclusivo de admin e testes de autorização. Rotas de gestão de exames com validação de propriedade (IDOR), conforme `AGENTS.md` seção 3.

### 3.3. Recursos do dispositivo reservados (pelo menos 1 obrigatório)

| Recurso | Pacote | Observação |
|---|---|---|
| Biometria + armazenamento seguro do token | `local_auth`, `flutter_secure_storage` | Maior valor técnico; reforça o bônus de segurança |
| Compartilhar exame | `share_plus` | Barato de fazer |
| Modo offline com cache da última busca | `connectivity_plus` + `drift` | Mostra tratamento de falha de rede |
| (Extras) geocodificação reversa do bairro, lembrete no calendário | `geocoding` | Opcional |

### 3.4. Deploy e documentação
- [ ] Gerar keystore e `.apk`/`.aab` assinado (`flutter build appbundle`), com `key.properties` fora do git
- [ ] Hospedar o back-end e o PostgreSQL (por exemplo, Render, Railway ou Fly.io) e apontar o app para a URL de produção
- [ ] Refatorar os diagramas de casos de uso e de classes para o estado final
- [ ] README completo: tecnologias, documentação, instruções de execução

### 3.5. Melhorias de produto já mapeadas (usar se faltar ideia)
- Gráfico de evolução do preço de um exame (`price_history`)
- "Atende hoje" e "aberto agora" calculados a partir dos horários da clínica
- Paginação e ordenação na busca
- Padronizar o nome do produto: o protótipo diz "Clara Saúde" e o código diz "Clinics"
- Visão da clínica (telas 7 e 8, CRUD de exames com checagem de propriedade), adiada por decisão do usuário

## 4. Registro de progresso

- 2026-10-12: levantamento de requisitos e roadmap criados. Nenhum código escrito ainda.
