# Contexto do Projeto Clinics (handoff entre sessões)

> **Para o agente de IA que retomar este trabalho:** leia este arquivo inteiro antes de qualquer ação. Ele resume tudo que foi decidido e construído até **2026-10-13**. Complementos: `docs/ROADMAP_ENTREGAS.md`, `docs/DISTRIBUICAO.md`, `docs/IDENTIDADE_VISUAL.md` (este repositório) e a pasta `docs/` do repositório `clinics-backend` (01 a 11).
> Atualize a seção **15. Registro de progresso** ao final de cada etapa.
> **Nunca escreva neste arquivo** senhas, tokens, chaves, o IP da VPS ou o conteúdo de `.env`.

---

## 1. O projeto em uma frase

**Clinics** é um app (Android + web instalável) que compara preços de exames e consultas em clínicas de **Surubim-PE** e leva o paciente ao WhatsApp da clínica com a mensagem pronta. Trabalho da disciplina **Programação para Dispositivos Móveis**, em dupla: **Márcio Ferreira Lima** (Git: `MarcioFerreiraL`, assina como **MárcioDev**) e **Lucas Nascimento Barros**.

## 2. Requisitos da avaliação (`docs/avaliacao.pdf`)

Regras gerais: dupla, tema original, código no **GitHub público**, **muitos commits ao longo do tempo**, nomes da dupla no `README.md` e no comentário do Classroom, **o envio no Classroom é o link do último commit** (não do repositório). Descumprir qualquer item zera a nota. Cada entrega é apresentada em até 7 minutos.

| Entrega | Itens | Nota |
|---|---|---|
| **1** (feita) | Diagrama de casos de uso, README, protótipo, 6+ telas Flutter | 10 |
| **2** (praticamente pronta) | Casos de uso +4 e diagrama de classes, back-end 4+ UCs, 3+ tabelas PostgreSQL, app integrado à API, 1 recurso do dispositivo | 10 |
| **3** (planejada) | +4 UCs, +3 tabelas, app integrado, +1 recurso do dispositivo, `.apk`/`.aab` assinado, diagramas/README refatorados, **bônus** JWT + RBAC | 11 |

## 3. Escopo e decisões do usuário

- **Só a visão do paciente.** A visão da clínica (gestão de exames, papel `CLINIC_MANAGER`) foi adiada.
- **Ir além do mínimo**, com práticas profissionais (testes, pipeline, deploy, carga).
- Repositórios separados: `clinics-backend` (Spring Boot) e `clinics-mobile` (Flutter, na subpasta `clinics/`).
- Branch de trabalho nos dois: **`develop`** (é a única; o deploy sai dela).
- **Tudo da Entrega 3 fica para depois** (recuperar senha, histórico de buscas, LGPD, refresh token, RBAC, biometria, compartilhar, offline).
- Identidade visual: **2D chapado, simples, sem degradê/textura/sombra elaborada**, cores **pastel**, só o texto com alto contraste. Paleta obrigatória: **branco + o azul `#0284C7` + verde-menta**. Créditos "MárcioDev e Lucas" na abertura, login, configurações e site.
- **iPhone:** sem conta Apple Developer, então o iOS é atendido por **PWA** (versão web instalável). Um app iOS real exige Mac + conta paga (US$ 99/ano); o Flutter gera iOS, mas o build precisa de Xcode.
- **Android:** APK assinado com **chave própria** (fora do Git), servido pelo próprio site.

## 4. Preferências de trabalho do usuário (seguir sempre)

1. **Commits**: Conventional Commits **em português, curtos e objetivos**, um por unidade de trabalho, com a linha `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. Sempre commitar o que fizer (e dar push quando pedido; o usuário já pediu push várias vezes).
2. **Perguntar antes de decisões relevantes** e antes de ações destrutivas ou irreversíveis (foi assim na limpeza da VPS: levantamento, confirmação, backup, remoção).
3. **Documentação primeiro**: requisitos, regras, MER e diagramas guiam o código.
4. **Não expor nada sensível no repositório** (`.env`, chaves, IP da VPS, senhas). Só `.env.example` é versionado.
5. **A porta 8080 não pode ficar aberta para a internet.** A API só escuta em `127.0.0.1` na VPS; o acesso público é pelo Cloudflare Tunnel.
6. Código em inglês, textos ao usuário em pt-BR, JSON em `snake_case`. Responder em português, direto.
7. Verificar de verdade (testes, `curl`, capturas de tela do celular via `adb`) antes de afirmar que algo funciona; relatar falhas com honestidade.
8. Quando o usuário estiver mexendo no celular, **não** enviar toques por `adb` (atrapalha).

## 5. Ambiente local

| Item | Situação |
|---|---|
| Repositórios | `~/Repositorio/clinics/clinics-backend` e `~/Repositorio/clinics/clinics-mobile` (remotos no GitHub, usuário `MarcioFerreiraL`, ambos públicos) |
| JDK / Maven | OpenJDK **25**, wrapper `./mvnw` |
| Docker | Disponível (testes com Testcontainers, build da imagem, k6) |
| Flutter | 3.47.4 em `/snap/bin/flutter`; Android SDK em `~/Android/Sdk` (`adb`, `apksigner` em `platform-tools`/`build-tools`) |
| `gh` CLI | **Não instalado.** Status do Actions é lido pela API pública do GitHub (`curl https://api.github.com/repos/MarcioFerreiraL/<repo>/actions/runs`) |
| Chave SSH da VPS | Pasta `~/Repositorio/clinics/SSH KEYS/` (fora dos repositórios). O caminho tem **espaço**: sempre usar aspas / função shell, nunca variável sem aspas |
| Chave de assinatura Android | `~/Keystores-clinics/` (`clinics-release.jks`, `LEIA-ME.txt` com senhas e instruções dos secrets). **Fazer backup.** Local: `clinics/android/key.properties` (ignorado pelo Git) |
| Backups da limpeza da VPS | `~/Backups-vps/2026-10-13/` (bancos antigos, projetos, nginx, beszel) |
| Celular de teste | Xiaomi/Android 16, conectado por USB quando o usuário avisa; tela 1220x2712 |

## 6. Back-end `clinics-backend` (concluído, em produção)

**Stack:** Java 25, Spring Boot 4.1.1 (versão Maven sem `.RELEASE`), PostgreSQL 17, Flyway, Spring Security + JWT (HS256), BCrypt custo 10, JPA (escrita) + `JdbcClient` (consultas), springdoc, JUnit 5, Testcontainers, ArchUnit. Arquitetura hexagonal por funcionalidade (`identity`, `catalog`, `engagement`, `shared`).

**Casos de uso (13)**, base `/api/v1`, JSON `snake_case`, erros RFC 9457 com `code`:

| UC | Endpoint | Acesso |
|---|---|---|
| UC01 | `POST /auth/register` (agora exige **CPF, e-mail e nascimento**) | público |
| UC02 | `POST /auth/login` | público |
| UC03 | `GET /exams/search` (query, category, sort_by, lat/lng, **neighborhood, min_price, max_price, min_rating, best_price_only**) | público |
| UC04 | `GET /exams/{id}` | público |
| UC05 | `GET /clinics/{id}` | público |
| UC06 | `GET /exam-types/trending` | público |
| UC07 | `POST /exams/{id}/contacts` | token opcional |
| UC08 | `GET /me/savings` | token |
| UC09 | favoritos `GET/PUT/DELETE /me/favorites...` | token |
| UC10 | avaliações `/clinics/{id}/reviews...` | misto |
| UC11 | `GET/PUT /me`, `PUT /me/avatar` | token |
| UC12 | `PUT /me/password` | token |
| UC13 | `GET /neighborhoods` | público |

Importante: login e cadastro devolvem só um **resumo** do usuário; o perfil completo (CPF, e-mail, nascimento, foto) vem de `GET /me`.

**Busca por nomes populares (RN39):** tabela `exam_type_aliases` (~190 apelidos, ex.: "colesterol" para Lipidograma, "esteira" para Teste Ergométrico). Casa por apelido dentro de frases maiores. **Limitação conhecida:** termos genéricos + específicos se somam ("ecografia da barriga" devolve 7 ofertas).

**Banco:** 10 tabelas (+ `flyway_schema_history`), migrações **V1 a V9** (V7 CPF, V8 clínicas de demonstração de Surubim com nomes alterados de propósito, V9 apelidos). Seed: 6 clínicas (Clínica Santa Mariazinha, Laboratório São Zezinho, Bioclínica Diagnóstikos, Centro Médico Surubinzinho, Policlínica do Agrestão, Cardiocentro Surubim), bairros Centro, São José, Santa Rita, Bairro Novo e Cohab, 18 tipos de exame, 31 ofertas.

**Site público servido pela API:** `/` página de download (`static/index.html`), `/app/` PWA do Flutter (gerado no deploy, **não versionado**), `/docs` redireciona para o Swagger UI, `/download/clinics.apk` APK do Android (de uma pasta/volume do servidor).

**Testes: 254, todos passando** (`./mvnw test`, precisa de Docker): unidade, integração por endpoint, arquitetura, contrato OpenAPI, **modelo de dados (MER)**, **consistência do seed**, **regras de negócio**, **jornada do paciente (RF01–RF12)**, download do APK. Matriz requisito/regra para teste em `docs/10-testes-e-rastreabilidade.md`.

**Documentação (`clinics-backend/docs/`):** 01 requisitos, 02 histórias, 03 regras (RN01–RN39), 04 casos de uso, 05 modelo de dados, 06 arquitetura, 07 referência da API, 08 sequências, **09 deploy e pipeline**, **10 testes e rastreabilidade**, **11 testes de carga**.

**Arquivos de ambiente:** `.env.example` versionado; `.env` real só local e na VPS (ignorado pelo Git). `compose.yaml` = dev (banco + API pelo `Dockerfile`); `compose.prod.yaml` = produção (imagem pronta, limites de memória, Postgres ajustado, publica em `127.0.0.1`).

## 7. App Flutter `clinics-mobile/clinics/` (integrado à API)

- **Dependências principais:** `flutter_riverpod`, `go_router`, `dio`, `flutter_secure_storage`, `shared_preferences`, `geolocator`, `speech_to_text`, `image_picker`, `flutter_local_notifications`, `url_launcher`, `intl`, `google_fonts`.
- **URL da API:** padrão `https://clinics.marciodev.com` (`ApiConfig`); sobrescrever com `--dart-define-from-file=.env` (modelo em `.env.example`). Emulador Android usa `http://10.0.2.2:8080`.
- **Funcionalidades:** login/cadastro (CPF, e-mail, nascimento, máscaras de telefone/CPF/data, pt-BR), sessão persistida, busca com categoria/ordenação/**filtros** (bairro, preço, nota, melhor preço) e "Mais Próximo", **seletor de bairro** na home, busca por **voz**, detalhes (favoritar, lembrete de preparo, contato WhatsApp registrado na API), ficha da clínica com avaliações, favoritos, perfil (total economizado, editar, trocar senha, foto), **Configurações** (ícone no canto superior direito), toque no card inteiro abre o detalhe.
- **Recursos do dispositivo:** GPS, voz, câmera/galeria, notificações locais (queda de preço de favoritos e lembrete). No **navegador** as notificações não existem (o app avisa).
- **Estado de rede:** `NetworkActivityOverlay` mostra barra no topo (após 0,25 s) e aviso com o pino pulando (após 0,8 s); toda requisição tem **limite total de 25 s** (falha vira "Tentar novamente"). Telas de carregamento de marca (`ClinicsLoader`, esqueletos, splash animada).
- **Identidade:** logo = pino azul com cruz branca e selo menta (gerado por `tool/generate_logo.py`); ilustrações 2D por categoria de exame (`tool/generate_exam_art.py`, `assets/exams/`, trocáveis por fotos); avatar com a inicial do nome. Tokens em `lib/core/theme/app_colors.dart`.
- **Tela de abertura:** splash nativa só branca + animação própria do logo (cai, quica, cruz, selo, check desenhado). A saída da abertura espera a animação terminar.
- **Android:** ícone adaptativo, assinatura de release por `key.properties` (local) ou variáveis de ambiente (CI).
- **Web (PWA):** pasta `web/` com manifesto e ícones; build com `--base-href /app/`.
- **Testes:** `flutter test` (14+ testes: máscaras, auth, exceções de API, indicador de rede, card de local, widget de login). `flutter analyze` limpo.

## 8. Infra e produção

**Domínio:** `https://clinics.marciodev.com` (Cloudflare Tunnel; o `cloudflared` da VPS é **gerenciado pelo painel**, usa token; a rota Public Hostname aponta para `localhost:8080`).

**VPS (Oracle, Ubuntu 22.04, 2 CPUs, ~1 GB RAM, 7 GB swap):** foi **limpa** a pedido do usuário (outros projetos removidos, com backup antes). Hoje roda **só** a API + PostgreSQL em Docker (`/opt/clinics-backend`), mais `cloudflared`, SSH e Docker. Firewall (ufw) **só com a porta 22 aberta**. Ajustes: API 600 MB (JVM serial GC, heap 65%), Postgres 200 MB (parâmetros afinados), pool 10, Tomcat 100 threads, logs rotacionados, `vm.swappiness=10`. Mantidos de propósito: agente da Oracle e `iscsid` (desligar pode afetar o disco). Segredos de produção só em `/opt/clinics-backend/.env` na VPS (gerados aleatoriamente no primeiro deploy).

**Pipelines (GitHub Actions):**
- `clinics-backend/.github/workflows/ci-cd.yml`: testes, build da imagem e **deploy automático** em push na `develop` (gera o PWA a partir do repo do app, constrói a imagem, envia por SSH, sobe, roda smoke test). Secrets usados: `VPS_HOST`, `VPS_USER`, `VPS_SSH_KEY` (já criados pelo usuário).
- `clinics-backend/.github/workflows/performance.yml`: k6 sob demanda e toda segunda.
- `clinics-mobile/.github/workflows/ci.yml`: analisar, testar, gerar APK de debug; job `release` publica o **APK assinado** na release fixa `app-latest` **somente se** os secrets `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` existirem (**ainda não criados pelo usuário**; sem eles só emite aviso).

**Distribuição do app:** o botão "Baixar APK" do site baixa de `/download/clinics.apk` (arquivo na VPS). O deploy tenta atualizar esse arquivo a partir da release `app-latest`; sem release, mantém o que está lá. Para publicar um APK à mão: `clinics-backend/deploy/publish-apk.sh`. O APK atual publicado é o assinado com a chave própria, com as correções até 2026-10-13.

**Desempenho medido** (ambiente espelho da VPS + produção real, `clinics-backend/docs/11-testes-de-carga.md`): busca p95 de milissegundos, ~1.600 req/s de pico sem erro, memória estável; em produção via Cloudflare mediana de 54 ms e p95 de 227 ms na busca (RNF03 atendido). Threads virtuais foram testadas e **não ajudaram** (não ligadas). Cadastro/login (BCrypt) é o gargalo esperado e não foi saturado.

## 9. Armadilhas já encontradas (evitar repetir)

- **Spring Boot 4 / Jackson 3:** pacotes `tools.jackson.*`; springdoc ignora `SNAKE_CASE` do mapper global (resolvido com `SnakeCaseModelConverter`). Mermaid de sequência: `;` em mensagem quebra o diagrama.
- **`pkill -f` com padrão presente no próprio comando derruba o shell.** Usar arquivo de PID ou `kill $(...)`.
- **Docker ignora o ufw ao publicar portas.** Sempre `127.0.0.1:8080:8080`, nunca `8080:8080`. (A 8080 já esteve acessível de fora por isso e foi corrigida.)
- **Caminho da chave SSH tem espaço:** usar aspas; `$R` com a chave dentro quebra.
- **A imagem base do Docker não tem `curl`:** o `Dockerfile` instala `curl` para o healthcheck.
- **VPS pequena:** não compilar Maven nela; a imagem é construída fora (CI/máquina local) e enviada. A primeira chamada de `/v3/api-docs` a frio pode passar de 10 s.
- **Flutter:** `StateProvider` não existe no Riverpod 3 (usar `Notifier`); `dart format` reflui o código e quebra replace de texto em scripts (conferir se a edição foi aplicada, pois um `fromJson` sem o CPF passou despercebido por isso); widgets animados sempre presentes (ex.: barra de progresso invisível) impedem `pumpAndSettle` e gastam bateria: só construir enquanto visíveis; mexer em provider durante o build exige `Future.microtask`.
- **`flutter create --platforms web` altera `analysis_options.yaml` e `.metadata`:** conferir o diff.
- **Login/cadastro só devolvem resumo:** o app precisa chamar `GET /me` depois.
- **APK de debug x release:** assinaturas diferentes; trocar exige `adb uninstall` (apaga só dados locais).
- **Workflow do GitHub:** `defaults.run.working-directory` quebra passos que rodam antes do checkout; secrets não podem ser usados direto em `if` (usar `env`); nomes de passo com `:` precisam de aspas.
- **Testes de integração compartilham o banco:** quem grava deve ser `@Transactional` (rollback) ou restaurar o estado.
- **Cloudflare 530 / erro 1033:** o domínio fica fora do ar quando o `cloudflared` da VPS não registra o túnel. Em 15/10 a causa foi **"Unauthorized: Invalid tunnel secret"** (o segredo do túnel foi trocado no painel da Cloudflare; o token em `/etc/cloudflared/token` na VPS, intacto desde 19/08, ficou inválido). Em QUIC o log só mostra "control stream failure"; para ver a mensagem real, rodar um conector temporário com `--protocol http2`. Correção: gerar o token novo no painel e gravar em `/etc/cloudflared/token` (sem expô-lo no chat), depois `sudo systemctl restart cloudflared`. A API e a VPS estavam saudáveis o tempo todo.
- **Chromium headless sem GPU é lento** para o Flutter web; não serve para ver o app web completo.

## 10. Documentação antiga que ainda precisa de correção (repositório do app)

Ainda descrevem Go/Fiber/GORM e a numeração antiga de casos de uso: `AGENTS.md`, `MVP_specification.md`, `docs/ARCHITECTURE.md`, `docs/API_SPECIFICATION.md` (usar `clinics-backend/docs/07-referencia-da-api.md` como fonte), `README.md` do app (casos de uso, tecnologias) e `docs/ROADMAP_ENTREGAS.md` (numeração antiga de UCs). Também falta o **documento de casos de uso e o diagrama de classes** no repositório do app, se o grupo preferir entregar por lá (hoje estão no back-end).

## 11. Entrega 3 (planejada, **não fazer agora**)

A numeração dos UCs mudou (UC13 hoje é "bairros"). Pendentes: recuperar senha (`password_reset_tokens`), histórico de buscas (`search_history`), consentimento LGPD (`consents`), exportar/excluir dados, refresh token (`refresh_tokens`), **bônus JWT + RBAC** (`@PreAuthorize`, endpoint de admin, anti-IDOR), biometria, compartilhar, modo offline, gráfico de `price_history`, visão da clínica. **APK assinado já existe** (item de 2 pontos); falta o `.aab` se for exigido.

## 12. Pendências imediatas, em ordem sugerida

1. **Usuário criar os 4 secrets `ANDROID_KEYSTORE_*` no repositório do app** (valores em `~/Keystores-clinics/LEIA-ME.txt`) e **fazer backup de `~/Keystores-clinics/`**. Depois disso o CI publica o APK na release `app-latest`.
2. **Build novo no celular** (o instalado é de antes dos cards de exame refeitos e do limite de tempo de requisição): pedir ao usuário para conectar e rodar `flutter build apk --release --dart-define=API_BASE_URL=https://clinics.marciodev.com`, `adb install`.
3. Oferecido e **aguardando resposta**: publicar **APK só de 64 bits** (cerca de 1/3 do tamanho, download bem mais rápido; celulares muito antigos não instalariam).
4. Atualizar os documentos antigos do app (seção 10) e escrever o diagrama de classes/casos de uso se necessário.
5. Mais testes automáticos no app e, se houver tempo, teste de carga com muitos cadastros (BCrypt).
6. Opcional: desligar `/swagger-ui` e `/v3/api-docs` em produção (o usuário pediu a OpenAPI visível, então por ora ficam); HTTPS já vem do Cloudflare.
7. Preparar a apresentação de 7 minutos (roteiro: problema, demo no celular, arquitetura, testes/pipeline/deploy, carga).
8. O IP da VPS aparece em um commit antigo do histórico do back-end (já removido dos arquivos); reescrever histórico só se o usuário pedir.

## 13. Arquivos importantes

| Caminho | Para quê |
|---|---|
| `clinics-mobile/docs/avaliacao.pdf` | Requisitos da avaliação |
| `clinics-mobile/docs/DISTRIBUICAO.md` | APK, PWA e chave de assinatura |
| `clinics-mobile/docs/IDENTIDADE_VISUAL.md` | Paleta, logo, movimento |
| `clinics-mobile/clinics/lib/core/` | Rede (`api_client`, `network_activity`), tema, widgets de marca |
| `clinics-backend/docs/` | Documentação 01–11 |
| `clinics-backend/deploy/` | `deploy.sh`, `build-web.sh`, `publish-apk.sh`, `smoke-test.sh` |
| `clinics-backend/loadtest/` | Cenários k6 e ambiente espelho |
| `clinics-backend/src/main/resources/db/migration/` | Esquema e seed (V1–V9) |
| `clinics-backend/src/main/resources/static/index.html` | Página de download do site |

## 14. Comandos úteis

```bash
# back-end (dev)
cd ~/Repositorio/clinics/clinics-backend
cp .env.example .env && docker compose up -d postgres && set -a && . ./.env && set +a && ./mvnw spring-boot:run
./mvnw test                                   # 254 testes (precisa de Docker)
deploy/smoke-test.sh https://clinics.marciodev.com
loadtest/run.sh load                          # k6 (suba antes o loadtest/compose.loadtest.yaml)

# app
cd ~/Repositorio/clinics/clinics-mobile/clinics
flutter pub get && flutter analyze && flutter test
flutter run --dart-define-from-file=.env
flutter build apk --release --dart-define=API_BASE_URL=https://clinics.marciodev.com
adb install -r build/app/outputs/flutter-apk/app-release.apk      # PATH: ~/Android/Sdk/platform-tools

# deploy manual (normalmente o pipeline faz)
cd ~/Repositorio/clinics/clinics-backend && deploy/build-web.sh && deploy/deploy.sh usuario@IP "caminho/da/chave"

# status do CI sem gh
curl -s https://api.github.com/repos/MarcioFerreiraL/clinics-backend/actions/runs?per_page=1
```

## 15. Registro de progresso

- **2026-10-12** · Levantamento do PDF, escopo, back-end completo (12 UCs, 9 tabelas, 154 testes), docs 01 a 08, roadmap, primeiro arquivo de contexto.
- **2026-10-13** · Repositórios publicados no GitHub. App integrado à API (auth, busca, detalhes, clínica, favoritos, perfil) e 4 recursos de dispositivo. CPF no cadastro, filtros, bairros (UC13), busca por nomes populares, clínicas de Surubim no seed.
- **2026-10-13** · Identidade visual pastel 2D (logo, ícone, splash animada, carregamento, avatar com inicial), configurações, indicador global de requisições, logo maior.
- **2026-10-13** · Docker + compose, deploy na VPS Oracle, Cloudflare Tunnel (`clinics.marciodev.com`), limpeza da VPS com backup, firewall só com SSH, ajuste de desempenho, pipeline CI/CD (deploy automático validado), smoke test pós-deploy.
- **2026-10-13** · 254 testes no back-end (MER, regras, seed, jornada), testes de carga k6 (smoke, load, stress, spike, soak, latência em produção), docs 09 a 11.
- **2026-10-13** · Site de download na raiz, PWA para iPhone em `/app/`, APK assinado com chave própria servido em `/download/clinics.apk`, `/docs` para a OpenAPI.
- **2026-10-13** · Correções: perfil não mostrava CPF/e-mail/nascimento (resumo do login e `fromJson` sem CPF), requisições sem limite de tempo; cards de exame refeitos (local de atendimento, ilustração no preço, botão "Ver mais").
- **2026-10-15** · Domínio fora do ar (Cloudflare 530/1033). Diagnóstico: API e VPS ok; túnel rejeitado com "Invalid tunnel secret" desde 13/10 ~19h UTC. Aguardando o usuário atualizar o token do túnel.
- **Próximo:** secrets do keystore no GitHub, build novo no celular, decidir APK 64 bits, atualizar docs antigas e preparar a apresentação.
