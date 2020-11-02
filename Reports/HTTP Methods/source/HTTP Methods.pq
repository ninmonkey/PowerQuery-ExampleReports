// Send a GET Request for every table row
let
    /*
    About:
        Fire multiple HTTP Get requests based on a table
    */
    Source = #table(
        type table[TestName = text],
        {{"A"}, {"B"}, {"C"}}
    ),
    WebRequest_Test = (label as text) as any  =>
    /*
    for optional arguments
        The extra [option] argument is documented here
        https://docs.microsoft.com/en-us/powerquery-m/web-contents

    */
        let
            Headers = [
                    Accept="application/json"
            ],
            Options = [
                RelativePath = "/get",
                Headers = Headers,
                Query = [
                    Name = label,
                    NowUTC = DateTimeZone.ToText( DateTimeZone.UtcNow() )
                ]
            ],
            Response = Web.Contents(
                "https://httpbin.org",
                Options
            ),
            Results = Json.Document(Response)
        in
            Results,

    RequestResults = Table.AddColumn(
        Source,
        "Request Results",
        each WebRequest_Test( [TestName] ),
        type record
    ),

    // drill down the returned request results
    #"Url" = Table.AddColumn(
        RequestResults,
        "Response",
        each [Request Results][url]?,
        type text
    ),
    #"Response Id" = Table.AddColumn(
        #"Url",
        "Response Id",
        each _[Request Results][headers][#"X-Amzn-Trace-Id"]?,
        type text
    )
in
    #"Response Id"