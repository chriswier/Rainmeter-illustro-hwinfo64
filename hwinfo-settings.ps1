# user changeable variables
#$use_hwinfo64_colors = $true
$map = @{
    "AMD Ryzen 9 5900X" = "CPU";
    "ASUS B550-F Gaming" = "Motherboard";
    "Seagate ST8000DM004 8TB" = "Disk";
    "Samsung 980 PRO 2TB" = "Disk";
    "ADATA SX8200PNP 2TB" = "Disk";
    "AMD Radeon RX 6400" = "GPU";
    "NVIDIA GeForce RTX 3080" = "GPU";
}

# setup internal variables to hold things
$categories = [ordered]@{}
$measures = @{}
$configs = @{
    "CPU" = "";
    "Motherboard" = "";
    "Disk" = "";
    "GPU" = "";
}
$yvalues = @{
    "CPU" = 12;
    "Motherboard" = 12;
    "Disk" = 12;
    "GPU" = 12;
}
$index = 0
$sensorloop = $true
$bailout = $false

# source of the sensors
$exists = Get-ItemProperty -Path HKCU:\Software\HWiNFO64\VSB -ErrorAction SilentlyContinue
if (($null -eq $exists) -or ($exists.Length -eq 0)) {
    Write-Host "Registry key HKCU:\Software\HWiNFO64\VSB does not exist.  Check your HWiNFO64 setup.  Cannot continue."
    $bailout = $true
} 

if($bailout -eq $false) {

    # get the sensors!
    $sensors = Get-ItemProperty -Path HKCU:\Software\HWiNFO64\VSB

    # template
    $template = @"
; Lines starting ; (semicolons) are commented out.
; That is, they do not affect the code and are here for demonstration purposes only.
; ----------------------------------

[Rainmeter]
Update=1000
DynamicWindowSize=1
Background=#@#Background.png
; #@# is equal to Rainmeter\Skins\illustro\@Resources
BackgroundMode=3
BackgroundMargins=0,34,0,14

[Metadata]
; Contains basic information of the skin.
Name=System
Author=Chris Wieringa <chris@wieringafamily.com>
Information=Displays HWiNFO64 states
License=Creative Commons BY-NC-SA 3.0
Version=1.0.0

[Variables]
; Variables declared here can be used later on between two # characters (e.g. #MyVariable#).
fontName=Trebuchet MS
textSize=8
colorBar=235,170,0,255
colorText=255,255,255,205

; ----------------------------------
; STYLES are used to "centralize" options
; ----------------------------------

[styleTitle]
StringAlign=Center
StringCase=Upper
StringStyle=Bold
StringEffect=Shadow
FontEffectColor=0,0,0,50
FontColor=#colorText#
FontFace=#fontName#
FontSize=10
AntiAlias=1
ClipString=1

[styleLeftText]
StringAlign=Left
; Meters using styleLeftText will be left-aligned.
StringCase=None
StringStyle=Bold
StringEffect=Shadow
FontEffectColor=0,0,0,20
FontColor=#colorText#
FontFace=#fontName#
FontSize=#textSize#
AntiAlias=1
ClipString=1

[styleRightText]
StringAlign=Right
StringCase=None
StringStyle=Bold
StringEffect=Shadow
FontEffectColor=0,0,0,20
FontColor=#colorText#
FontFace=#fontName#
FontSize=#textSize#
AntiAlias=1
ClipString=1

[styleBar]
BarColor=#colorBar#
BarOrientation=HORIZONTAL
SolidColor=255,255,255,15

; ----------------------------------
; The Meters and Measures!
; ----------------------------------

"@

    # build it up
    while($sensorloop) {
        $checkSensor = "Sensor{0}" -f $index
        if($checkSensor -in $sensors.PSObject.Properties.Name) {
            $value = $sensors.$checkSensor

            # add the index to the categories
            if($categories.$value) {
                $categories[$value] += "$index"
            } else {
                $categories[$value] = (@("$index"))
            }

            $thismeasure = ""
            $thismeasure = "{0}[measure{1}Sensor]`nMeasure=Registry`nRegHKey=HKEY_CURRENT_USER`nRegKey=SOFTWARE\HWiNFO64\VSB`nRegValue=Sensor{1}`n`n" -f $thismeasure, $index 
            $thismeasure = "{0}[measure{1}Label]`nMeasure=Registry`nRegHKey=HKEY_CURRENT_USER`nRegKey=SOFTWARE\HWiNFO64\VSB`nRegValue=Label{1}`n`n" -f $thismeasure, $index 
            $thismeasure = "{0}[measure{1}Value]`nMeasure=Registry`nRegHKey=HKEY_CURRENT_USER`nRegKey=SOFTWARE\HWiNFO64\VSB`nRegValue=Value{1}`n`n" -f $thismeasure, $index
            $thismeasure = "{0}[measure{1}Color]`nMeasure=Registry`nRegHKey=HKEY_CURRENT_USER`nRegKey=SOFTWARE\HWiNFO64\VSB`nRegValue=Color{1}`n`n" -f $thismeasure, $index

            # for percentages, I want to set a minvalue and maxvalue for rawvalues
            $value = "Value{0}" -f $i
            if($sensors.$value -match "\%") {
                $minmaxvalues = "MinValue=0`nMaxValue=100`n"
            } else {
                $minmaxvalues = ""
            }
      
            # add rawvalues
            $thismeasure = "{0}[measure{1}ValueRaw]`nMeasure=Registry`nRegHKey=HKEY_CURRENT_USER`nRegKey=SOFTWARE\HWiNFO64\VSB`nRegValue=ValueRaw{1}`n{2}`n" -f $thismeasure, $index, $minmaxvalues
            

            # add it to the measures under the sensorIndex
            $measures[$checkSensor] = $thismeasure

        } else {
            $sensorloop = $false
        }
        $index++;
    }

    # go through each category, then each sensor value
    $categoryCounter = 0
    foreach($c in $categories.Keys) {

        # grab current y value
        $y = $yvalues[$map[$c]]

        # start writing the config
        $category_config = "[category{0}Title]`nMeter=String`nMeterStyle=styleTitle`nX=100`nY={1}`nW=190`nH=18`nText={2}`n`n" -f $categoryCounter, $y, $c
        $y += 28
        
        # iterate through indexes
        foreach ($i in $categories[$c]) {
            $sensorName = "Sensor{0}" -f $i
            $category_config = "{0}{1}" -f $category_config, $measures[$sensorName]
            $category_config = "{0}[meterLabel{1}]`nMeter=String`nMeasureName=measure{1}Label`nMeterStyle=styleLeftText`nX=10`nY={2}`nW=190`nH=14`nText=%1`n`n" -f $category_config, $i, $y
            $category_config = "{0}[meterValue{1}]`nMeter=String`nMeasureName=measure{1}Value`nMeterStyle=styleRightText`nX=200`nY=0r`nW=190`nH=14`nText=%1`n`n" -f $category_config, $i

            $value = "Value{0}" -f $i
            if($sensors.$value -match "\%") {
                $newy = $y + 12
                $category_config = "{0}[meterBar{1}]`nMeter=Bar`nMeasureName=measure{1}ValueRaw`nMeterStyle=styleBar`nX=10`nY={2}`nW=190`nH=1`n`n" -f $category_config, $i, $newy
                #Write-Host "match percent"
            }

            # increment y by 20
            $y += 20
        }

        # update yvalues for next iteration
        $yvalues[$map[$c]] = $y + 10

        # increment counter
        $categoryCounter++

        # store it in the configs
        $configs[$map[$c]] = "{0}{1}" -f $configs[$map[$c]], $category_config

    }


    # Write out the template files
    foreach($type in $configs.Keys) {
        $folder = "{0}\Rainmeter\Skins\illustro\HWiNFO64-{1}" -f [Environment]::GetFolderPath("MyDocuments"), $type
        $file = "{0}\HWiNFO64.ini" -f $folder

        if (Test-Path $folder) { } else {
            New-Item $folder -ItemType Directory
        }
        $fullconfig = "{0}{1}" -f $template, $configs[$type]
        $fullconfig | Out-File -FilePath $file -Force
    }
}
