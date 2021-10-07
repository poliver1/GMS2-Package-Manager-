#ASSET PATHS
$current_folder = $PSScriptRoot
$gml_file       = "$current_folder\GMLIB.gml"
$yy_file        = "$current_folder\GMLIB.yy"

#PROJECTS FOLDER
$projects_folder = "C:\Users\kewne\Documents\GameMakerStudio2"

#GET PROJECTS
$projects = Get-ChildItem -Path $projects_folder

foreach ($project in $projects) {

    if (Test-Path -Path "$projects_folder\$project\scripts") {
        #if scripts folder in project exists, create or overwrite the GMLIB files
        Copy-Item $current_folder -Destination "$projects_folder\$project\scripts\" -force
        Copy-Item $gml_file       -Destination "$projects_folder\$project\scripts\GMLIB\" -force
        Copy-Item $yy_file        -Destination "$projects_folder\$project\scripts\GMLIB\" -force
        #place the GMLIB script into root level
        (Get-Content "$projects_folder\$project\scripts\GMLIB\GMLIB.yy").replace('CURRENT_PROJECT', $project) | Set-Content "$projects_folder\$project\scripts\GMLIB\GMLIB.yy"
    }
    else {
        #if scripts folder in project doesn't exist, create the folder and copy the GMLIB files
        New-Item -Path "$projects_folder\$project\" -Name scripts -ItemType Directory
        Copy-Item $current_folder -Destination "$projects_folder\$project\scripts\"
        Copy-Item $gml_file       -Destination "$projects_folder\$project\scripts\GMLIB\"
        Copy-Item $yy_file        -Destination "$projects_folder\$project\scripts\GMLIB\"
        #place the GMLIB script into root level
        (Get-Content "$projects_folder\$project\scripts\GMLIB\GMLIB.yy").replace('CURRENT_PROJECT', $project) | Set-Content "$projects_folder\$project\scripts\GMLIB\GMLIB.yy"
    }

    #add reference to GMLIB script to the project file
    $yyp_file = "$projects_folder\$project\$project.yyp"
    $resource = '{"id":{"name":"GMLIB","path":"scripts/GMLIB/GMLIB.yy",},"order":'

    $entry = Select-String -Path $yyp_file -Pattern $resource
    if ($entry -eq $null) {
        #adding the resource
[LIST]
[*]        $NewContent = Get-Content -Path $yyp_file |
[/LIST]
        ForEach-Object {
            $_
            if($_ -match ('^' + [regex]::Escape('  "resources": ['))) {
                "    $resource"
            }
        }
        $NewContent | Out-File -FilePath $yyp_file -Encoding Default -Force
    }
}
