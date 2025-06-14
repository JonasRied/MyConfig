Configuration M365Configuration {

    Import-DSCResource -ModuleName 'M365Configuration'

    Node $AllNodes.NodeName {

        Write-Host $Node.NodeName

        MyResource ExampleResource {}
    }
}