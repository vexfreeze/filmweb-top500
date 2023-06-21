$baseUrl = "https://www.filmweb.pl"
$topRoute = "/ajax/ranking/film/"
$pages = 20

$date = Get-Date -format "yyyy-MM-dd"
$filmFile = "Filmweb Top 500 - $date.txt"

if (Test-Path -Path $filmFile -PathType Leaf) {
    Remove-Item $filmFile
}

for ($i = 0; $i -le $pages; $i++) {
    $req = Invoke-WebRequest -Uri "$baseUrl$topRoute$i"

    $req.ParsedHtml.getElementsByClassName("rankingType") | ForEach-Object {
        $position = $_.querySelector(".rankingType__position").innerText
        $title = [System.Net.WebUtility]::HtmlDecode($_.querySelector(".rankingType__title a").innerText)
        $year = [System.Net.WebUtility]::HtmlDecode($_.querySelector(".rankingType__year").innerText)

        $filmRoute = $_.querySelector(".rankingType__title a").href.Replace("about:", "")
        $filmReq = Invoke-WebRequest -Uri "$baseUrl$filmRoute"
        $directorsMatches = $filmReq.RawContent | Select-String -AllMatches -Pattern 'title="([^"]+)" itemprop="director"'

        $directorsArray = @()
        foreach ($directorsMatch in $directorsMatches.Matches) {
            $directorsArray += [System.Net.WebUtility]::HtmlDecode($directorsMatch.Captures[0].Groups[1])
        }

        $directors = $directorsArray -join ', '

        $filmLine = "$position. $title ($year) $directors"

        Write-Host $filmLine
        Add-Content -Encoding utf8 $filmFile $filmLine
    }
}
