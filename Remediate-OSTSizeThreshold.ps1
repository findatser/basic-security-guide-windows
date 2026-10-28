$officeVersion = '16.0'
$unlimitedValue = [UInt32]2147483647
$registryRoots = @(
    'HKCU:\Software\Policies\Microsoft\Office',
    'HKCU:\Software\Microsoft\Office'
)

$outlookInstalled = $false
$officePaths = @(
    "$env:ProgramFiles\Microsoft Office\root\Office16\OUTLOOK.EXE",
    "$env:ProgramFiles(x86)\Microsoft Office\root\Office16\OUTLOOK.EXE",
    "$env:ProgramFiles\Microsoft Office\Office16\OUTLOOK.EXE",
    "$env:ProgramFiles(x86)\Microsoft Office\Office16\OUTLOOK.EXE",
    "$env:ProgramFiles\Common Files\Microsoft Shared\ClickToRun\OfficeClickToRun.exe",
    "$env:ProgramFiles(x86)\Common Files\Microsoft Shared\ClickToRun\OfficeClickToRun.exe"
)

foreach ($path in $officePaths) {
    if (Test-Path $path) {
        $outlookInstalled = $true
        break
    }
}

if (-not $outlookInstalled) {
    Write-Output 'Microsoft 365 Outlook is not installed; no remediation required.'
    exit 0
}

foreach ($root in $registryRoots) {
    $baseKey = Join-Path $root $officeVersion
    $outlookKey = Join-Path $baseKey 'Outlook'
    $ostKey = Join-Path $outlookKey 'OST'

    if (-not (Test-Path $outlookKey)) {
        New-Item -Path $outlookKey -Force | Out-Null
    }

    if (-not (Test-Path $ostKey)) {
        New-Item -Path $ostKey -Force | Out-Null
    }

    Set-ItemProperty -Path $ostKey -Name 'MaxLargeFileSize' -Type DWord -Value $unlimitedValue -Force
    Set-ItemProperty -Path $ostKey -Name 'WarnLargeFileSize' -Type DWord -Value $unlimitedValue -Force

    Write-Output "Configured $ostKey with MaxLargeFileSize=$unlimitedValue and WarnLargeFileSize=$unlimitedValue"
}

Write-Output 'Microsoft 365 Outlook OST threshold remediation completed successfully.'
exit 0
