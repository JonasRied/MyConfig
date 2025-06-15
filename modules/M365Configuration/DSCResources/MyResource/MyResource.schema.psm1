Configuration MyResource { 

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node $AllNodes.NodeName {

        $AuthenticationData = $Node.Authentication

        File ExampleFile {
            DestinationPath = 'C:\Temp\example.txt'
            Contents        = "$Env:M365_TenantId`n$Env:M365_CertificateThumbprint`n$Env:M365_ApplicationId"
            Ensure          = 'Present'
            Type            = 'File'
        }
    }
}