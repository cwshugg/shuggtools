# This PowerShell script mutes and unmutes the default sound output device on
# Windows.

$obj = New-Object -ComObject wscript.shell
$obj.SendKeys([char] 173)

