let
    start = 2,
    end = 30,
    step = 40,
    count = 10,

    Literal = {2..30},
    Literal_With_Vars = {start..end},
    Numbers = List.Numbers(
        start, count, step
    ),

    Generate = List.Generate(
        () => start,
        each _ < end,
        each _ + step
    ),

    Index_Default_Type = Table.AddIndexColumn(
        Table, "Index", start, step),

    Index_Int8 = Table.AddIndexColumn(
        Table, "Index", start, step, Int8.Type),

    Results = [
        Literal = Literal,
        Literal_With_Vars = Literal_With_Vars,
        Numbers = Numbers,
        Generate = Generate
    ]
in
    Results