#https://www.speedtest.net/apps/cli
cls

$DownloadURL = "https://install.speedtest.net/app/cli/ookla-speedtest-1.0.0-win64.zip"
#location to save on the computer. Path must exist or it will error
$DOwnloadPath = "c:\temp\SpeedTest.Zip"
$ExtractToPath = "c:\temp\SpeedTest"
$SpeedTestEXEPath = "C:\temp\SpeedTest\speedtest.exe"
#Log File Path
$LogPath = 'c:\temp\SpeedTestLog.txt'

#Start Logging to a Text File
$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path $LogPath -Append:$false
#check for and delete existing log files

function RunTest()
{
    $test = & $SpeedTestEXEPath --accept-license
    $test
}

$resultTmp = (Select-String -Path $env:temp\SpeedTestLog.txt -Pattern Latency,Download,Upload) -replace '\s',''
$resultLA = ($resultTmp -split ':')[4]
$resultDN = ((($resultTmp -split ':')[9]) -split '\(')[0]
$resultUP = ((($resultTmp -split ':')[15]) -split '\(')[0]

write-output "Ping : $resultLA Down : $resultDN Up : $resultUP"

#check if file exists
if (Test-Path $SpeedTestEXEPath -PathType leaf)
{
    Write-Host "SpeedTest EXE Exists, starting test" -ForegroundColor Green
    RunTest
}
else
{
    Write-Host "SpeedTest EXE Doesn't Exist, starting file download"

    #downloads the file from the URL
    wget $DownloadURL -outfile $DOwnloadPath

    #Unzip the file
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    function Unzip
    {
        param([string]$zipfile, [string]$outpath)

        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
    }

    Unzip $DOwnloadPath $ExtractToPath
    RunTest
}


#get hostname
$Hostname = hostname

#stop logging
Stop-Transcript
exit 0
