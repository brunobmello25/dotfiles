param (
    [string]$selected
)

if (-not $selected) {
    $dirs = Get-ChildItem -Directory -Path "$HOME/Documents/bruno/dev", "$HOME/Documents/bruno/dev/godot-projects"  | ForEach-Object { $_.FullName }
    $additional_dirs = @("$HOME/Documents/bruno/obsidian-vault")
    $all_dirs = $dirs + $additional_dirs
    $selected = $all_dirs | fzf
}

if (-not $selected) {
    exit
}

$selected_name = [System.IO.Path]::GetFileName($selected) -replace '\.', '_'
$sessions = Get-Process -Name "WindowsTerminal" -ErrorAction SilentlyContinue

if (-not $sessions) {
    wt w "0" -d $selected -p "PowerShell" --title $selected_name
    exit
}

$sessions = Get-Process -Name "WindowsTerminal" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like "*$selected_name*" }

if ($sessions) {
    $sessions | ForEach-Object {
        [void][WindowsInput.Native.InputSimulator]::New().Keyboard.KeyPress([WindowsInput.Native.VirtualKeyCode]::VK_LWIN)
        Start-Sleep -Milliseconds 100
        $_.WaitForInputIdle()
        [void][WindowsInput.Native.InputSimulator]::New().Keyboard.KeyPress([WindowsInput.Native.VirtualKeyCode]::TAB)
    }
    exit
} else {
    wt -w "0" -d $selected -p "PowerShell" --title $selected_name
}

