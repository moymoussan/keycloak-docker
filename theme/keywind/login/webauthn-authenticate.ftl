<!DOCTYPE html>
<html>
<head>
    <title>Verificación segura - WhatsApp</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
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
        
        <div>
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
            
            <button class="webauthn-button" onclick="handleWebAuthn()" type="button">
                Continuar
            </button>
        </div>
    </div>

    <script>
        // Implementación directa de la funcionalidad WebAuthn
        function handleWebAuthn() {
            console.log('Iniciando autenticación WebAuthn');
            
            // Datos de configuración desde el servidor
            const webAuthnConfig = {
                challenge: '${challenge}',
                timeout: '${createTimeout}',
                rpId: '${rpId}',
                userVerification: '${userVerification}'
            };
            
            // Intentar usar la API WebAuthn directamente
            if (navigator.credentials && navigator.credentials.get) {
                try {
                    const publicKeyCredentialRequestOptions = {
                        challenge: Uint8Array.from(atob(webAuthnConfig.challenge), c => c.charCodeAt(0)),
                        allowCredentials: [
                            <#if authenticators??>
                                <#list authenticators.authenticators as authenticator>
                                {
                                    id: Uint8Array.from(atob('${authenticator.credentialId}'), c => c.charCodeAt(0)),
                                    type: 'public-key'
                                }<#if authenticator?has_next>,</#if>
                                </#list>
                            </#if>
                        ],
                        timeout: parseInt(webAuthnConfig.timeout || 60000),
                        userVerification: webAuthnConfig.userVerification || 'preferred'
                    };
                    
                    navigator.credentials.get({
                        publicKey: publicKeyCredentialRequestOptions
                    }).then(assertion => {
                        // Convertir la respuesta a base64
                        const authData = new Uint8Array(assertion.response.authenticatorData);
                        const clientDataJSON = new Uint8Array(assertion.response.clientDataJSON);
                        const signature = new Uint8Array(assertion.response.signature);
                        const userHandle = assertion.response.userHandle ? 
                            new Uint8Array(assertion.response.userHandle) : new Uint8Array(0);
                        
                        // Llenar los campos del formulario
                        document.getElementById('authenticatorDataInput').value = 
                            btoa(String.fromCharCode.apply(null, authData));
                        document.getElementById('clientDataJSONInput').value = 
                            btoa(String.fromCharCode.apply(null, clientDataJSON));
                        document.getElementById('credentialIdInput').value = 
                            btoa(String.fromCharCode.apply(null, new Uint8Array(assertion.rawId)));
                        document.getElementById('signatureInput').value = 
                            btoa(String.fromCharCode.apply(null, signature));
                        document.getElementById('userHandleInput').value = 
                            btoa(String.fromCharCode.apply(null, userHandle));
                        
                        // Enviar formulario
                        document.getElementById('webAuthnForm').submit();
                    }).catch(error => {
                        console.error('Error en WebAuthn:', error);
                        document.getElementById('errorInput').value = error.message;
                        document.getElementById('webAuthnForm').submit();
                    });
                    
                } catch (error) {
                    console.error('Error configurando WebAuthn:', error);
                    document.getElementById('errorInput').value = error.message;
                    document.getElementById('webAuthnForm').submit();
                }
            } else {
                // Navegador no compatible
                const errorMsg = 'WebAuthn no soportado en este navegador';
                console.warn(errorMsg);
                document.getElementById('errorInput').value = errorMsg;
                document.getElementById('webAuthnForm').submit();
            }
        }

        // Auto-iniciar la autenticación después de un breve delay
        setTimeout(() => {
            // Opcional: auto-iniciar la autenticación
            // handleWebAuthn();
        }, 100);
    </script>
</body>
</html>