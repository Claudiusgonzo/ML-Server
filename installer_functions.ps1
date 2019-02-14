<#
 .SYNOPSIS
 Function wrappers, Used in installers for templates / samples for ML Server / SQL Server ML Services
 #>
function ExecuteSQL
{
    param(
        [String]$query,
        [Parameter(Mandatory=$false)]
        [String]$dbName = $DatabaseName
    )
    if($IsMixedMode -eq "Yes") {
        Invoke-Sqlcmd -ServerInstance $serverName -Database $dbName -Username $username -Password $password -Query $query
    }
    else {
        Invoke-Sqlcmd -ServerInstance $serverName -Database $dbName -Query $query
    }
}
function ExecuteSQLScript
{
    param(
        [String]$scriptfile,
        [Parameter(Mandatory=$false)]
        [String]$dbName = $DatabaseName,
        [Parameter(Mandatory=$false)]
        [String[]]$variables = ''
    )
    if($IsMixedMode -eq "Yes") {
        Invoke-Sqlcmd -ServerInstance $serverName -Database $dbName -Username $username -Password $password -InputFile $scriptfile -Variable $variables
    }
    else {
        Invoke-Sqlcmd -ServerInstance $serverName -Database $dbName -InputFile $scriptfile -Variable $variables
    }
}
function ExecuteBCP
{
    param(
        [String]
        $bcpcmd
    )
    if($IsMixedMode -eq "Yes") {
        $bcpCommand = "$bcpcmd  -U $username -S $serverName -P $password"
    }
    else {
        $bcpCommand = "$bcpcmd -T -S $serverName"
    }
    #Write-Host($bcpCommand)
    Invoke-Expression $bcpCommand
}

##################################################################
##DSVM Does not have SQLServer Powershell Module Install or Update 
##################################################################
function InstallOrUpdateSQLServerPowerShellModule
{
    if (Get-Module -ListAvailable -Name SQLServer) 
    {
        Write-Host 
        ("Updating SQLServer Power Shell Module")    
        Update-Module -Name "SQLServer" -MaximumVersion 21.0.17199
        Import-Module -Name SqlServer -MaximumVersion 21.0.17199 -Force
    }
    Else 
    {
        Write-Host 
        ("Installing SQLServer Power Shell Module")  
        Install-Module -Name SqlServer -RequiredVersion 21.0.17199 -Scope AllUsers -AllowClobber -Force
        Import-Module -Name SqlServer -MaximumVersion 21.0.17199 -Force
    }
}

##########################################################################
##Clone Data from GIT
##########################################################################
function CloneFromGIT
{
    param(
        [String]
        $SolutionFullName,
        [String]
        $solutionTemplatePath,
        [String]
        $SolutionPath
    )
        
    $clone = "clone https://github.com/Microsoft/$SolutionFullName $solutionTemplatePath"
    if (Test-Path $SolutionPath) {
        Write-Host "Solution has already been cloned"
    }
    else {
        Write-Host "Cloning solution"
        #Invoke-Expression "git "+$clone
        Start-Process "C:\Program Files\Git\bin\git.exe" -ArgumentList $clone -Wait -NoNewWindow
    }
}

##########################################################################
## Install Power BI
##########################################################################
function InstallPowerBI()
{
    Write-Host("Installing latest Power BI")
    #Download PowerBI Desktop installer
    Start-BitsTransfer -Source "https://go.microsoft.com/fwlink/?LinkId=521662&clcid=0x409" -Destination powerbi-desktop.msi
    ##Silently install PowerBI Desktop
    msiexec.exe /i powerbi-desktop.msi /qn /norestart  ACCEPT_EULA=1

    if (!$?) 
    {
    Write-Host -ForeGroundColor Red " Error installing Power BI Desktop. Please install latest Power BI manually."
    }
}