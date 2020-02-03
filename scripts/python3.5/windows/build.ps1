# This script builds a Cura release using the cura-build-environment Windows docker image.

param (
# Docker parameters
  [string]$DockerImage = "ultimaker/cura-build-environment:win1809-latest",

# Branch parameters
  [string]$CuraBranchOrTag = "master",
  [string]$UraniumBranchOrTag = "master",
  [string]$CuraEngineBranchOrTag = "master",
  [string]$CuraBinaryDataBranchOrTag = "master",
  [string]$FdmMaterialsBranchOrTag = "master",
  [string]$LibCharonBranchOrTag = "master",

# Cura release parameters
  [Parameter(Mandatory=$true)]
    [int32]$CuraVersionMajor,
  [Parameter(Mandatory=$true)]
    [int32]$CuraVersionMinor,
  [Parameter(Mandatory=$true)]
    [int32]$CuraVersionPatch,
  [string]$CuraVersionExtra = "",

  [string]$CuraBuildType = "",
  [string]$NoInstallPlugins = "",

  [Parameter(Mandatory=$true)]
    [string]$CloudApiRoot = "https://api.ultimaker.com",
  [Parameter(Mandatory=$true)]
    [string]$CloudAccountApiRoot = "https://account.ultimaker.com",
  [Parameter(Mandatory=$true)]
    [int32]$CloudApiVersion = 1,

  [boolean]$EnableDebugMode = $true,
  [boolean]$EnableCuraEngineExtraOptimizationFlags = $true,

  [Parameter(Mandatory=$true)]
    [string]$CuraWindowsInstallerType = "EXE",

  [string]$CuraMsiProductGuid = "",
  [string]$CuraMsiUpgradeGuid = "",

  [boolean]$IsInteractive = $true,
  [boolean]$BindSshVolume = $false
)

$ErrorActionPreference = "Stop"

$outputDirName = "windows-installers"
$buildOutputDirName = "build"

New-Item $outputDirName -ItemType "directory" -Force
$repoRoot = Join-Path $PSScriptRoot -ChildPath "..\..\.." -Resolve
$outputRoot = Join-Path (Get-Location).Path -ChildPath $outputDirName -Resolve

$CURA_DEBUG_MODE = "OFF"
if ($EnableDebugMode) {
  $CURA_DEBUG_MODE = "ON"
}

$CURAENGINE_ENABLE_MORE_COMPILER_OPTIMIZATION_FLAGS = "OFF"
if ($EnableCuraEngineExtraOptimizationFlags) {
  $CURAENGINE_ENABLE_MORE_COMPILER_OPTIMIZATION_FLAGS = "ON"
}

if ($CuraWindowsInstallerType -eq "EXE") {
  $CPACK_GENERATOR = "NSIS"
}
elseif ($CuraWindowsInstallerType -eq "MSI") {
  $CPACK_GENERATOR = "WIX"
  if ($CuraMsiProductGuid -eq "" -Or $CuraMsiUpgradeGuid -eq "") {
    Write-Error `
      -Message "Missing CuraMsiProductGuid or CuraMsiUpgradeGuid." `
      -Category InvalidArgument
    exit 1
  }
}
else {
  Write-Error `
    -Message "Invalid value [$CuraWindowsInstallerType] for CuraWindowsInstallerType. Must be EXE or MSI" `
    -Category InvalidArgument
  exit 1
}

$dockerExtraArgs = New-Object Collections.Generic.List[String]
if ($IsInteractive) {
  $dockerExtraArgs.Add("-it")
}

if ($BindSshVolume) {
  $oldPath = pwd
  cd ~
  $homePath = pwd
  cd $oldPath
  $sshPath = "$homePath\.ssh"
  $dockerExtraArgs.Add("--volume")
  $dockerExtraArgs.Add("${sshPath}:C:\Users\ContainerAdministrator\.ssh")
}

& docker.exe run $dockerExtraArgs `
  --rm `
  --volume ${repoRoot}:C:\cura-build-src `
  --volume ${outputRoot}:C:\cura-build-output `
  --env CURA_BUILD_SRC_PATH=C:\cura-build-src `
  --env CURA_BUILD_OUTPUT_PATH=C:\cura-build-output `
  --env CURA_BRANCH_OR_TAG=$CuraBranchOrTag `
  --env URANIUM_BRANCH_OR_TAG=$UraniumBranchOrTag `
  --env CURAENGINE_BRANCH_OR_TAG=$CuraEngineBranchOrTag `
  --env CURABINARYDATA_BRANCH_OR_TAG=$CuraBinaryDataBranchOrTag `
  --env FDMMATERIALS_BRANCH_OR_TAG=$FdmMaterialsBranchOrTag `
  --env LIBCHARON_BRANCH_OR_TAG=$LibCharonBranchOrTag `
  --env CURA_VERSION_MAJOR=$CuraVersionMajor `
  --env CURA_VERSION_MINOR=$CuraVersionMinor `
  --env CURA_VERSION_PATCH=$CuraVersionPatch `
  --env CURA_VERSION_EXTRA=$CuraVersionExtra `
  --env CURA_BUILD_TYPE=$CuraBuildType `
  --env CURA_NO_INSTALL_PLUGINS=$NoInstallPlugins `
  --env CURA_CLOUD_API_ROOT=$CuraCloudApiRoot `
  --env CURA_CLOUD_API_VERSION=$CuraCloudApiVersion `
  --env CURA_CLOUD_ACCOUNT_API_ROOT=$CuraCloudAccountApiRoot `
  --env CURA_DEBUG_MODE=$CURA_DEBUG_MODE `
  --env CURAENGINE_ENABLE_MORE_COMPILER_OPTIMIZATION_FLAGS=$CURAENGINE_ENABLE_MORE_COMPILER_OPTIMIZATION_FLAGS `
  --env CPACK_GENERATOR=$CPACK_GENERATOR `
  --env CURA_MSI_PRODUCT_GUID=$CuraMsiProductGuid `
  --env CURA_MSI_UPGRADE_GUID=$CuraMsiUpgradeGuid `
  $DockerImage `
  powershell.exe -Command cmd /c "C:\cura-build-src\scripts\python3.5\windows\build_in_docker_vs2015.cmd"
