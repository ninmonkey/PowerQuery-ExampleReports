function Invoke-RandomCatImages {
    <#
.synopsis
    generates random cat urls
.example

    [ GroupId = 1, = "https://cdn2.thecatapi.com/images/e7.jpg" ]
    [ GroupId = 2, = "https://cdn2.thecatapi.com/images/cdh.jpg" ]
    [ GroupId = 0, = "https://cdn2.thecatapi.com/images/ZKuiRpWtD.jpg" ]
    [ GroupId = 1, = "https://cdn2.thecatapi.com/images/ycoqoHPqh.jpg" ]
    [ GroupId = 2, = "https://cdn2.thecatapi.com/images/SCHe-SekW.jpg" ]
    [ GroupId = 0, = "https://cdn2.thecatapi.com/images/dnb.jpg" ]

#>
    [cmdletbinding()]
    param()

    $template = '[ GroupId = {0}, = {1} ]'
    $cats = 0..5 | ForEach-Object {
        Invoke-RestMethod 'https://api.thecatapi.com/v1/images/search'
        Start-Sleep 0.2 # values are hard-coded, to be nice to the api
    }

    $cats.url | ForEach-Object {
        $i++
        $Template -f @(
            $i % 3
            $_ | Join-String -DoubleQuote
        )
    }
}


$template = '[ GroupId = {0}, = {1} ]'
$cats ??= 0..5 | ForEach-Object {
    Invoke-RestMethod 'https://api.thecatapi.com/v1/images/search'
    Start-Sleep 0.2 # values are hard-coded, to be nice to the api
}

$i = 0
$cats.url
| Join-String -sep ",`n" {
    $script:i++
}
