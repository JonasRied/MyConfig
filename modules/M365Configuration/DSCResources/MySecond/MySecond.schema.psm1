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
            TenantId              = $Node.NodeName
            ApplicationId         = $Node.Authentication.ApplicationId
            CertificateThumbprint = $Node.Authentication.CertificateThumbprint
        }
    }
}
