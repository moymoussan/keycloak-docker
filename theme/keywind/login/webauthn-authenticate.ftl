<#import "template2.ftl" as layout>
<#import "components/atoms/button.ftl" as button>

<@layout.registrationLayout script="dist/webAuthnAuthenticate.js"; section>
  <#if section="title">
    Verificación segura - WhatsApp
  <#elseif section="header">
    <!-- Header vacío porque el logo ya está en template.ftl -->
  <#elseif section="form">
    <div x-data="webAuthnAuthenticate" style="text-align: center; padding: 20px;">
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
      
      <!-- Contenido centrado -->
      <h1 style="font-size: 28px; font-weight: 600; margin-bottom: 12px; margin-top: 2rem;">
        Verificación segura 🔐
      </h1>
      <p style="font-size: 16px; color: #a0a0a0; line-height: 1.5; margin-bottom: 3rem; max-width: 300px; margin-left: auto; margin-right: auto;">
        Confirma tu identidad para autorizar la operación solicitada en WhatsApp.
      </p>
      
      <img src="${url.resourcesPath}/img/faceid.webp" alt="Verificación" style="width: 120px; height: 120px; margin-bottom: 3rem;">
      
      <!-- Botón con estilos personalizados -->
      <@button.kw 
        @click="webAuthnAuthenticate" 
        color="primary" 
        type="button"
        style="background: #25D366 !important; color: #000000 !important; border: none !important; padding: 16px !important; border-radius: 8px !important; font-weight: 600 !important; font-size: 16px !important; width: 300px !important; max-width: 100% !important; cursor: pointer !important; margin: 0 auto !important; display: block !important;"
      >
        Continuar
      </@button.kw>
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