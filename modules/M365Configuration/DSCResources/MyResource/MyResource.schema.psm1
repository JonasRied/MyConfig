Configuration MyResource
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node $AllNodes.NodeName
    {
        $AuthenticationData = $Node.Authentication

        File ExampleFile
        {
            DestinationPath = 'C:\Temp\example.txt'
            Contents        = "$($Node.NodeName)`n$($AuthenticationData.CertificateThumbprint)`n$($AuthenticationData.ApplicationId)"
            Ensure          = 'Present'
            Type            = 'File'
        }
    }
}