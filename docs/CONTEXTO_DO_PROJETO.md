# Contexto do Projeto Clinics (handoff entre sessões)

> **Para o agente de IA que retomar este trabalho:** leia este arquivo inteiro antes de qualquer ação. Ele resume tudo que foi decidido e construído até 2026-10-12. Complementos: `docs/ROADMAP_ENTREGAS.md` (planejamento das Entregas 2 e 3) e a pasta `docs/` do repositório `clinics-backend`.
> Atualize a seção **13. Registro de progresso** ao final de cada etapa.

---

## 1. O projeto em uma frase

**Clinics** é um app móvel que compara preços de exames e consultas em clínicas de **Surubim-PE** e leva o paciente ao WhatsApp da clínica com a mensagem pronta. Trabalho da disciplina **Programação para Dispositivos Móveis**, em dupla: **Márcio Ferreira Lima** (usuário do Git: `MarcioFerreiraL`) e **Lucas Nascimento Barros**.

## 2. Requisitos da avaliação (`docs/avaliacao.pdf`)

Regras gerais: dupla, tema original, código no **GitHub público**, **muitos commits ao longo do tempo**, nomes da dupla no `README.md` e no comentário do Classroom, **o envio no Classroom é o link do último commit** (não do repositório). Descumprir qualquer item zera a nota. Cada entrega é apresentada oralmente em até 7 minutos.

| Entrega | Itens | Nota |
|---|---|---|
| **1** (feita) | Diagrama de casos de uso, README, protótipo Figma/Stitch, 6+ telas Flutter navegáveis | 10 |
| **2** (em andamento) | Casos de uso +4 e diagrama de classes (2), back-end com 4+ UCs e endpoints (3), 3+ tabelas PostgreSQL (2), app integrado à API (2), 1 recurso do dispositivo (1) | 10 |
| **3** (planejada) | +4 UCs no back-end (3), +3 tabelas (1), app integrado (2), +1 recurso do dispositivo (1), `.apk`/`.aab` assinado (2), diagramas e README refatorados (1), **bônus** JWT + RBAC (1) | 11 |

## 3. Escopo e decisões do usuário

- **Só a visão do paciente.** A visão da clínica (telas 7 e 8, gestão de exames, papel `CLINIC_MANAGER`) foi **adiada** por decisão do usuário.
- **Ir além do mínimo do PDF**, com práticas de engenharia de software de nível profissional.
- **Backend e frontend em repositórios separados**, irmãos em `~/Repositorio/`.
- **Back-end em Spring Boot** (substituiu o Go previsto em `AGENTS.md`, `MVP_specification.md`, `docs/ARCHITECTURE.md` e `docs/API_SPECIFICATION.md`).
- **4 recursos de dispositivo na Entrega 2:** GPS, voz, câmera/galeria e notificações locais. Biometria, compartilhar e modo offline ficam para a Entrega 3 (o usuário quer guardar ideias para ela).
- **Tabelas da Entrega 3 só entram na Entrega 3** (`password_reset_tokens`, `search_history`, `consents`, `refresh_tokens`).
- **Tudo da Entrega 3 é "para fazer depois"**, não entra agora.
- Escopo de banco e UCs: modelo de **9 tabelas** e **12 casos de uso** (confirmado pelo usuário, incluindo catálogo separado `exam_types`, tabela de horários e favoritos por tipo de exame).

## 4. Preferências de trabalho do usuário (seguir sempre)

1. **Perguntar com frequência** antes de decisões relevantes. O usuário tem conhecimento de desenvolvimento e quer participar. Usar perguntas objetivas com opções e uma recomendada.
2. **Documentação primeiro**: requisitos, histórias de usuário, regras de negócio, diagramas, MER, antes de codar. Os documentos guiam o desenvolvimento.
3. **Pensar no banco antes de desenvolver**; MER em markdown com diagramas Mermaid.
4. **Commits**: padrão Conventional Commits, **em português**, **curtos e objetivos**, um commit por unidade de trabalho. Terminar com a linha `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. Nada de corpo longo.
5. **Testes**: domínio (unidade) + integração por endpoint com PostgreSQL real (Testcontainers).
6. Código em inglês, textos ao usuário em pt-BR, JSON em `snake_case`.
7. Responder em português, de forma direta.

## 5. Estado do ambiente

| Item | Situação |
|---|---|
| Repositório do app | `~/Repositorio/clinics-mobile` (branch `master`). Contém `clinics/` (Flutter), `docs/`, `AGENTS.md`, `MVP_specification.md` |
| Repositório do back-end | `~/Repositorio/clinics-backend` (branch `main`), **49 commits**, árvore limpa, **ainda sem remote no GitHub** |
| JDK | OpenJDK **25** (o usuário instalou `openjdk-25-jdk-headless`) |
| Maven | Wrapper `./mvnw` (Maven 3.10.0) |
| Docker | Disponível. Já existe um container `banco_dados` do usuário na porta **5432**; o do projeto é `clinics_postgres` na **5433** (`docker compose up -d`) |
| Flutter/Dart | `/snap/bin/flutter` e `/snap/bin/dart` |
| GitHub CLI (`gh`) | **Não instalado.** Para publicar: o usuário cria o repositório vazio e público no site e informa a URL, ou instala com `sudo apt install -y gh` + `gh auth login` |
| Sudo | Não disponível para o agente; o usuário roda com `! comando` |

## 6. Back-end `clinics-backend` (Entrega 2: **concluído e documentado**)

**Stack:** Java 25, **Spring Boot 4.1.1** (a versão no Maven Central é `4.1.1`, **sem** o sufixo `.RELEASE` que o Initializr gera), PostgreSQL 17, Flyway, Spring Security com JWT (OAuth2 Resource Server, HS256), BCrypt custo 10, Spring Data JPA (escrita) + `JdbcClient` (consultas), springdoc-openapi 3.1.1, JUnit 5, Testcontainers, ArchUnit.

**Arquitetura:** hexagonal por funcionalidade, três módulos: `identity`, `catalog`, `engagement`, mais `shared`. Domínio sem Spring/JPA/Jackson, verificado por `ArchitectureTest`. `engagement` consome o catálogo só pela porta pública (adaptador anticorrupção).

**12 casos de uso implementados** (todos com testes de integração). Base `/api/v1`; JSON `snake_case`; erros RFC 9457 com campo `code`:

| UC | Endpoint | Acesso |
|---|---|---|
| UC01 | `POST /auth/register` | público |
| UC02 | `POST /auth/login` | público |
| UC03 | `GET /exams/search` (`query`, `category`, `sort_by`, `lat`, `lng`, `page`, `size`) | público |
| UC04 | `GET /exams/{id}` | público |
| UC05 | `GET /clinics/{id}` | público |
| UC06 | `GET /exam-types/trending` | público |
| UC07 | `POST /exams/{id}/contacts` (devolve `whatsapp_url`) | token opcional |
| UC08 | `GET /me/savings` | token |
| UC09 | `GET /me/favorites`, `PUT`/`DELETE /me/favorites/{examTypeId}` | token |
| UC10 | `GET /clinics/{id}/reviews`, `PUT`/`GET /clinics/{id}/reviews/me` | público / token |
| UC11 | `GET`/`PUT /me`, `PUT /me/avatar` (multipart `file`) | token |
| UC12 | `PUT /me/password` | token |

Arquivos de avatar: `GET /files/avatars/{arquivo}` (caminho relativo guardado em `avatar_url`; o app monta a URL base). Swagger em `/swagger-ui.html`, contrato em `/v3/api-docs`, health em `/actuator/health`.

**Banco (9 tabelas, migrações V1 a V6):** `users`, `clinics`, `clinic_operating_hours`, `exam_types`, `exams` (oferta por clínica), `favorites`, `reviews`, `price_history`, `contact_events`. Seed: 6 clínicas, 18 tipos de exame, 31 ofertas, 5 pacientes de demonstração sem login e 21 avaliações. Exemplo de dado: "Ultrassom Abdominal Total" tem 5 ofertas de R$ 90 a R$ 140, média R$ 118.

**Documentação do back-end** em `clinics-backend/docs/`: `01-requisitos`, `02-historias-de-usuario`, `03-regras-de-negocio` (RN01 a RN36), `04-casos-de-uso`, `05-modelo-de-dados` (MER), `06-arquitetura-e-classes`, `07-referencia-da-api` (exemplos reais), `08-diagramas-de-sequencia`. README completo com os nomes da dupla. Todos os 18 diagramas Mermaid foram validados com o parser.

**Testes:** 154 passando (unidade, integração com Testcontainers, arquitetura e contrato OpenAPI). Rodar: `./mvnw test` (precisa de Docker).

**Como subir:** `cd ~/Repositorio/clinics-backend && docker compose up -d && ./mvnw spring-boot:run` (porta 8080).

### Armadilhas já encontradas (evitar repetir)

- **Spring Boot 4 / Jackson 3:** pacotes `tools.jackson.*`; `AutoConfigureMockMvc` está em `org.springframework.boot.webmvc.test.autoconfigure`. O springdoc usa Jackson 2 próprio e ignora o `SNAKE_CASE` da aplicação. Resolvido com `SnakeCaseModelConverter` (renomeia só as propriedades dos schemas; trocar a estratégia do mapper global **quebra** o próprio documento OpenAPI).
- Mensagens de erro de validação devem usar `snake_case` nos campos (`FieldNames.toSnakeCase`).
- No Mermaid de sequência, **`;` dentro de mensagem ou nota quebra o diagrama**. Trocar por vírgula ou travessão.
- `pkill -f` com padrão que aparece no próprio comando derruba o shell. Usar arquivo de PID.
- Em `HandlerExceptionResolver`, um `@ExceptionHandler(Exception.class)` sem estender `ResponseEntityExceptionHandler` transforma 404 de rota em 500.
- Testes de integração compartilham o banco; quem altera o seed deve restaurar. Avaliações de teste usam clínica criada pelo próprio teste.

## 7. App Flutter `clinics/` (Entrega 2: **não iniciado**)

Estado atual (Entrega 1): ~3.200 linhas, 6 telas visuais com **dados mockados** (`lib/features/search/data/mock_data.dart`).

- Dependências: `flutter_riverpod ^3.4.3`, `go_router ^18`, `google_fonts`, `url_launcher`.
- Estrutura: `lib/core/{router,theme,utils}` e `lib/features/{auth,search,exam,clinic,profile}` (maioria só com `presentation/`; `search` tem `data/` e `domain/`).
- Telas: login/cadastro, início/busca, drawer, resultados, detalhes do exame, perfil do usuário, ficha da clínica.
- Design: tokens em `docs/DESIGN_SYSTEM.md` (Primary `#0284C7`, Atmospheric Blue `#E0F2FE`, WhatsApp `#25D366`, canvas `#F8FAFC`; Plus Jakarta Sans + Inter; cards 16px, botões 12px, chips pill).
- Protótipo: `docs/prototype/pages/*/screen.png` (nome **Clara Saúde** no protótipo vs **Clinics** no código; padronizar).

### O que falta fazer no app (Entrega 2)

1. **Camada de dados real** (`data/`, Riverpod `AsyncNotifier`): cliente HTTP (sugestão: `dio` com interceptor de JWT), repositórios que chamam a API, DTOs com `fromJson`, tratamento do formato de erro RFC 9457 (`code`).
2. **Autenticação:** login e cadastro reais, guardar o token (sugestão `flutter_secure_storage`; a biometria é Entrega 3), redirecionamento no `go_router`, logout.
3. **Integrar as telas:** busca (com filtros e ordenação), resultados (média, economia, selo "Melhor preço", distância), detalhes (aberto agora, preparo), ficha da clínica (horários, avaliações), favoritos, avaliação, perfil (editar, senha, foto, total economizado), "Em alta" na home.
4. **Recursos do dispositivo:**
   - **GPS** (`geolocator`): enviar `lat`/`lng` na busca e nos detalhes; filtro "Mais Próximo".
   - **Voz** (`speech_to_text`): microfone da tela inicial alimenta a busca.
   - **Câmera/galeria** (`image_picker`): foto de perfil via `PUT /me/avatar`.
   - **Notificações locais** (`flutter_local_notifications`): alerta de queda de preço dos favoritos (comparar `min_price` da API com o valor guardado) e lembrete de jejum do exame.
5. **URL base da API:** emulador Android usa `http://10.0.2.2:8080`; aparelho físico usa o IP da máquina. Tornar configurável (`--dart-define`).
6. Cuidados Android: permissões de localização, microfone, câmera e notificações; `usesCleartextTraffic` para HTTP em desenvolvimento.

## 8. Documentação antiga que precisa de correção (repositório do app)

Ainda descreve Go/Fiber/GORM e a numeração antiga de casos de uso:
`AGENTS.md`, `MVP_specification.md`, `docs/ARCHITECTURE.md`, `docs/API_SPECIFICATION.md` (endpoints e campos mudaram; usar `clinics-backend/docs/07-referencia-da-api.md` como fonte), `README.md` do app (atualizar casos de uso, tecnologias, instruções) e `docs/ROADMAP_ENTREGAS.md` (usa a numeração antiga de UCs; a atual está na seção 6 e em `clinics-backend/docs/04-casos-de-uso.md`).

Também falta o **documento de casos de uso e o diagrama de classes** exigidos pela Entrega 2 no repositório do app, se o grupo preferir entregar por lá (hoje estão no back-end).

## 9. Entrega 3 (planejada, **não fazer agora**)

**Casos de uso (UC13 a UC18):** recuperar senha (`password_reset_tokens`), histórico de buscas (`search_history`), consentimento LGPD (`consents`), exportar meus dados, excluir conta (anonimiza avaliações e contatos), renovar sessão com refresh token (`refresh_tokens`). Mínimo exigido: 4 UCs e 3 tabelas.

**Bônus JWT + RBAC:** `@PreAuthorize` por papel (`PATIENT`, `CLINIC_MANAGER`, `ADMIN`), endpoint exclusivo de admin e testes de autorização. O JWT já existe. Rotas de gestão de exame exigem dono da clínica (`owner_user_id` = usuário do token), com 403 caso contrário (anti-IDOR).

**Dispositivo (+1 obrigatório):** biometria + armazenamento seguro (`local_auth`, `flutter_secure_storage`), compartilhar exame (`share_plus`), modo offline com cache (`connectivity_plus` + `drift`). Extras opcionais: geocodificação reversa do bairro (`geocoding`), lembrete no calendário.

**Deploy e docs:** gerar keystore e `.apk`/`.aab` assinado (`key.properties` fora do git); hospedar back-end e PostgreSQL (Render, Railway ou Fly.io) e apontar o app; refatorar diagramas; README completo.

**Ideias de produto se sobrar tempo:** gráfico de evolução do preço (`price_history`), "atende hoje" a partir dos horários, visão da clínica (telas 7 e 8, CRUD de exames), registro automático em `price_history` a cada mudança de preço (RN13).

## 10. Pendências imediatas, em ordem sugerida

1. **Publicar o back-end no GitHub (público).** Obrigatório pelo PDF. Depois: `git remote add origin <url>` e `git push -u origin main` em `clinics-backend`.
2. Commitar `docs/ROADMAP_ENTREGAS.md` e este arquivo no `clinics-mobile` (estão sem commit).
3. Atualizar os documentos antigos do app (seção 8).
4. **Integrar o app Flutter à API** (seção 7), começando por: cliente HTTP + login/cadastro, depois busca/detalhes, depois favoritos/avaliações/perfil, depois os 4 recursos do dispositivo.
5. Revisar o histórico de commits do app: o PDF exige commits distribuídos ao longo do desenvolvimento.
6. Preparar a apresentação de 7 minutos da Entrega 2.

## 11. Arquivos importantes

| Caminho | Para quê |
|---|---|
| `clinics-mobile/docs/avaliacao.pdf` | Requisitos da avaliação |
| `clinics-mobile/docs/ROADMAP_ENTREGAS.md` | Planejamento das entregas (numeração de UCs desatualizada) |
| `clinics-mobile/docs/DESIGN_SYSTEM.md` | Tokens de design obrigatórios |
| `clinics-mobile/docs/prototype/pages/` | Telas do protótipo (screen.png e code.html) |
| `clinics-backend/docs/07-referencia-da-api.md` | Contrato da API com exemplos reais (fonte para o app) |
| `clinics-backend/docs/03-regras-de-negocio.md` | RN01 a RN36 |
| `clinics-backend/src/main/resources/db/migration/` | Esquema e seed |
| `clinics-backend/src/test/java/br/com/clinics/TestUsers.java` | Helper para criar pacientes nos testes |

## 12. Comandos úteis

```bash
# back-end
cd ~/Repositorio/clinics-backend
docker compose up -d && ./mvnw spring-boot:run     # API em :8080
./mvnw test                                         # 154 testes
curl localhost:8080/api/v1/exams/search?query=ultrassom

# app
cd ~/Repositorio/clinics-mobile/clinics
flutter pub get && flutter analyze && flutter test
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080   # (a definir no app)
```

## 13. Registro de progresso

- **2026-10-12** · Levantamento do PDF, análise tela a tela, decisão de escopo (12 UCs, 9 tabelas, 4 recursos de dispositivo). Roadmap criado.
- **2026-10-12** · Back-end completo: docs 01 a 08, migrações V1 a V6, 12 casos de uso, OpenAPI, 154 testes, README. 49 commits em `clinics-backend`.
- **2026-10-12** · Este arquivo de contexto criado.
- **2026-10-13** · Repositórios publicados no GitHub (branch `develop`). App integrado à API: cliente `dio` com JWT, login/cadastro com sessão persistida, busca (categoria, ordenação, GPS), detalhes com contato WhatsApp (UC07), ficha da clínica com avaliações (UC10), favoritos (UC09), perfil com economia, edição, senha e foto (UC08, UC11, UC12). Recursos de dispositivo: GPS, voz, câmera/galeria e notificações locais (queda de preço e lembrete de preparo). Mocks removidos. Compila em debug com `--dart-define=API_BASE_URL`.
- **Próximo:** testar no aparelho físico, escrever testes do app, atualizar documentos antigos (seção 8) e preparar a apresentação.
