# 跳過 Windows11 更新的硬體限制
function Win11Update-NotVerify {
    param (
        [string] $IsoFile
    )
    $7zPATH = "${env:ProgramFiles}\7-Zip"
    
    if (!(Test-Path $7zPATH)) {
        Set-ExecutionPolicy Bypass -S:Process -F
        Invoke-RestMethod chocolatey.org/install.ps1|Invoke-Expression
        choco install -y 7zip
    }
    
    $env:Path = "${env:Path};$7zPATH"
    $WinPATH = "${env:Temp}\Win11_ISO"
    $cmd = "7z x `"$IsoFile`" -o$WinPATH"
    Invoke-Expression $cmd
    
    Move-Item "$WinPATH\sources\appraiserres.dll" "$WinPATH\sources\_appraiserres.dll" -Force
    explorer "$WinPATH"
    explorer "$WinPATH\setup.exe"
    
    Write-Host "安裝時務必在第一個畫面選擇" -ForegroundColor:Yellow
    Write-Host "  變更安裝下載的方式 -> 現在不用" -ForegroundColor:Yellow
} # Win11Update-NotVerify -IsoFile:"D:\DATA\ISO_Files\Win11_Chinese(Traditional)_x64v1.iso"
