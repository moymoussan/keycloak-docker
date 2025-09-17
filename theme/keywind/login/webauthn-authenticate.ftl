<#import "template.ftl" as layout>
<#import "components/atoms/button.ftl" as button>

<@layout.registrationLayout script="dist/webAuthnAuthenticate.js"; section>
  <#if section="title">
    Verificación segura - WhatsApp
  <#elseif section="header">
    <style>
      /* Sobrescribir estilos de la template base */
      .card {
        background: #000000 !important;
        border: none !important;
        box-shadow: none !important;
        padding: 0 !important;
      }
      
      .card-header {
        text-align: left !important;
        padding: 0 !important;
        margin-bottom: 1rem !important;
      }
      
      .card-content {
        padding: 0 !important;
        background: #000000 !important;
      }
      
      /* Ocultar elementos no deseados */
      .alert, .text-secondary-600, .text-sm {
        display: none !important;
      }
    </style>
    
    <div style="margin-left: 1rem; margin-top: 1rem;">
      <img src="${url.resourcesPath}/img/logo-nono-white.png" alt="Logo" style="height: 40px;">
    </div>
  <#elseif section="form">
    <div x-data="webAuthnAuthenticate" style="background: #000000; text-align: center; padding: 20px;">
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
      
      <!-- Tu diseño personalizado -->
      <h1 style="font-size: 28px; font-weight: 600; color: #ffffff; margin-bottom: 12px;">
        Verificación segura 🔐
      </h1>
      <p style="font-size: 16px; color: #a0a0a0; line-height: 1.5; margin-bottom: 3rem; max-width: 300px; margin-left: auto; margin-right: auto;">
        Confirma tu identidad para autorizar la operación solicitada en WhatsApp.
      </p>
      
      <img src="${url.resourcesPath}/img/faceid.webp" alt="Verificación" style="width: 120px; height: 120px; margin-bottom: 3rem;">
      
      <!-- Botón que mantiene la funcionalidad Alpine -->
      <@button.kw 
        @click="webAuthnAuthenticate" 
        color="primary" 
        type="button"
        style="background: #25D366; color: #000000; border: none; padding: 16px; border-radius: 8px; font-weight: 600; font-size: 16px; width: 300px; cursor: pointer; margin: 0 auto; display: block;"
      >
        Continuar
      </@button.kw>
    </div>
    
    <style>
      /* Reset del fondo body */
      body {
        background: #000000 !important;
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