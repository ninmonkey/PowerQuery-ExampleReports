let
    // toggles hiding extra columns
    UseMinimal = false,         // simplify final table output
    UseFastTest = true,         // skip most tests to quickly test the connection?
                                // slow might need a sleep delay/waitfor pattern to play nice
    /*
    todo:
        - add delay testing: <https://httpstat.us/200?sleep=2000>
        - retry pattern: <https://docs.microsoft.com/en-us/power-query/waitretry>
        - Uri split query string
        - <https://docs.microsoft.com/en-us/power-query/helperfunctions#urifromparts>
        - <https://docs.microsoft.com/en-us/power-query/helperfunctions#retrieving-data>
    */
    // every code supported by <https://httpstat.us/>
    ErrorCodes_https_supported =
        {100..103} & {200..206} & {300..308}
        & {400..429} & {431, 451} & {500..507}
        & {511, 520, 522, 524},

    ErrorCodes_default = {400..405} & {429,500,503},


    ErrorCodes_ManualStatusHandling =
        ErrorCodes_default,
        // {400,401,403,404,429,500,503},
    ErrorCodes_StatusList =
        ErrorCodes_ManualStatusHandling,
        // ErrorCodes_ManualStatusHandling

    RequestOptions =  [
        // Timeout = // as duration: default is 100ms
        // IsRetry = true, // true: means ignore cached response
        // ManualStatusHandling =
        ManualStatusHandling = ErrorCodes_ManualStatusHandling

    ],
    static_UrlList = {
        // test TLS errors
        "https://wrong.host.badssl.com/",
        "https://expired.badssl.com/",
        // non-existing domain
        "http://www.somefakenamedoesnotexist.com",

        // a couple specific HTTP statuses
        "https://httpbin.org/",
        "https://httpstat.us/200",
        "https://httpstat.us/404",
        "https://httpstat.us/403",
        "https://httpstat.us/405"
    },

    dynamic_UrlList =
        List.Transform(
            ErrorCodes_https_supported,
            (_ as any) as text =>
                "https://httpstat.us/" & Text.From( _ )
        ),


    urlList =
        if UseFastTest then static_UrlList
        else static_UrlList & dynamic_UrlList,

    responseList = List.Transform(
        urlList,
        (url as text) as any =>
            Web.Contents(
                url,
                RequestOptions
            )
    ),


    // Get metadata for a Web.Contents call
    WebRequest_ToRecord = (response as binary) as record  =>
        let
            metaData = Value.Metadata( response ),
            maybeErr = try metaData[Content.Type],

            /*
            Careful:
                Binary.Length( Web.Contents( ...a 403 response ) )

            will throw
                "Expression.Error: Access to the resource if forbidden"

            Note:
                - No error occurs on Value.Metadata() but it will on value calls
                - Exception is high level
                    even a 'try' or 'let' block cannot capture it.
                    an error record isn't returned if you use a "try"

            403 returns status code null

            */
            contentLength =
                if ( metaData[Response.Status] = 403 or metaData[Response.Status] = null) then null
                else Binary.Length( response ),

            r1 = Record.AddField(metaData, "Binary", response, null ),
            r2 = Record.AddField(r1, "Content.Length", contentLength, null
            ),
            r3 = Record.AddField(r2, "Response.Error",
                if maybeErr[HasError] then maybeErr[Error] else null,
                null
            ),
            r4 = Record.AddField(r3, "Url", metaData[Content.Uri]() ),
            r5 = Record.RemoveFields(
                r4, {"Content.Uri"}, MissingField.UseNull
            )
        in
            r5,

    metaDataList = List.Transform(
        responseList,
        each WebRequest_ToRecord(_)
    ),

    WebRequestList_ToTable = (source as list, optional minimal as nullable logical) as table =>
        let
            WebRequest_Table.Type = type table[
                Url = text,
                Response.Status = number, // always?
                Content.Type = text,
                Content.Length = Int64.Type,
                Response.Error = record,
                // Content.Uri = Function.Type, it returns the url, nothing else? or re-invoke original?
                Content.Name = text, // probably base url
                Headers = record,
                Request.Options = record,
                Binary = binary
        ],

        t1 = Table.FromRecords(
            metaDataList,
            WebRequest_Table.Type,
            MissingField.Error
        ),
        Final = Table.ExpandRecordColumn(
            t1,
            "Response.Error",
            {"Reason", "Message", "Detail"},
            {"Error.Reason", "Error.Message", "Error.Detail"}
        ),
        FinalMinimal = Table.SelectColumns(
            Final,
            {"Url", "Response.Status", "Error.Reason", "Error.Message", "Error.Detail"}
        ),
        result =
            if minimal then FinalMinimal else Final
        in
            result,

    FinalTable = WebRequestList_ToTable( responseList, UseMinimal )
in
    FinalTable