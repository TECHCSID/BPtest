$rand = New-Object System.Random
Start-Sleep $rand.next(10,120)

$url = "http://deploiement-rg.septeocloud.com/secib/speedtest.exe"
$output = "$ C:\speedtest.exe"
$outputzip = "$env:tmp\BPTest\"
    
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $url -OutFile $output

[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
[System.IO.Compression.ZipFile]::ExtractToDirectory($output, $outputzip)

Start-Process cmd -Verb RunAs -WindowStyle Hidden -ArgumentList "/c", "del c:\speedtest.exe /q"

.$env:tmp\BPTest\speedtest.exe --accept-license --accept-gdpr > $env:tmp\BPTest\result.txt

$resultTmp = (Select-String -Path $env:tmp\BPTest\result.txt -Pattern Latency,Download,Upload) -replace '\s',''
$resultLA = ($resultTmp -split ':')[4]
$resultDN = ((($resultTmp -split ':')[9]) -split '\(')[0]
$resultUP = ((($resultTmp -split ':')[15]) -split '\(')[0]

write-output "Ping : $resultLA Down : $resultDN Up : $resultUP"

Start-Process cmd -Verb RunAs -WindowStyle Hidden -ArgumentList "/c", "rd C:\Windows\Temp\BPTest\ /q /s"
