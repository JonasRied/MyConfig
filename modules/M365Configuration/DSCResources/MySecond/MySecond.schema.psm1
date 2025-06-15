Configuration MySecond
{
    Import-DscResource -ModuleName Microsoft365DSC

    Node $AllNodes.NodeName
    {
        File ExampleFile {
            DestinationPath       = 'C:\Temp\example.txt'
            Contents              = "Hello from $($Node.NodeName)"
            Ensure                = 'Present'
            Type                  = 'File'
            TenantId              = $Env:M365_TenantId
            ApplicationId         = $Env:M365_ApplicationId
            CertificateThumbprint = $Env:M365_CertificateThumbprint
        }
    }
}
    