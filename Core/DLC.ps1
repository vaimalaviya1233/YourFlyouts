

function debug {
    param(
        [Parameter()]
        [string]
        $message
    )

    $RmAPI.Bang("[!Log `"`"`"" + $message + "`"`"`" Debug]")
}
function check-update {
    # $editingModule = $RmAPI.VariableStr('Page.SubpageModule')
    $skinsPath = $RmAPI.VariableStr('SKINSPATH')
    $skinName = $RmAPI.VariableStr('Skin.Name')
    $DLCDir = "$($skinsPath.Replace('Skins\',''))CoreData\$skinName\DLC\"
    $skinDir = "$($skinsPath)$skinName"

    $fileInstalledDLCs = "$skinDir\@Resources\InstalledDLCs.inc"
    $file1 = "$skinDir\Core\DLC\Includer.inc"
    $file2 = "$skinDir\Core\Layout\Includer.inc"

    $arr = @(Get-ChildItem $DLCDir -filter *.zip | Foreach-Object -Process { [System.IO.Path]::GetFileNameWithoutExtension($_) })
    if ($arr.Length -eq 0) {
        $file1content += @"

[Item1.Shape]
Meter=Shape
MeterStyle=Item.Shape:S
[Item1.StringIcon]
Meter=String
Text=[\xe854]
MeterStyle=Set.String:S | Item.StringIcon:S
[Item1.String]
Meter=String
Text=You don't have any DLCs installed! If you've purchased it and unsure how to install, read the guide on the ko-fi page!
MeterStyle=Set.String:S | Item.String:S

"@
        $file2content = ""
        $file1content | Out-File -FilePath $file1 -Encoding unicode
        $file2content | Out-File -FilePath $file2 -Encoding unicode
        $file2content | Out-File -FilePath $fileInstalledDLCs -Encoding unicode
    }


    for ($i = 1; $i -le $arr.Length; $i++) {
        if ([string]::IsNullOrEmpty($RmAPI.VariableStr($arr[$i - 1]))) {


            for ($i = 1; $i -le $arr.Length; $i++) {
                $iName = $arr[$i - 1]
                debug $iName
                
                $RmAPI.Bang("[!WriteKeyValue Variables $iName $(-join ((48..57) + (97..122) | Get-Random -Count 32 | % {[char]$_})) `"`"`"$fileInstalledDLCs`"`"`"]")
                Expand-Archive -Path "$DLCDir$iName.zip" -DestinationPath "$skinDir\" -Force -Verbose

                $file1content += @"

[$iName.Shape]
Meter=Shape
MeterStyle=Item.Shape:S
[$iName.StringIcon]
Meter=String
Text=[\xf091]
MeterStyle=Set.String:S | Item.StringIcon:S
[$iName.String]
Meter=String
Text=$iName - $skinName
MeterStyle=Set.String:S | Item.String:S

"@
                $file2content += @"

[$iName.Shape]
Meter=Shape
MeterStyle=Module.Shape:S
[$iName.Image]
Meter=Image
MeterStyle=Module.Image:S
[$iName.String]
Meter=String
MEterStyle=Set.String:S | Module.STring:S
[$iName.Description.String]
Meter=String
Text=Default layout for the $iName DLC
MEterStyle=Set.String:S | Module.Description.STring:S

"@
                #                 $moduleNames = @(Get-ChildItem "$skinDir\Core\Module" | Where-Object { $_.Name -match "^$iName" } | Foreach-Object -Process { [System.IO.Path]::GetFileNameWithoutExtension($_) })
                #                 for ($j = 1; $j -le $moduleNames.Length; $j++) {
                #                     $mo = $j % 3
                #                     $file3content += @"
                
                # [$($moduleNames[$j-1]).Shape]
                # Meter=Shape
                # "@
                #                     if ($mo -eq 1) {
                #                         $file3content += @"

                # X=(#SEc.P#)
                # Y=(#Sec.P#*2)r
                # "@
                #                     }
                #                     $file3content += @"

                # MeterStyle=DLC.Shape:S
                # [$($moduleNames[$j-1]).Image]
                # Meter=Image
                # MeterStyle=DLC.Image:S
                # [$($moduleNames[$j-1]).String]
                # Meter=String
                # MEterStyle=Sec.String:S | DLC.STring:S
                # "@
                #                 }

                #                 $file3content += @"
                
                # [AnchorSuppli]
                # Meter=String
                # Container=ContentContainer
                # x=r
                # Y=R

                # "@
                $file1content | Out-File -FilePath $file1 -Encoding unicode
                $file2content | Out-File -FilePath $file2 -Encoding unicode
            }

            
            break
        }
    }

    $RmAPI.Bang("[!Delay 1000][!WriteKeyvalue Variables page.page 1 `"$skinDir\Core\DLC.inc`"][!Refresh]")
}

function moveDLC($path) {
    $skinsPath = $RmAPI.VariableStr('SKINSPATH')
    $skinName = $RmAPI.VariableStr('Skin.Name')
    $DLCDir = "$($skinsPath.Replace('Skins\',''))CoreData\$skinName\DLC\"
    $skinDir = "$($skinsPath)$skinName"
    debug $path
    Move-Item -Path $path -Destination $DLCDir
    $RmAPI.Bang("[!Delay 500][!WriteKeyvalue Variables page.page 0 `"$skinDir\Core\DLC.inc`"][!Refresh]")
}