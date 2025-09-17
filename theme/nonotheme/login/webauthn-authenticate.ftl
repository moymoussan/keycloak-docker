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
            background: #25D366;
            color: #000000;
            border: none;
            padding: 16px 32px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 16px;
            width: 300px;
            max-width: 100%;
            cursor: pointer;
            margin: 0 auto;
            display: block;
            text-align: center;
            transition: background-color 0.2s;
        }
        
        .webauthn-button:hover {
            background: #20BA5A;
        }
        
        .error-message {
            color: #ff4444;
            margin-top: 1rem;
            display: none;
        }
        
        .loading {
            display: none;
            margin-top: 1rem;
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
        
        <form action="${url.loginAction}" method="post" id="webAuthnForm">
            <input name="authenticatorData" type="hidden" id="authenticatorDataInput" />
            <input name="clientDataJSON" type="hidden" id="clientDataJSONInput" />
            <input name="credentialId" type="hidden" id="credentialIdInput" />
            <input name="error" type="hidden" id="errorInput" />
            <input name="signature" type="hidden" id="signatureInput" />
            <input name="userHandle" type="hidden" id="userHandleInput" />
        </form>
        
        <button class="webauthn-button" onclick="startWebAuthnAuthentication()" type="button" id="authButton">
            Usar Passkey
        </button>
        
        <div class="loading" id="loading">
            <p>Esperando autenticación biométrica...</p>
        </div>
        
        <div class="error-message" id="errorMessage"></div>
    </div>

    <script>
        // Configuración desde el servidor
        const webAuthnConfig = {
            challenge: '${challenge}',
            timeout: '${createTimeout}' || 60000,
            rpId: '${rpId}',
            userVerification: '${userVerification}' || 'preferred'
        };

        // Credenciales disponibles
        const allowCredentials = [
            <#if authenticators??>
                <#list authenticators.authenticators as authenticator>
                {
                    id: base64ToArray('${authenticator.credentialId}'),
                    type: 'public-key'
                }<#if authenticator?has_next>,</#if>
                </#list>
            </#if>
        ];

        function base64ToArray(base64) {
            const binaryString = atob(base64);
            const bytes = new Uint8Array(binaryString.length);
            for (let i = 0; i < binaryString.length; i++) {
                bytes[i] = binaryString.charCodeAt(i);
            }
            return bytes;
        }

        function arrayToBase64(array) {
            return btoa(String.fromCharCode.apply(null, array));
        }

        async function startWebAuthnAuthentication() {
            const authButton = document.getElementById('authButton');
            const loading = document.getElementById('loading');
            const errorMessage = document.getElementById('errorMessage');
            
            authButton.style.display = 'none';
            loading.style.display = 'block';
            errorMessage.style.display = 'none';

            try {
                if (!navigator.credentials || !navigator.credentials.get) {
                    throw new Error('Tu navegador no soporta Passkeys');
                }

                const publicKey = {
                    challenge: base64ToArray(webAuthnConfig.challenge),
                    allowCredentials: allowCredentials,
                    timeout: parseInt(webAuthnConfig.timeout),
                    userVerification: webAuthnConfig.userVerification
                };

                const assertion = await navigator.credentials.get({ publicKey });
                
                // Preparar datos para enviar al servidor
                document.getElementById('authenticatorDataInput').value = 
                    arrayToBase64(new Uint8Array(assertion.response.authenticatorData));
                document.getElementById('clientDataJSONInput').value = 
                    arrayToBase64(new Uint8Array(assertion.response.clientDataJSON));
                document.getElementById('credentialIdInput').value = 
                    arrayToBase64(new Uint8Array(assertion.rawId));
                document.getElementById('signatureInput').value = 
                    arrayToBase64(new Uint8Array(assertion.response.signature));
                
                if (assertion.response.userHandle) {
                    document.getElementById('userHandleInput').value = 
                        arrayToBase64(new Uint8Array(assertion.response.userHandle));
                }

                // Enviar formulario
                document.getElementById('webAuthnForm').submit();

            } catch (error) {
                console.error('Error en autenticación:', error);
                errorMessage.textContent = this.getErrorMessage(error);
                errorMessage.style.display = 'block';
                loading.style.display = 'none';
                authButton.style.display = 'block';
            }
        }

        function getErrorMessage(error) {
            if (error.name === 'NotAllowedError') {
                return 'Autenticación cancelada por el usuario';
            } else if (error.name === 'NotSupportedError') {
                return 'Passkeys no soportado en este dispositivo';
            } else if (error.name === 'SecurityError') {
                return 'Error de seguridad. Asegúrate de usar HTTPS';
            }
            return 'Error en la autenticación: ' + error.message;
        }

        // Auto-iniciar si está configurado
        <#if autoAuthenticate?? && autoAuthenticate>
        setTimeout(startWebAuthnAuthentication, 100);
        </#if>
    </script>
</body>
</html>