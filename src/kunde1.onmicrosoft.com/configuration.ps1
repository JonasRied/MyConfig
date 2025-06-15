Configuration OutPut {

    Import-DSCResource -ModuleName 'M365Configuration'

    Node $AllNodes.NodeName {

        MyResource ExampleResource {}
    }
}