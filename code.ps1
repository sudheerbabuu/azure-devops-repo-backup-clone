$Organization = 'https://dev.azure.com/name'
$Projects = az devops project list --organization $Organization --query 'value[].name' -o tsv
foreach ($Proj in $Projects) {
    if (-not (Test-Path -Path ".\$Proj" -PathType Container)) {
        New-Item -Path $Proj -ItemType Directory |
        Select-Object -ExpandProperty FullName |
        Push-Location
    }
    $Repos = az repos list --organization $Organization --project $Proj | ConvertFrom-Json
    foreach ($Repo in $Repos) {
        if(-not (Test-Path -Path $Repo.name -PathType Container)) {
            Write-Warning -Message "Cloning repo $Proj\$($Repo.Name)"
            git clone $Repo.webUrl
        }
    }
    $cmd = "cd D:/repo/backup"
    iex $cmd
    
}
