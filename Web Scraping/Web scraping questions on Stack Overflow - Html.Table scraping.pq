let
    Url = "https://stackoverflow.com/questions/tagged/powerquery",
    Response = Web.Contents( Url ),
    /*
    The 3rd argument in "columnNameSelectorPairs" is the transformation function.
    by default it uses:

            each _[TextContent]
    */
    HeaderAsElement = Html.Table(
        Response,
        {
            { "Link", "a.question-hyperlink", each _ }

        }
    ),

    ElementRecord = Table.ExpandRecordColumn(HeaderAsElement, "Link", {"TextContent", "Attributes"}, {"TextContent", "Attributes"}),
    ExpandedAttributes = Table.ExpandRecordColumn(ElementRecord, "Attributes", {"class", "href"}, {"Class", "Url"}),
in
    ExpandedAttributes