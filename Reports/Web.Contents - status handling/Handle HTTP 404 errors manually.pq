let
    response = Html.Table(Web.Contents("www.google.com/catdsfdsfds", [ManualStatusHandling={404}]), {})
in
    response
