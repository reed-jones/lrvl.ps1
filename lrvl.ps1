###########################
# lrvl.ps1 by Reed Jones
# Laravel installer
# Jan 20, 2018
###########################

param(
  [string] $vm,
  [string] $new
)

# Prefered development TLD
$tld = '.test'

# startup routine
function startUp {
  If (!$vm -and $new) {
    If ([System.IO.File]::Exists("$((Get-Item -Path ".\" -Verbose).FullName)\Homestead.yaml")) {
      & Write-Host "You already seem to be in a Laravel project folder..."
      exit
    }
    newProject
  }
  ElseIf (!$new -and $vm) {
    If (![System.IO.File]::Exists("$((Get-Item -Path ".\" -Verbose).FullName)\Homestead.yaml")) {
      & Write-Host "This doesn't seem to be a valid Homestead (Laravel) folder..."
      exit
    }
    vagrantController
  }
  Else {
    Write-Host "Sorry, command not understood. Options include:
    -new {siteName}
    -vm {go/halt/status/destroy}"
  }
}

# Vagrant Controls
$siteUrl = $(Get-Location | Split-Path -Leaf)
function vagrantController {
  switch -regex ($vm) {
    "^up?$" { vagrantUp }
    "^go?$" { vagrantGo }
    "^h(alt)?$" { vagrantHalt }
    "^s(sh)?$" { vagrantSSH }
    "^st(atus)?$" { vagrantStatus }
    "^r(eprovision)?$" { vagrantReprovision }
    "^d(estroy)?$" { vagrantDestroy }
    default { & Write-Host "vagrant command not understood" }
  }
}

# vagrant wrapper functions
function vagrantUp {
  & Write-Host "vagrant up"
  & vagrant up
}

function vagrantGo {
  & Write-Host "vagrant starting"
  & vagrant up
  # open URL in default browser
  & echo "Website available at http://$($siteurl)$($tld)"
  (New-Object -Com Shell.Application).Open("http://$($siteurl)$($tld)")
  & vagrantSSH
}

function vagrantHalt {
  & Write-Host "vagrant Halt"
  & vagrant halt
}

function vagrantReprovision {
  & Write-Host "vagrant re-provisioning"
  & vagrant reload --provision
}

function vagrantSSH {
  & Write-Host "vagrant ssh"
  & vagrant ssh
}

function vagrantStatus {
  & Write-Host "vagrant status"
  & vagrant status
}

function vagrantDestroy {
  & Write-Host "vagrant destroying"
  & vagrant destroy --force
}

# Laravel Create New Project
function newProject {

  #  Create new laravel project
  & composer  create-project --prefer-dist laravel/laravel $new

  # cd into new folder
  & Set-Location $new

  # install homestead
  & composer require laravel/homestead --dev

  # init homestead
  & vendor\\bin\\homestead make

  # replace default domain with project-name
  $here = (Get-Item -Path ".\" -Verbose).FullName
  $content = [System.IO.File]::ReadAllText("$($here)\Homestead.yaml").Replace("homestead.test", "$($new)$($tld)")
  [System.IO.File]::WriteAllText("$($here)\Homestead.yaml", $content)

  # auto hostsfile magic
  & Add-Content -Encoding UTF8 C:\Windows\system32\drivers\etc\hosts "192.168.10.10 `t$($new)$($tld) `t# reeds powershell magic"

  # if available globally, don't need to copy
  #& Copy-Item -Path ..\lrvl.ps1 -Destination .\

  # friendly output
  & Write-Host "
/*********************************************************************/
 | After configuring your Homestead.yaml file to your liking
 | simply start the vm and connect with
 | '.\lrvl -vm go'
 | and destroy with
 | '.\lrvl -vm destroy"

  # start VSCode
  & code .
}

# run startup routine
startUp

