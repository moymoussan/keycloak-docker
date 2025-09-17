<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <title>Verificación segura</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <link rel="stylesheet" href="${url.resourcesPath}/css/custom.css" />
</head>
<body class="bg-black text-white flex items-center justify-center min-h-screen">
  <div class="max-w-sm w-full text-center p-6">
    <img src="${url.resourcesPath}/img/logo-nonocard.svg" alt="nonocard" class="mx-auto mb-6" />

    <h1 class="text-xl font-bold mb-2">Verificación segura 🔐</h1>
    <p class="text-sm text-white/80 mb-6">
      Confirma tu identidad para autorizar la operación solicitada en WhatsApp.
    </p>

    <img src="${url.resourcesPath}/img/facial-icon.svg" alt="FaceID" class="mx-auto mb-6 h-20" />

    <form action="${url.loginAction}" method="post" x-data="webAuthnAuthenticate" x-ref="webAuthnForm">
      <input name="authenticatorData" type="hidden" x-ref="authenticatorDataInput" />
      <input name="clientDataJSON" type="hidden" x-ref="clientDataJSONInput" />
      <input name="credentialId" type="hidden" x-ref="credentialIdInput" />
      <input name="error" type="hidden" x-ref="errorInput" />
      <input name="signature" type="hidden" x-ref="signatureInput" />
      <input name="userHandle" type="hidden" x-ref="userHandleInput" />

      <button
        type="submit"
        class="w-full bg-lime-500 hover:bg-lime-600 text-black font-medium py-2 rounded-lg"
        @click.prevent="authenticate"
      >
        Continuar
      </button>
    </form>
  </div>

  <script>
    document.addEventListener('alpine:init', () => {
      Alpine.store('webAuthnAuthenticate', {
        challenge: '${challenge}',
        createTimeout: '${createTimeout}',
        isUserIdentified: '${isUserIdentified}',
        rpId: '${rpId}',
        unsupportedBrowserText: '${msg("webauthn-unsupported-browser-text")?no_esc}',
        userVerification: '${userVerification}',
      })
    })
  </script>

  <script src="${url.resourcesPath}/js/webAuthnAuthenticate.js"></script>
</body>
</html>
