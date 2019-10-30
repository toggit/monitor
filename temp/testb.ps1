Write-Output "from testb: =>>>>>>"
if (-not $script:varA) {
    $script:varA = @{ }
}
$script:varA.Add("two", "number2")
$script:varA.Add("one3", "number1##")


function updateHash {
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $key
    )
    Write-Output "testb.ps1: calling updateHash"
    $script:varA.add($key, "$key value")
}