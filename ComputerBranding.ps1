<#
.SYNOPSIS
	Set Wallpaper and LockScreen in Windows 10 Enterprise downloading file from a site. (In my case Azure Blob).

.DESCRIPTION
	This script will replace The Lockdown and Desktop and images.
	Follow Per Larsen's guide on how to create Azure Blob & get the shared access signature.
	https://osddeployment.dk/2019/04/14/how-to-set-windows-10-lock-screen-and-background-picture-with-intune/
	@PerLarsen1975

.NOTES
	Version: 1.0
	Author: Bruce Sa
	Twitter: @BruceSaaaa
	Creation date: 04-15-2019
	

.LINK
	https://github.com/brucesa85/Powershell-Scripts
#>

#Set your image location ex: "https://mysite.blob.core.windows.net/w"
$LockScreenSource = "https://picturelink"
$BackgroundSource = "https://picturelink"

if (-not [string]::IsNullOrWhiteSpace($LogPath)) {
    Start-Transcript -Path "$($LogPath)\$($env:COMPUTERNAME).log" | Out-Null
}

$ErrorActionPreference = "Stop"

$RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"

$DesktopPath = "DesktopImagePath"
$DesktopStatus = "DesktopImageStatus"
$DesktopUrl = "DesktopImageUrl"
$LockScreenPath = "LockScreenImagePath"
$LockScreenStatus = "LockScreenImageStatus"
$LockScreenUrl = "LockScreenImageUrl"

$StatusValue = "1"
$DesktopImageValue = "C:\Windows\System32\oobe\Desktop.jpg"
$LockScreenImageValue = "C:\Windows\System32\oobe\LockScreen.jpg"

if (!$LockScreenSource -and !$BackgroundSource) 
{
    Write-Host "Either LockScreenSource or BackgroundSource must has a value."
}
else 
{
    if(!(Test-Path $RegKeyPath)) {
        Write-Host "Creating registry path $($RegKeyPath)."
        New-Item -Path $RegKeyPath -Force | Out-Null
    }
    if ($LockScreenSource) {
        Write-Host "Copy Lock Screen image from $($LockScreenSource) to $($LockScreenImageValue)."
        (New-Object System.Net.WebClient).DownloadFile($LockScreenSource, "$LockScreenImageValue")
        Write-Host "Creating registry entries for Lock Screen"
        New-ItemProperty -Path $RegKeyPath -Name $LockScreenStatus -Value $StatusValue -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $RegKeyPath -Name $LockScreenPath -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null
        New-ItemProperty -Path $RegKeyPath -Name $LockScreenUrl -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null
    }
    if ($BackgroundSource) {
        Write-Host "Copy Desktop Background image from $($BackgroundSource) to $($DesktopImageValue)."
        (New-Object System.Net.WebClient).DownloadFile($BackgroundSource, "$DesktopImageValue")
        Write-Host "Creating registry entries for Desktop Background"
        New-ItemProperty -Path $RegKeyPath -Name $DesktopStatus -Value $StatusValue -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $RegKeyPath -Name $DesktopPath -Value $DesktopImageValue -PropertyType STRING -Force | Out-Null
        New-ItemProperty -Path $RegKeyPath -Name $DesktopUrl -Value $DesktopImageValue -PropertyType STRING -Force | Out-Null
    }  
}
if (-not [string]::IsNullOrWhiteSpace($LogPath)){Stop-Transcript}
