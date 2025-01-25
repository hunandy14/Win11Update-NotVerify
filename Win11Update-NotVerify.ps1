# 初始化 7z 環境
function Initialize-7zEnvironment {
    [CmdletBinding()]
    param (
        [switch] $ForceDownload
    )

    # 如果已安裝直接使用
    $7zPath = Join-Path $env:ProgramFiles "7-Zip\7z.exe"
    if (Test-Path $7zPath) { return $7zPath }
    
    # 未安裝則下載精簡版使用
    $7zrPath = Join-Path $env:TEMP "7zr.exe"
    $7zrUrls = @(
        "https://7-zip.org/a/7zr.exe",
        "https://github.com/hunandy14/Win11Update-NotVerify/raw/refs/heads/master/soft/7zr.exe"
    )
    if ((!(Test-Path $7zrPath)) -or $ForceDownload) {
        try {
            (New-Object Net.WebClient).DownloadFile($7zrUrls[0], $7zrPath)
            return $7zrPath
        } catch {
            try {
                (New-Object Net.WebClient).DownloadFile($7zrUrls[1], $7zrPath)
                return $7zrPath
            } catch {
                Write-Error "Failed to download 7-Zip from both primary and backup sources" -ErrorAction $ErrorActionPreference
            }
        }
    }
} # Initialize-7zEnvironment -ForceDownload -ErrorAction Stop; Write-Host "7zr.exe 下載完成"



# 跳過 Windows11 更新的硬體限制
function Install-Windows11Bypass {
    [CmdletBinding()]
    param (
        [string] $IsoFile
    )
    # 初始化 7zr
    $7zrPath = Initialize-7zEnvironment -ForceDownload -ErrorAction Stop
    $WinPath = "${env:Temp}\Win11_ISO"
    $warpperUrl = "https://github.com/hunandy14/Win11Update-NotVerify/raw/refs/heads/master/bypass11/Win11-24H2-Warpper.zip"
    $warpperPath = "${env:Temp}\$([IO.Path]::GetFileName($warpperUrl))"

    # 下載 ISO-Warpper
    try {
        (New-Object Net.WebClient).DownloadFile($warpperUrl, $warpperPath)
    } catch {
        Write-Error "Failed to download Win11-Warpper package: $($_.Exception.Message)" -ErrorAction Stop
    }
    
    # 解壓縮 ISO
    & $7zrPath x $IsoFile -o"$WinPath" -y
    & $7zrPath x $warpperPath -o"$WinPath" -y
    
    # 開啟安裝程式
    Start-Process -FilePath "setup.exe" -WorkingDirectory $WinPATH
} # Install-Windows11Bypass -IsoFile:"C:\Users\User\Desktop\Win11_24H2_Chinese_Traditional_x64.iso"



# 安裝 Windows PC Health Check Setup
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
