// Case Sensitive Test
let
    /* Use ListAsText to summarize results */
    NameList = { "moNkey", "monKEY", "MONKEY", "mONkeY" },
    Source = Table.FromList(
        NameList, null,
        type table[Name = text],
        null, null
    ),
    Results = [
        #"Original List" = ListAsText(  Source[Name] ),
        #"IsDistinct? Ordinal" = List.IsDistinct( Source[Name], Comparer.Ordinal ),
        #"IsDistinct? OrdinalIgnoreCase" = List.IsDistinct( Source[Name], Comparer.OrdinalIgnoreCase ),

        #"Distinct using OrdinalIgnoreCase" = ListAsText(  List.Distinct( Source[Name], Comparer.OrdinalIgnoreCase ) ),
        #"Distinct using Ordinal" = ListAsText(  List.Distinct( Source[Name], Comparer.Ordinal ) )
    ]
in
    Results

// ListAsText
/*
from: https://github.com/microsoft/DataConnectors/blob/460babf2f8c44ec82d7e08d1b65b156984c6ba75/samples/UnitTesting/UnitTesting.query.pq#L210-L244

Note:
    The original serializes **everything**
    This only shows type names as text

    todo: support

*/
let

    /* Optional parameter: Is this being used as part of a function signature? */
    Serialize.List =  (x) => "{" &
        List.Accumulate(x, "",
            (seed,item) =>
                if seed="" then Text.From(item)
                else seed & ", " & Text.From(item)) &
            "} "
in
    Serialize.List
