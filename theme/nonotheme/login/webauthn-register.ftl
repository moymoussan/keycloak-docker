<!DOCTYPE html>
<html>
<head>
    <title>Registro con Passkey - WhatsApp</title>
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
        
        .user-info {
            margin-bottom: 2rem;
        }
    </style>
</head>
<body>
    <div class="header">
        <img src="${url.resourcesPath}/img/logo-nono-white.png" alt="Logo" class="logo">
    </div>
    
    <div class="content">
        <h1 class="title">Registrar Passkey 🔐</h1>
        <p class="description">Configura tu huella digital o reconocimiento facial para acceder de forma segura.</p>
        
        <div class="user-info">
            <p>Usuario: <strong>${username!''}</strong></p>
        </div>
        
        <img src="${url.resourcesPath}/img/faceid.webp" alt="Registro" class="verification-icon">
        
        <form action="${url.loginAction}" method="post" id="webAuthnForm">
            <input name="attestationObject" type="hidden" id="attestationObjectInput" />
            <input name="clientDataJSON" type="hidden" id="clientDataJSONInput" />
            <input name="credentialId" type="hidden" id="credentialIdInput" />
            <input name="error" type="hidden" id="errorInput" />
            <input name="publicKey" type="hidden" id="publicKeyInput" />
        </form>
        
        <button class="webauthn-button" onclick="startWebAuthnRegistration()" type="button" id="registerButton">
            Registrar Passkey
        </button>
        
        <div class="loading" id="loading">
            <p>Esperando configuración biométrica...</p>
        </div>
        
        <div class="error-message" id="errorMessage"></div>
    </div>

    <script>
        // Configuración desde el servidor
        const webAuthnConfig = {
            challenge: '${challenge}',
            timeout: '${createTimeout}' || 60000,
            rp: {
                name: '${realm.displayName!"WhatsApp"}',
                id: '${rpId}'
            },
            user: {
                id: '${userid}',
                name: '${username}',
                displayName: '${userDisplayName!username}'
            },
            pubKeyCredParams: [
                { type: "public-key", alg: -7 },  // ES256
                { type: "public-key", alg: -257 } // RS256
            ],
            authenticatorSelection: {
                authenticatorAttachment: 'platform',
                userVerification: 'preferred'
            },
            attestation: 'direct'
        };

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

        async function startWebAuthnRegistration() {
            const registerButton = document.getElementById('registerButton');
            const loading = document.getElementById('loading');
            const errorMessage = document.getElementById('errorMessage');
            
            registerButton.style.display = 'none';
            loading.style.display = 'block';
            errorMessage.style.display = 'none';

            try {
                if (!navigator.credentials || !navigator.credentials.create) {
                    throw new Error('Tu navegador no soporta Passkeys');
                }

                const publicKey = {
                    challenge: base64ToArray(webAuthnConfig.challenge),
                    rp: webAuthnConfig.rp,
                    user: {
                        id: base64ToArray(webAuthnConfig.user.id),
                        name: webAuthnConfig.user.name,
                        displayName: webAuthnConfig.user.displayName
                    },
                    pubKeyCredParams: webAuthnConfig.pubKeyCredParams,
                    timeout: parseInt(webAuthnConfig.timeout),
                    authenticatorSelection: webAuthnConfig.authenticatorSelection,
                    attestation: webAuthnConfig.attestation
                };

                const credential = await navigator.credentials.create({ publicKey });
                
                // Preparar datos para enviar al servidor
                document.getElementById('attestationObjectInput').value = 
                    arrayToBase64(new Uint8Array(credential.response.attestationObject));
                document.getElementById('clientDataJSONInput').value = 
                    arrayToBase64(new Uint8Array(credential.response.clientDataJSON));
                document.getElementById('credentialIdInput').value = 
                    arrayToBase64(new Uint8Array(credential.rawId));
                
                if (credential.response.getPublicKey) {
                    const publicKey = await credential.response.getPublicKey();
                    document.getElementById('publicKeyInput').value = 
                        arrayToBase64(new Uint8Array(publicKey));
                }

                // Enviar formulario
                document.getElementById('webAuthnForm').submit();

            } catch (error) {
                console.error('Error en registro:', error);
                errorMessage.textContent = getErrorMessage(error);
                errorMessage.style.display = 'block';
                loading.style.display = 'none';
                registerButton.style.display = 'block';
            }
        }

        function getErrorMessage(error) {
            if (error.name === 'NotAllowedError') {
                return 'Registro cancelado por el usuario';
            } else if (error.name === 'NotSupportedError') {
                return 'Passkeys no soportado en este dispositivo';
            } else if (error.name === 'SecurityError') {
                return 'Error de seguridad. Asegúrate de usar HTTPS';
            }
            return 'Error en el registro: ' + error.message;
        }

        // Auto-iniciar registro si está configurado
        <#if autoRegister?? && autoRegister>
        setTimeout(startWebAuthnRegistration, 100);
        </#if>
    </script>
</body>
</html>