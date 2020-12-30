// WIP -- postman GET
let
    config = [
        url = "https://postman-echo.com",
        relativePath = "/post",
        method = "POST"
    ],
    header = [

    ],
    query = [
        foo1 = "bar1",
        foo2 = "bar2"
    ],
    /* You can test on the commandlinel

        curl 'https://finnhub.io/api/v1/stock/profile2?symbol=AAPL&token=<apikeyhere>'
    */
    WebContents_options = [
        // ApiKeyName = "X-Finnhub-Token",
        RelativePath = config[relativePath],
        Query = [
            symbol = "AAPL"
        ]
    ],
    bin = Web.Contents( config[url], WebContents_options ),
    json = Json.Document( bin ),
    Source = Record.ToTable( json )
in
    Source