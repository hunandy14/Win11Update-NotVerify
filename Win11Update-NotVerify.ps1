function Initialize-7zEnvironment {
    param (
        [switch] $ForceInstall
    )
    $7zPATH = "${env:ProgramFiles}\7-Zip"
    
    if ((!(Test-Path $7zPATH)) -or $ForceInstall) {
        Set-ExecutionPolicy Bypass -S:Process -F
        Invoke-RestMethod chocolatey.org/install.ps1|Invoke-Expression
        choco install -y 7zip
    }
    
    $env:Path = "${env:Path};$7zPATH"
} # Initialize-7zEnvironment

# 跳過 Windows11 更新的硬體限制
function Update-Win11 {
    param (
        [string] $IsoFile
    )
    Initialize-7zEnvironment -ForceInstall
    $WinPATH = "${env:Temp}\Win11_ISO"
    $cmd = "7z x `"$IsoFile`" -o$WinPATH"
    Invoke-Expression $cmd
    
    Move-Item "$WinPATH\sources\appraiserres.dll" "$WinPATH\sources\_appraiserres.dll" -Force
    explorer "$WinPATH"
    explorer "$WinPATH\setup.exe"
    
    Write-Host "安裝時務必在第一個畫面選擇" -ForegroundColor:Yellow
    Write-Host "  變更安裝下載的方式 -> 現在不用" -ForegroundColor:Yellow
} # Update-Win11 -IsoFile:"D:\DATA\ISO_Files\Win11_Chinese(Traditional)_x64v1.iso"


function Install-WindowsPCHealthCheckSetup {
    param (
        [switch] $Force
    )
    $Site = "https://github.com/hunandy14/Win11Update-NotVerify/raw/master/soft/WindowsPCHealthCheckSetup.msi"
    $FileName    = "WindowsPCHealthCheckSetup.msi"
    $AppPath     = $env:TEMP
    $DownloadChk = !(Test-Path "$AppPath\$FileName")
    if ($DownloadChk -or $Force) {
        Start-BitsTransfer $Site "$env:TEMP"
    } explorer "$AppPath\$FileName"
} # Install-WindowsPCHealthCheckSetup