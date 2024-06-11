# Ensure PSReadLine is imported
if ($PSVersionTable.PSVersion -lt [Version]"6.0") {
    Import-Module PSReadLine
} else {
    Import-Module Microsoft.PowerShell.PSReadLine
}

# Define the action to be executed by Ctrl+F
Set-PSReadLineKeyHandler -Chord 'Ctrl+f' -ScriptBlock {
    $sessionizerScript = "C:\\Users\\Bruno\\Documents\\bruno\\dev\\dotfiles\\powershell\\sessionizer.ps1"
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File $sessionizerScript
}

Set-Alias v nvim

function skeleton {
    Set-Location -Path 'C:\Users\Bruno\AppData\Local\nvim\'
}

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

