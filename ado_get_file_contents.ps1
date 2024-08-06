<#
.SYNOPSIS
    This script downloads a YAML file from an Azure DevOps repository.

.DESCRIPTION
    This script uses the Azure DevOps REST API to download a specified YAML file from a given repository.
    It requires a Personal Access Token (PAT) for authentication. The script allows specifying the organization,
    project, repository, and file path. It also provides options to set the download path and output file name.

.PARAMETER pat
    The Personal Access Token (PAT) for authenticating with Azure DevOps.

.PARAMETER organization
    The name of the Azure DevOps organization.

.PARAMETER project
    The name of the Azure DevOps project. This can contain spaces.

.PARAMETER repositoryName
    The name of the repository from which to download the YAML file.

.PARAMETER yamlFilePath
    The path to the YAML file within the repository.

.PARAMETER downloadPath
    The local path where the file will be downloaded. Defaults to the current script folder.

.PARAMETER outputYamlName
    The name of the output YAML file. Defaults to "YamlDownload.yaml".

.PARAMETER outputYaml
    A flag indicating whether to output the YAML file content to a file. Defaults to $false.

.EXAMPLE
    .\ado_get_file_contents.ps1
    Downloads the specified YAML file to the current script folder with the default name.

.NOTES
    Ensure that the PAT token is kept secure and not uploaded to any public repository.
#>

# PAT token - DO NOT UPLOAD THIS
$pat = "" # 
# Replace these with your values

$organization = "ORGANIZATION"
$project = "PROJECT" # can have spaces, those will be escaped later
$repositoryName = "REPO"
$yamlFilePath = "FOLDER/FILE.YAML"
$downloadPath = ""
$outputYamlName = ""
#Output Yaml flag
$outputYaml = $false


if ([string]::IsNullOrEmpty($downloadPath)){
    $downloadPath = "./"
    Write-Host "File will be downloaded to current script folder with default name."
}

if ([string]::IsNullOrEmpty($outputYamlName)){
    $outputYamlName = "YamlDownload.yaml"
    Write-Host "File will be downloaded with default name: $($outputYamlName)"
}

$outputPath = $($yamlFilePath) + $($outputYamlName)

# Create a base64-encoded token
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($pat)"))

$fileUri = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repositoryName/items?path=$yamlFilePath&api-version=7.0"

if ($fileUri -Contains "* *"){
    $escapedYamlUri = [uri]::EscapeUriString($pipelineFileUri)
} else{
    $escapedYamlUri = $fileUri
}

Write-Host $escapedYamlUri
try{
    $yamlFile = Invoke-RestMethod -Uri $escapedYamlUri -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}

    Write-Host $yamlFile
    if ($outputYaml -eq $true){
        # this is the content of our yaml file - no response code
        Out-File -FilePath $outputPath -InputObject $yamlFile
    }

    # Check if the request was successful
    if ($null -eq $yamlFile) {
        Write-Host "Failed to fetch file content."
        Exit 1
    }
}
catch{
    Write-Host "Could not reach ADO endpoint."
}