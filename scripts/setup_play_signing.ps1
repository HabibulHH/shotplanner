param(
    [string]$Keytool = "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$androidRoot = Join-Path $projectRoot "android"
$keystoreDir = Join-Path $androidRoot "keystore"
$keystorePath = Join-Path $keystoreDir "shotkit-upload.jks"
$propertiesPath = Join-Path $androidRoot "key.properties"

if (-not (Test-Path -LiteralPath $Keytool)) {
    throw "keytool was not found at $Keytool"
}
if ((Test-Path -LiteralPath $keystorePath) -or
    (Test-Path -LiteralPath $propertiesPath)) {
    throw "Signing files already exist. Nothing was overwritten."
}

New-Item -ItemType Directory -Path $keystoreDir -Force | Out-Null
$randomBytes = New-Object byte[] 32
$randomGenerator = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$randomGenerator.GetBytes($randomBytes)
$randomGenerator.Dispose()
$password = [BitConverter]::ToString($randomBytes).Replace("-", "").ToLowerInvariant()

& $Keytool -genkeypair `
    -keystore $keystorePath `
    -storepass $password `
    -keypass $password `
    -alias "shotkit-upload" `
    -keyalg RSA `
    -keysize 4096 `
    -validity 10000 `
    -dname "CN=ShotKit Upload Key, OU=Mobile, O=AppMachine, C=BD"

if ($LASTEXITCODE -ne 0) {
    throw "keytool failed with exit code $LASTEXITCODE"
}

$properties = @(
    "storePassword=$password"
    "keyPassword=$password"
    "keyAlias=shotkit-upload"
    "storeFile=../keystore/shotkit-upload.jks"
)
[System.IO.File]::WriteAllLines($propertiesPath, $properties)

Write-Host "ShotKit upload signing is configured."
Write-Host "Back up both files securely before publishing:"
Write-Host "  $keystorePath"
Write-Host "  $propertiesPath"
