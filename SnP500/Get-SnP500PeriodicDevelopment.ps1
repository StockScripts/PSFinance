function Get-SnP500PeriodicDevelopment {
    <#
        .SYNOPSIS
            Get the development of the SnP500 index between given dates, as a percentage.

        .EXAMPLE
            $JanuarySnP500 = 1951..2019 | %{
                $Year = $_
                $Development = Get-SnP500PeriodicDevelopment -Verbose -StartDate (Get-Date -Year $_ -Month 1 -Day 2) `
                                                -EndDate (Get-Date -Year $_ -Month 1 -Day 29)
                [PSCustomObject] @{
                        Year = $Year
                        Development = if ($Development) { [Math]::Round($Development, 4) } else { '-' }
                }
            }

    #>
    [CmdletBinding()]
    Param(
        [DateTime] $StartDate = (Get-Date).AddDays(-21),
        [DateTime] $EndDate = (Get-Date).AddDays(-1),
        [String] $FilePath = "C:\temp\^GSPC.csv"
        )

    
    ## 2019-01-31. beta version...
    
    $SnPCSV = Import-Csv -LiteralPath $FilePath

    $SnPCSV | ForEach-Object {
    
        if (($CsvNow = [DateTime] $_.Date) -lt $StartDate.AddDays(1) `
            -and $CsvNow -gt $StartDate.AddDays(-1)) {
        
            Write-Verbose "Found start date as $CsvNow (close: $($_.Close))."
            $StartClose = [Decimal] $_.Close

        }
        if (($CsvNow = [DateTime] $_.Date) -lt $EndDate.AddDays(1) `
            -and $CsvNow -gt $EndDate.AddDays(-1)) {

            Write-Verbose "Found end date as $CsvNow (close: $($_.Close))."
            $EndClose = [Decimal] $_.Close

        }

    }

    # Calculate development as a percentage.

    if ($null -eq $EndClose) {
        Write-Verbose "End close not found for end date: $EndDate"
        return
    }
    if ($null -eq $StartClose) {
        Write-Verbose "Start close not found for start date: $StartDate"
        return
    }

    (($EndClose - $StartClose) / $EndClose) * 100

}
