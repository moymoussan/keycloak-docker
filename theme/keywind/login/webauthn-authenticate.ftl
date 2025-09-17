<#import "template.ftl" as layout>
<#import "components/atoms/button.ftl" as button>

<@layout.registrationLayout script="dist/webAuthnAuthenticate.js"; section>
  <#if section="title">
    Verificación segura - WhatsApp
  <#elseif section="header">
    <div style="text-align: center; margin-bottom: 2rem;">
      <img src="${url.resourcesPath}/img/logo-nono-white.png" alt="Logo" style="height: 60px; margin-bottom: 1.5rem;">
      <h1 style="color: #ffffff; font-size: 1.5rem; font-weight: 600; margin-bottom: 0.5rem;">
        Verificación segura
      </h1>
      <p style="color: #a0a0a0; font-size: 0.9rem;">
        Confirma tu identidad para autorizar la operación solicitada en WhatsApp.
      </p>
    </div>
  <#elseif section="form">
    <div x-data="webAuthnAuthenticate" style="background: #000000; padding: 2rem; border-radius: 12px;">
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
      
      <div style="text-align: center;">
        <@button.kw 
          @click="webAuthnAuthenticate" 
          color="primary" 
          type="button"
          style="background: #25D366; color: #000000; border: none; padding: 12px 24px; border-radius: 8px; font-weight: 600; font-size: 1rem; width: 100%; cursor: pointer;"
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