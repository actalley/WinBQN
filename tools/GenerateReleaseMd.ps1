Set-StrictMode -Version Latest


filter FieldWidth {

    [string[]]$_ | Measure-Object -Maximum -Property Length |
        Select-Object -Property @{ Name='Width'; Expression={ $_.Maximum + 2 } } |
        Select-Object -ExpandProperty Width
}


Filter Pad {

    ($_.PadLeft($_.Length + 1, $args[0])).PadRight($args[1], $args[0])
}


$filename = 'release.md'
$dist = "$PSScriptRoot\..\dist\"
$c1, $c2 = 'Filename', 'SHA256'

$hashes = Get-ChildItem -Path $dist -Filter *.zip |
    Select-Object -Property @{ Name=$c1; Expression={ $_.Name }},
        @{ Name=$c2; Expression={ Get-FileHash -Path $_.FullName -Algorithm $c2 |
    Select-Object -ExpandProperty Hash } }

$nameWidth, $hashWidth =
    ($hashes | Select-Object -ExpandProperty $c1),
    ($hashes | Select-Object -ExpandProperty $c2) | FieldWidth

"|$($c1 | Pad ' ' $nameWidth)|$($c2 | Pad ' ' $hashWidth)|",
"|$('' | Pad '-' $nameWidth)|$('' | Pad '-' $hashWidth)|",
($hashes | ForEach-Object { "|$($_.$c1 | Pad ' ' $nameWidth)|$($_.$c2 | Pad ' ' $hashWidth)|" }) |
    Out-File -FilePath "$dist\$filename"