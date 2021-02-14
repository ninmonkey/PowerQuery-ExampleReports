let
    // These datetimes are all the same time, using a different 'culture'
    Source = #table(
        type table[DateString = text, User = text],
        {
            { "2/13/2021 7:01:46 PM", "Bob" },
            { "13/02/2021 19:01:46", "Jen" },
            { "13.02.2021 19:01:46", "Kate" }
        }
    ),
    Culture = [
        Bob = "en-US",
        Jen = "de-DE",
        Kate = "en-GB"
    ],

    // [User] column is mapped to a 'culture'
    // then [DateString] is converted
    DateTime_FromDynamicCulture = (row as record) as datetime =>
        let
            author = row[User],
            culture = Record.Field( Culture, author),
            result = DateTime.FromText( row[DateString], culture)
        in
            result,

    convertDatetimes = Table.AddColumn(
        Source, "DateTime_DynamicCulture",
        each DateTime_FromDynamicCulture(_),
        type datetime
    )
in
    convertDatetimes