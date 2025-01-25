# 初始化 7z 環境
function Initialize-7zEnvironment {
    [CmdletBinding()]
    param (
        [switch] $ForceDownload
    )

    # 如果已安裝直接使用
    # $7zPath = Join-Path $env:ProgramFiles "7-Zip\7z.exe"
    # if (Test-Path $7zPath) { return $7zPath }
    
    # 下載免安裝板使用
    $7zPath = Join-Path $env:TEMP "7-Zip\7z.exe"
    $7zUrl = "https://github.com/hunandy14/Win11Update-NotVerify/raw/refs/heads/master/soft/7-Zip2409.zip"
    if ((!(Test-Path $7zPath)) -or $ForceDownload) {
        try {
            (New-Object Net.WebClient).DownloadFile($7zUrl, "$env:TEMP\7-Zip2409.zip")
            Expand-Archive -Path "$env:TEMP\7-Zip2409.zip" -DestinationPath "$env:TEMP" -Force
            return $7zPath
        } catch {
            Write-Error "Failed to download and extract 7-Zip package" -ErrorAction $ErrorActionPreference
        }
    }
} # Initialize-7zEnvironment -ForceDownload -ErrorAction Stop; Write-Host "7zr.exe 下載完成"



# 跳過 Windows11 更新的硬體限制
function Install-Windows11Bypass {
    [Alias('BypassWin11')]
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory)]
        [ValidateScript({Test-Path $_})]
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
    if (!(Test-Path $WinPath)) { New-Item -ItemType Directory -Path $WinPath -Force | Out-Null }
    Write-Host "正在解壓縮 Windows 11 ISO '$IsoFile' 檔案..." -ForegroundColor DarkCyan
    Write-Host "  解壓縮位置: $WinPath" -ForegroundColor DarkCyan
    & $7zrPath x $IsoFile -o"$WinPath" -y
    & $7zrPath x $warpperPath -o"$WinPath" -y
    
    # 開啟安裝程式
    Start-Process -FilePath "setup.exe" -WorkingDirectory $WinPath
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
