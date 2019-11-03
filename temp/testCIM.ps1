

function Foo ( $a, $b) {
    $a
    $b
    return "foo"
}

$x = "abc"
$y = 123

Invoke-Command -Credential $c -ComputerName $fqdn -ScriptBlock ${function:Foo} -ArgumentList $x, $y