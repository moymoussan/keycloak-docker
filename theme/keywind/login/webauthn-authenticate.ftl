<#import "template.ftl" as layout>
<#import "components/atoms/button.ftl" as button>

<@layout.registrationLayout script="dist/webAuthnAuthenticate.js"; section>
  <#if section="title">
    Verificación segura - WhatsApp
  <#elseif section="header">
    <style>
      /* Reset completo de estilos heredados */
      * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
      }
      
      body {
        background: white !important;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        display: flex;
        justify-content: center;
        align-items: center;
        min-height: 100vh;
        padding: 20px;
      }
      
      .card {
        all: unset !important;
        background: white !important;
        width: 100%;
        max-width: 400px;
        text-align: center;
      }
      
      .card-header {
        all: unset !important;
        margin-bottom: 2rem;
      }
      
      .card-content {
        all: unset !important;
      }
    </style>
    
    <div style="text-align: center; margin-bottom: 2rem;">
      <!-- Icono de verificación -->
      <div style="background: #3dc28d; width: 80px; height: 80px; border-radius: 50%; margin: 0 auto 1.5rem; display: flex; align-items: center; justify-content: center;">
        <svg width="40" height="40" viewBox="0 0 24 24" fill="white">
          <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/>
        </svg>
      </div>
      <h1 style="color: #000000; font-size: 24px; font-weight: 600; margin-bottom: 12px; line-height: 1.3;">
        Verificación segura
      </h1>
      <p style="color: #666666; font-size: 16px; line-height: 1.5;">
        Confirma tu identidad para autorizar la operación solicitada en WhatsApp.
      </p>
    </div>
  <#elseif section="form">
    <div x-data="webAuthnAuthenticate" style="width: 100%;">
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
      
      <div style="text-align: center; margin-top: 2rem;">
        <@button.kw 
          @click="webAuthnAuthenticate" 
          color="primary" 
          type="button"
          style="background: #3dc28d; color: white; border: none; padding: 16px; border-radius: 8px; font-weight: 600; font-size: 16px; width: 100%; cursor: pointer; height: 48px; display: flex; align-items: center; justify-content: center;"
        >
          Continuar
        </@button.kw>
      </div>
    </div>
  </#if>
</@layout.registrationLayout>

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