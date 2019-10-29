

function test {

    $script:a = 1
    $script:b = 2

    function a {
        $script:a = 5
    }

    function b {
        $script:b = 6
    }

    b
    a
    $b = $b + $a + 1
    Write-Output "b: $b, a: $a"

}
# test
$MyInvocation.MyCommand.Path
$PSScriptRoot
Join-Path $PSScriptRoot Functions
$global:Security