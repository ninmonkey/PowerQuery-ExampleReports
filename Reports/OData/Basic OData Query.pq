let

    config = [
        uriBase = "https://services.odata.org/Northwind/Northwind.svc/Employees",
        topCount = 3
    ],

    requestUri = config[uriBase] & "?" & "$top=" & Number.ToText( config[topCount] ),

    Final = 2
in
   Final
