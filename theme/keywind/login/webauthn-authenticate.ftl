<#import "template.ftl" as layout>
<#import "components/atoms/button.ftl" as button>

<@layout.registrationLayout script="dist/webAuthnAuthenticate.js"; section>
  <#if section="title">
    Verificación segura - WhatsApp
  <#elseif section="header">
    <style>
      /* Sobrescribir estilos de la template base */
      .card {
        background: white !important;
        border: none !important;
        box-shadow: none !important;
        padding: 2rem !important;
      }
      
      .card-header {
        text-align: center !important;
        padding: 0 !important;
        margin-bottom: 2rem !important;
      }
      
      .card-content {
        padding: 0 !important;
      }
    </style>
    
    <div class="verification-header">
      <!-- Logo/Icono de verificación -->
      <div class="verification-icon">
        <svg width="40" height="40" viewBox="0 0 24 24" fill="white">
          <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/>
        </svg>
      </div>
      <h1 class="verification-title">
        Verificación segura
      </h1>
      <p class="verification-description">
        Confirma tu identidad para autorizar la operación<br>solicitada en WhatsApp.
      </p>
    </div>
  <#elseif section="form">
    <div x-data="webAuthnAuthenticate" class="verification-content">
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
      
      <div class="verification-button-container">
        <@button.kw 
          @click="webAuthnAuthenticate" 
          color="primary" 
          type="button"
          style="background: #3dc28d; color: #ffffff; border: none; padding: 16px 32px; border-radius: 8px; font-weight: 600; font-size: 1.1rem; width: 100%; cursor: pointer; box-shadow: 0 2px 4px rgba(0,0,0,0.1);"
        >
          Continuar
        </@button.kw>
      </div>
    </div>
    
    <style>
      /* Estilos específicos para esta página */
      .verification-icon {
        background: #3dc28d;
        width: 80px;
        height: 80px;
        border-radius: 50%;
        margin: 0 auto 1.5rem;
        display: flex;
        align-items: center;
        justify-content: center;
      }
      
      .verification-title {
        color: #000000;
        font-size: 1.5rem;
        font-weight: 600;
        margin-bottom: 0.5rem;
      }
      
      .verification-description {
        color: #666666;
        font-size: 0.9rem;
        line-height: 1.4;
      }
      
      .verification-button-container {
        text-align: center;
        margin-top: 2rem;
      }
      
      /* Reset de estilos heredados */
      body {
        background: white !important;
      }
    </style>
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