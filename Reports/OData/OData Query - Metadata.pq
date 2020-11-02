let
    BaseUrl = "http://services.odata.org/v4/TripPinService/",
    r1_args = [
        Implementation = "2.0"
    ],
    r2_args = [
        Implementation = "2.0",
        IncludeAnnotations = "*"
    ],

    r3_args = [
        Implementation = "2.0",
        IncludeAnnotations="OData.Community.Display.V1.FormattedValue"
    ],


    r1_Source = OData.Feed( BaseUrl, null, r1_args ),
    r1_schema = Table.Schema( r1_Source ),
    r1_SourceAirports = r1_Source{[Name="Airports"]}[Data],
    r1_schemaAirports = Table.Schema( r1_SourceAirports ),

    r2_Source = OData.Feed( BaseUrl, null, r2_args ),
    r2_schema = Table.Schema( r2_Source ),
    r2_SourceAirports = r2_Source{[Name="Airports"]}[Data],
    r2_schemaAirports = Table.Schema( r2_SourceAirports ),

    r3_Source = OData.Feed( BaseUrl, null, r3_args ),
    r3_schema = Table.Schema( r3_Source ),
    r3_SourceAirports = r3_Source{[Name="Airports"]}[Data],
    r3_schemaAirports = Table.Schema( r3_SourceAirports ),


    last = r2_schemaAirports
in
    last
