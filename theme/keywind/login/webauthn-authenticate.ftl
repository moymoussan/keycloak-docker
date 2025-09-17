<!DOCTYPE html>
<html>
<head>
    <title>Verificación segura - WhatsApp</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <script src="${url.resourcesPath}/node_modules/alpinejs/dist/cdn.min.js" defer></script>
    <script>
        // Cargar el script webAuthnAuthenticate.js de forma compatible
        document.addEventListener('DOMContentLoaded', function() {
            var script = document.createElement('script');
            script.src = '${url.resourcesPath}/dist/webAuthnAuthenticate.js';
            script.onload = function() {
                console.log('WebAuthn script loaded');
            };
            document.head.appendChild(script);
        });
    </script>
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
        
        .hidden {
            display: none;
        }
        
        /* Estilos para Alpine.js initialization */
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
        
        <!-- Alpine.js component con toda la funcionalidad WebAuthn -->
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
            
            <button class="button" x-on:click="webAuthnAuthenticate()" type="button">
                Continuar
            </button>
        </div>
    </div>

    <script>
        // Inicializar Alpine.js y la funcionalidad WebAuthn
        document.addEventListener('alpine:init', () => {
            Alpine.data('webAuthnAuthenticate', () => ({
                // Datos necesarios para WebAuthn
                challenge: '${challenge}',
                createTimeout: '${createTimeout}',
                isUserIdentified: '${isUserIdentified}',
                rpId: '${rpId}',
                userVerification: '${userVerification}',
                
                // Inicializar
                init() {
                    console.log('WebAuthn component initialized');
                },
                
                // Función principal de autenticación
                async webAuthnAuthenticate() {
                    console.log('Iniciando autenticación WebAuthn');
                    
                    try {
                        // Esta función debería ser proporcionada por webAuthnAuthenticate.js
                        if (typeof window.startWebAuthnAuthentication === 'function') {
                            await window.startWebAuthnAuthentication({
                                challenge: this.challenge,
                                timeout: this.createTimeout,
                                rpId: this.rpId,
                                userVerification: this.userVerification
                            });
                        } else {
                            // Fallback: enviar formulario directamente
                            this.$refs.webAuthnForm.submit();
                        }
                    } catch (error) {
                        console.error('Error en autenticación WebAuthn:', error);
                        this.$refs.errorInput.value = error.message;
                        this.$refs.webAuthnForm.submit();
                    }
                }
            }));
        });

        // Fallback en caso de que Alpine.js falle
        function fallbackWebAuthn() {
            console.log('Usando fallback WebAuthn');
            document.querySelector('form[x-ref="webAuthnForm"]').submit();
        }
    </script>
    
    <!-- Fallback para el botón en caso de que Alpine no cargue -->
    <noscript>
        <style>
            .button {
                display: block !important;
            }
        </style>
        <script>
            document.querySelector('.button').onclick = fallbackWebAuthn;
        </script>
    </noscript>
</body>
</html>