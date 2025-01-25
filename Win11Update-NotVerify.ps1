# 初始化 7z 環境
function Initialize-7zEnvironment {
    param (
        [switch] $ForceDownload
    )

    # 如果已安裝直接使用
    $7zPath = Join-Path $env:ProgramFiles "7-Zip\7z.exe"
    if ((Test-Path $7zPath) -and (!$ForceDownload)) {
        return $7zrPath
    }
    
    # 未安裝則下載精簡板使用
    $7zrUrl = "https://7-zip.org/a/7zr.exe"
    $7zrPath = Join-Path $env:TEMP "7zr.exe"
    if ((!(Test-Path $7zrPath)) -or $ForceDownload) {
        try {
            (New-Object Net.WebClient).DownloadFile($7zrUrl, $7zrPath)
            $7zrPath = $7zrPath
        } catch { throw }
    }
    return $7zrPath
} # Initialize-7zEnvironment

# 跳過 Windows11 更新的硬體限制
function Update-Win11 {
    param (
        [string] $IsoFile
    )
    # 初始化 7zr
    $7zrPath = Initialize-7zEnvironment
    $WinPATH = "${env:Temp}\Win11_ISO"
    
    # 使用 7zr 解壓 ISO
    & $7zrPath x $IsoFile -o $WinPATH
    
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