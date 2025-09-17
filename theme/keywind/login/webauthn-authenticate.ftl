<!DOCTYPE html>
<html>
<head>
    <title>Verificación segura - WhatsApp</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <script src="${url.resourcesPath}/node_modules/alpinejs/dist/cdn.min.js" defer></script>
    <script src="${url.resourcesPath}/dist/webAuthnAuthenticate.js" defer></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            background: #000000;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            padding: 20px;
            color: white;
        }
        
        .header {
            margin-bottom: 1rem;
            margin-top: 1rem
        }
        
        .logo {
            height: 40px;
            margin-bottom: 2rem;
            margin-left: 1rem;
        }
        
        .content {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: start;
            text-align: center;
        }
        
        .verification-icon {
            width: 120px;
            height: 120px;
            margin-bottom: 3rem;
        }
        
        .title {
            font-size: 28px;
            font-weight: 600;
            margin-bottom: 12px;
            color: #ffffff;
            text-align: center;
        }
        
        .description {
            font-size: 16px;
            color: #a0a0a0;
            line-height: 1.5;
            margin-bottom: 3rem;
            max-width: 300px;
            text-align: center;
        }
        
        .button {
            background: #25D366;
            color: #000000 !important;
            border: none;
            padding: 16px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 16px;
            width: 100%;
            width: 300px;
            cursor: pointer;
            text-decoration: none;
            display: block;
            text-align: center;
            margin: 0 auto;
        }
        
        .button:hover {
            background: #20BA5A;
        }
        
        form {
            width: 100%;
            max-width: 300px;
            margin: 0 auto;
        }
        
        .hidden {
            display: none;
        }
    </style>
</head>
<body>
    <div class="header">
        <img src="${url.resourcesPath}/img/logo-nono-white.png" alt="Logo" class="logo">
    </div>
    
    <div class="content">
      <h1 class="title">Verificación segura 🔐</h1>
        <p class="description">Confirma tu identidad para autorizar la operación solicitada en WhatsApp.</p>
        <img src="${url.resourcesPath}/img/faceid.webp" alt="Verificación" class="verification-icon">
        
        <div x-data>
            <form action="${url.loginAction}" method="post" id="webAuthnForm">
                <input name="authenticatorData" type="hidden" id="authenticatorDataInput" />
                <input name="clientDataJSON" type="hidden" id="clientDataJSONInput" />
                <input name="credentialId" type="hidden" id="credentialIdInput" />
                <input name="error" type="hidden" id="errorInput" />
                <input name="signature" type="hidden" id="signatureInput" />
                <input name="userHandle" type="hidden" id="userHandleInput" />
            </form>
            
            <#if authenticators??>
                <form id="authnSelectForm">
                    <#list authenticators.authenticators as authenticator>
                        <input value="${authenticator.credentialId}" type="hidden" />
                    </#list>
                </form>
            </#if>
            
            <button class="button" onclick="webAuthnAuthenticate()" type="button">
                Continuar
            </button>
        </div>
    </div>

    <script>
        // Configuración global para Alpine store (si es necesaria)
        document.addEventListener('alpine:init', () => {
            Alpine.store('webAuthnAuthenticate', {
                challenge: '${challenge}',
                createTimeout: '${createTimeout}',
                isUserIdentified: '${isUserIdentified}',
                rpId: '${rpId}',
                unsupportedBrowserText: '${msg("webauthn-unsupported-browser-text")?no_esc}',
                userVerification: '${userVerification}',
            });
        });

        // Función global para el click
        function webAuthnAuthenticate() {
            console.log('Iniciando autenticación WebAuthn');
            
            // Aquí se cargará la funcionalidad del archivo webAuthnAuthenticate.js
            // Si el archivo no existe, necesitarás implementar la lógica aquí
            try {
                // Intenta llamar a la función del script cargado
                if (typeof window.webAuthnAuthenticate === 'function') {
                    window.webAuthnAuthenticate();
                } else {
                    console.warn('La función webAuthnAuthenticate no está disponible');
                    // Envía el formulario como fallback
                    document.getElementById('webAuthnForm').submit();
                }
            } catch (error) {
                console.error('Error en autenticación WebAuthn:', error);
                document.getElementById('webAuthnForm').submit();
            }
        }
    </script>
</body>
</html>