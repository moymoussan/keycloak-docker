<!DOCTYPE html>
<html>
<head>
    <title>Verificación segura - WhatsApp</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <script src="${url.resourcesCommonPath}/node_modules/alpinejs/dist/cdn.min.js" defer></script>
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
            margin-top: 1rem;
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
        }
        
        .description {
            font-size: 16px;
            color: #a0a0a0;
            line-height: 1.5;
            margin-bottom: 3rem;
            max-width: 300px;
        }
        
        /* Botón con estilos idénticos a los de Keycloak pero personalizado */
        .webauthn-button {
            background: #25D366 !important;
            color: #000000 !important;
            border: none !important;
            padding: 16px 32px !important;
            border-radius: 8px !important;
            font-weight: 600 !important;
            font-size: 16px !important;
            width: 300px !important;
            max-width: 100% !important;
            cursor: pointer !important;
            margin: 0 auto !important;
            display: block !important;
            text-align: center !important;
            text-decoration: none !important;
            transition: background-color 0.2s !important;
        }
        
        .webauthn-button:hover {
            background: #20BA5A !important;
        }
        
        .hidden {
            display: none;
        }
        
        [x-cloak] {
            display: none !important;
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
        
        <div x-data="webAuthnAuthenticate" x-cloak>
            <form action="${url.loginAction}" method="post" x-ref="webAuthnForm">
                <input name="authenticatorData" type="hidden" x-ref="authenticatorDataInput" />
                <input name="clientDataJSON" type="hidden" x-ref="clientDataJSONInput" />
                <input name="credentialId" type="hidden" x-ref="credentialIdInput" />
                <input name="error" type="hidden" x-ref="errorInput" />
                <input name="signature" type="hidden" x-ref="signatureInput" />
                <input name="userHandle" type="hidden" x-ref="userHandleInput" />
            </form>
            
            <#if authenticators??>
                <form x-ref="authnSelectForm">
                    <#list authenticators.authenticators as authenticator>
                        <input value="${authenticator.credentialId}" type="hidden" />
                    </#list>
                </form>
            </#if>
            
            <!-- Botón que se renderizará siempre -->
            <button class="webauthn-button" x-on:click="webAuthnAuthenticate()" type="button">
                Continuar
            </button>
        </div>
    </div>

    <script>
        // Inicialización de Alpine.js con la funcionalidad completa
        document.addEventListener('alpine:init', () => {
            Alpine.store('webAuthnAuthenticate', {
                challenge: '${challenge}',
                createTimeout: '${createTimeout}',
                isUserIdentified: '${isUserIdentified}',
                rpId: '${rpId}',
                unsupportedBrowserText: '${msg("webauthn-unsupported-browser-text")?no_esc}',
                userVerification: '${userVerification}',
            });
            
            // Definir el componente Alpine
            Alpine.data('webAuthnAuthenticate', () => ({
                init() {
                    console.log('WebAuthn component initialized');
                },
                
                webAuthnAuthenticate() {
                    console.log('Iniciando autenticación WebAuthn');
                    // La función real está en webAuthnAuthenticate.js
                    if (typeof window.webAuthnAuthenticate === 'function') {
                        window.webAuthnAuthenticate();
                    } else {
                        // Fallback
                        this.$refs.webAuthnForm.submit();
                    }
                }
            }));
        });

        // Fallback por si Alpine.js no carga
        setTimeout(() => {
            if (typeof Alpine === 'undefined') {
                console.log('Alpine.js no cargó, usando fallback');
                const buttons = document.querySelectorAll('.webauthn-button');
                buttons.forEach(button => {
                    button.onclick = () => {
                        document.querySelector('form[x-ref="webAuthnForm"]').submit();
                    };
                });
            }
        }, 1000);
    </script>
</body>
</html>