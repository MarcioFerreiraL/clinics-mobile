# Distribuição do app

O site `https://clinics.marciodev.com/` é a página de download. De lá o usuário escolhe:

| Plataforma | Como chega ao usuário |
|---|---|
| **Android** | APK assinado, publicado pelo CI na release fixa `app-latest` do GitHub. O botão do site aponta sempre para a versão mais nova. |
| **iPhone / iPad** | App web instalável (PWA) em `/app/`: abrir no Safari → Compartilhar → Adicionar à Tela de Início. |
| **Computador** | O mesmo app web em `/app/`. |

## Por que o iPhone usa PWA

O Flutter gera app iOS, mas o build exige um Mac com Xcode e a Apple só permite instalar apps de fora da App Store com conta Apple Developer (US$ 99/ano). Sem a conta, o PWA é o caminho. Diferenças da versão web: sem alertas de queda de preço nem lembrete de preparo (notificações locais), e o reconhecimento de voz depende do navegador.

## Android: chave de assinatura

A chave fica **fora do Git** (`~/Keystores-clinics/`, com `LEIA-ME.txt`). **Faça backup:** sem ela não é possível atualizar o app já instalado nos aparelhos.

Para o CI assinar o APK, crie estes secrets no repositório do app (Settings → Secrets and variables → Actions):

| Secret | Valor |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | conteúdo de `clinics-release.jks.base64` |
| `ANDROID_KEYSTORE_PASSWORD` | senha do keystore |
| `ANDROID_KEY_ALIAS` | `clinics` |
| `ANDROID_KEY_PASSWORD` | senha da chave |

Sem eles o job de release só emite um aviso. Build local assinado: coloque as credenciais em `android/key.properties` (ignorado pelo Git) e rode `flutter build apk --release --dart-define-from-file=.env`.

## App web (PWA)

O back-end serve o app web. O deploy do back-end compila o Flutter web (`deploy/build-web.sh`) e embute o resultado na imagem. A URL da API é a mesma origem, então não há CORS. O manifesto e os ícones ficam em `clinics/web/`.
