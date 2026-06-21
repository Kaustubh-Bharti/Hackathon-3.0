# SystemPulse - Standalone Windows PowerShell Script
# No Node.js required. Runs native commands only.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File system-info.ps1
#
# Output: system-info.json in the same directory.

$ErrorActionPreference = "SilentlyContinue"

Write-Host ""
Write-Host "  SystemPulse -- Gathering system info via PowerShell..." -ForegroundColor Magenta
Write-Host ""

# -- OS --
$os = Get-CimInstance Win32_OperatingSystem
$cs = Get-CimInstance Win32_ComputerSystem

$osName      = if ($os.Caption)        { $os.Caption.Trim() }       else { "N/A" }
$osVersion   = if ($os.Version)        { $os.Version }              else { "N/A" }
$osBuild     = if ($os.BuildNumber)    { $os.BuildNumber }          else { "N/A" }
$osArch      = if ($os.OSArchitecture) { $os.OSArchitecture }       else { "N/A" }
$hostname    = if ($cs.Name)           { $cs.Name }                 else { hostname }

# -- CPU --
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1

$cpuModel    = if ($cpu.Name)                      { $cpu.Name.Trim() }                else { "N/A" }
$cpuCores    = if ($cpu.NumberOfCores)              { $cpu.NumberOfCores }               else { "N/A" }
$cpuLogical  = if ($cpu.NumberOfLogicalProcessors)  { $cpu.NumberOfLogicalProcessors }   else { "N/A" }
$cpuSpeed    = if ($cpu.MaxClockSpeed)              { "$($cpu.MaxClockSpeed) MHz" }      else { "N/A" }

# -- Memory --
$totalMem    = [math]::Round($os.TotalVisibleMemorySize * 1024)
$freeMem     = [math]::Round($os.FreePhysicalMemory * 1024)
$usedMem     = $totalMem - $freeMem
$usagePct    = if ($totalMem -gt 0) { [math]::Round((1 - $freeMem / $totalMem) * 100, 1) } else { 0 }

function Format-Bytes($bytes) {
    if ($bytes -ge 1TB) { return "{0:N2} TB" -f ($bytes / 1TB) }
    if ($bytes -ge 1GB) { return "{0:N2} GB" -f ($bytes / 1GB) }
    if ($bytes -ge 1MB) { return "{0:N2} MB" -f ($bytes / 1MB) }
    if ($bytes -ge 1KB) { return "{0:N2} KB" -f ($bytes / 1KB) }
    return "$bytes Bytes"
}

# -- Disk --
$disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    @{
        drive      = $_.DeviceID
        filesystem = if ($_.FileSystem) { $_.FileSystem } else { "N/A" }
        total      = Format-Bytes $_.Size
        free       = Format-Bytes $_.FreeSpace
    }
}

# -- Uptime --
$bootTime = $os.LastBootUpTime
$uptime   = if ($bootTime) { (New-TimeSpan -Start $bootTime -End (Get-Date)).ToString("d\d\ h\h\ m\m\ s\s") } else { "N/A" }

# -- User --
$username = $env:USERNAME
$homedir  = $env:USERPROFILE

# -- Network --
$networkRaw = ipconfig | Out-String
if ($networkRaw.Length -gt 2000) { $networkRaw = $networkRaw.Substring(0, 2000) }

# -- Environment Variables --
$envVarNames = @(
    "PATH", "USERNAME", "COMPUTERNAME", "USERPROFILE", "OS",
    "PROCESSOR_ARCHITECTURE", "NUMBER_OF_PROCESSORS", "APPDATA",
    "LOCALAPPDATA", "TEMP", "SYSTEMROOT", "PROGRAMFILES", "COMSPEC",
    "JAVA_HOME", "NODE_ENV"
)

$envVars = @{}
foreach ($name in $envVarNames) {
    $val = [Environment]::GetEnvironmentVariable($name)
    $envVars[$name] = @{
        value     = if ($val) { $val } else { $null }
        available = [bool]$val
    }
}

# -- Build JSON --
$result = @{
    _meta = @{
        generated_at      = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        generator         = "SystemPulse (PowerShell, no Node.js)"
        detected_platform = "Windows"
        commands_used     = "Get-CimInstance, ipconfig, hostname"
    }
    system = @{
        os_name            = $osName
        os_version         = $osVersion
        os_build           = $osBuild
        os_arch            = $osArch
        hostname           = $hostname
        cpu_model          = $cpuModel
        cpu_physical_cores = $cpuCores
        cpu_logical_cores  = $cpuLogical
        cpu_max_speed      = $cpuSpeed
        mem_total          = Format-Bytes $totalMem
        mem_used           = Format-Bytes $usedMem
        mem_free           = Format-Bytes $freeMem
        mem_usage_percent  = "$usagePct%"
        uptime             = $uptime
        disks              = $disks
    }
    user = @{
        username       = $username
        home_directory = $homedir
    }
    environment_variables = $envVars
}

$json = $result | ConvertTo-Json -Depth 5

# -- Save with unique name: {hostname}_{timestamp}.json --
$ts = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH-mm-ss")
$outName = "$($hostname)_$($ts).json"
$outPath = Join-Path $PSScriptRoot $outName
$json | Out-File -FilePath $outPath -Encoding utf8

# -- Console Display --
$sep = "-" * 50

Write-Host "  $sep" -ForegroundColor Cyan
Write-Host "    Operating System" -ForegroundColor Magenta
Write-Host "  $sep" -ForegroundColor Cyan
Write-Host "  |  OS Name                      $osName" -ForegroundColor White
Write-Host "  |  Version                      $osVersion" -ForegroundColor White
Write-Host "  |  Build                        $osBuild" -ForegroundColor White
Write-Host "  |  Architecture                 $osArch" -ForegroundColor White
Write-Host "  |  Hostname                     $hostname" -ForegroundColor White

Write-Host ""
Write-Host "  $sep" -ForegroundColor Cyan
Write-Host "    CPU" -ForegroundColor Magenta
Write-Host "  $sep" -ForegroundColor Cyan
Write-Host "  |  Model                        $cpuModel" -ForegroundColor White
Write-Host "  |  Physical Cores               $cpuCores" -ForegroundColor White
Write-Host "  |  Logical Cores                $cpuLogical" -ForegroundColor White
Write-Host "  |  Max Speed                    $cpuSpeed" -ForegroundColor White

Write-Host ""
Write-Host "  $sep" -ForegroundColor Cyan
Write-Host "    Memory" -ForegroundColor Magenta
Write-Host "  $sep" -ForegroundColor Cyan
Write-Host "  |  Total                        $(Format-Bytes $totalMem)" -ForegroundColor White
Write-Host "  |  Used                         $(Format-Bytes $usedMem)" -ForegroundColor White
Write-Host "  |  Free                         $(Format-Bytes $freeMem)" -ForegroundColor White
Write-Host "  |  Usage                        $usagePct%" -ForegroundColor White

Write-Host ""
Write-Host "  $sep" -ForegroundColor Cyan
Write-Host "    User" -ForegroundColor Magenta
Write-Host "  $sep" -ForegroundColor Cyan
Write-Host "  |  Username                     $username" -ForegroundColor White
Write-Host "  |  Home Directory               $homedir" -ForegroundColor White

Write-Host ""
Write-Host "  $sep" -ForegroundColor Cyan
Write-Host "    Environment Variables" -ForegroundColor Magenta
Write-Host "  $sep" -ForegroundColor Cyan
foreach ($name in $envVarNames) {
    $val = $envVars[$name].value
    if ($val -and $val.Length -gt 60) { $val = $val.Substring(0,57) + "..." }
    if (-not $val) { $val = "(not available)" }
    $line = "  |  {0,-28} {1}" -f $name, $val
    Write-Host $line -ForegroundColor White
}

Write-Host ""
Write-Host "  [OK] Report saved to: $outPath" -ForegroundColor Green
Write-Host ""
