// Get WebContents Response values and status codes
let
    // toggles hiding extra columns
    UseMinimal = false,
    /*
    future:
        - add delay testing: <https://httpstat.us/200?sleep=2000>
    */
    // every code supported by <https://httpstat.us/>
    ErrorCodes_https_supported =
        {100..103} & {200..206} & {300..308}
        & {400..429} & {431, 451} & {500..507}
        & {511, 520, 522, 524},

    ErrorCodes_default = {400,401,403,404,429,500,503},


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
        "https://httpbin.org/",
        "https://wrong.host.badssl.com/",
        "https://expired.badssl.com/",
        "http://www.somefakenamedoesnotexist.com"
    },

    dynamic_UrlList =
        List.Transform(
            ErrorCodes_https_supported,
            each "dsfd" & _
        ),

    urlList = static_UrlList & dynamicUrlList,



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
            r2 = Record.AddField(metaData, "Binary", response, null ),
            r3 = Record.AddField(r2, "Response.Error",
                if maybeErr[HasError] then maybeErr[Error] else null,
                null
            ),
            r4 = Record.AddField(r3, "Url", metaData[Content.Uri]() )
        in
            r4,

    metaDataList = List.Transform(
        responseList,
        each WebRequest_ToRecord(_)
    ),

    WebRequestList_ToTable = (source as list, optional minimal as nullable logical) as table =>
        let
            WebRequest_Table.Type = type table[
                Content.Type = text,
                Content.Uri = Function.Type,
                Content.Name = text,
                Headers = record,
                Request.Options = record,
                Response.Status = number, // always?
                Response.Error = record,
                Binary = binary,
                Url = text
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