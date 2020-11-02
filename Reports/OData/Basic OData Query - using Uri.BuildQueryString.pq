let
    // ref: https://github.com/tonmcg/powersocrata/blob/471d27be5746aab885375d23443a143bcc5ea74f/M/Socrata.ReadOData.pq

    config = [
        uriBase = "https://services.odata.org/Northwind/Northwind.svc/Employees",
        topCount = 3
    ],

    // QueryParams = [
    //     "$top" = 10
    // ],
    queryString = Uri.BuildQueryString()


    Final = 2
    // requestUri = config[uriBase] & "?" & "$top=" & Number.ToText( config[topCount] ),
in
   Final
