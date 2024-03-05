<#import "template.ftl" as layout>
<@layout.registrationLayout; section>
    <#if section = "header">
        ${msg("confirmLinkIdpTitle")}
    <#elseif section = "form">
        ${msg("docSuppressionCompteMessage")} <a href="https://doc.pass-emploi.beta.gouv.fr/suppression-de-compte/">${msg("docSuppressionCompteLinkLabel")}</a>
    </#if>
</@layout.registrationLayout>