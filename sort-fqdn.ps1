<#
.SYNOPSIS
    Sort a list of FQDNs into TLD order.

.DESCRIPTION
    Names are compared label by label from right to left (TLD first, then the
    domain, then each sub-domain), case-insensitively and ignoring any trailing
    dot. Each name is output exactly as it was given. Blank lines are ignored.

.PARAMETER InputObject
    FQDNs to sort. Accepts pipeline input.

.PARAMETER Path
    One or more files containing one FQDN per line.

.EXAMPLE
    ./sort-fqdn.ps1 -Path hosts.txt

.EXAMPLE
    Get-Content hosts.txt | ./sort-fqdn.ps1

.EXAMPLE
    ./sort-fqdn.ps1 www.example.com mail.example.org example.com
#>
[CmdletBinding(DefaultParameterSetName = 'Input')]
param(
    [Parameter(ParameterSetName = 'Input', Position = 0, ValueFromPipeline = $true, ValueFromRemainingArguments = $true)]
    [AllowEmptyString()]
    [string[]]$InputObject,

    [Parameter(ParameterSetName = 'Path', Mandatory = $true)]
    [string[]]$Path
)

begin {
    $names = [System.Collections.Generic.List[string]]::new()
}

process {
    if ($PSCmdlet.ParameterSetName -eq 'Path') {
        $lines = Get-Content -LiteralPath $Path
    }
    else {
        $lines = $InputObject
    }
    foreach ($line in $lines) {
        if ($null -eq $line) { continue }
        $name = $line.Trim()
        if ($name -ne '') { $names.Add($name) }
    }
}

end {
    # Key is the reversed labels joined with [char]1, which sorts before any
    # printable character under ordinal comparison, so that
    # "a.com" < "x.a.com" < "a-b.com".
    $items = foreach ($name in $names) {
        $labels = $name.ToLowerInvariant().TrimEnd('.').Split('.')
        [array]::Reverse($labels)
        [pscustomobject]@{ Key = $labels -join [char]1; Name = $name }
    }

    $comparison = [System.Comparison[object]] {
        param($a, $b)
        $c = [string]::CompareOrdinal($a.Key, $b.Key)
        if ($c -eq 0) { $c = [string]::CompareOrdinal($a.Name, $b.Name) }
        $c
    }

    $list = [System.Collections.Generic.List[object]]::new()
    foreach ($item in $items) { $list.Add($item) }
    $list.Sort($comparison)
    $list | ForEach-Object { $_.Name }
}
