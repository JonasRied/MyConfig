Configuration MySecondResource
{
    Import-DscResource -ModuleName Microsoft365DSC

    Node $AllNodes.NodeName
    {
        AADUser 'ConfigureJohnSMith' {
            UserPrincipalName     = "John.Smith@$Env:M365_TenantId"
            FirstName             = "John"
            LastName              = "Smith"
            DisplayName           = "John J. Smith"
            City                  = "Gatineau"
            Country               = "Canada"
            Office                = "Ottawa - Queen"
            UsageLocation         = "US"
            Ensure                = "Present"
            TenantId              = $Env:M365_TenantId
            ApplicationId         = $Env:M365_ApplicationId
            CertificateThumbprint = $Env:M365_CertificateThumbprint
        }
    }
}
