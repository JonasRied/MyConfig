Configuration OutPut {

    Import-DSCResource -ModuleName 'M365Configuration'

    Node $AllNodes.NodeName {

        # Ensure the M365Build environment variables are set
        $Env:M365_TenantId = $Node.NodeName
        $Env:M365_ApplicationId = $Node.Authentication.ApplicationId
        $Env:M365_CertificateThumbprint = $Node.Authentication.CertificateThumbprint

        # Use resources from the M365Configuration module to build the configuration
        MyResource ExampleResource {}
    }
}