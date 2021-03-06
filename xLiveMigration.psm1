function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Enabled","Disabled")]
        [System.String]
        $Status,

        [System.UInt32]
        $StorageMigrations,

        [System.UInt32]
        $VMMigrations,

        [System.Boolean]
        $UseAnyNetworkForMigration,

        [ValidateSet("TCP/IP","Compression","SMB")]
        [System.String]
        $VMMigrationPerformanceOption,

        [ValidateSet("CredSSP","Kerberos")]
        [System.String]
        $VMMigrationAuthenticationType
    )

# Check if Hyper-V module is present for Hyper-V cmdlets
    if(!(Get-Module -ListAvailable -Name Hyper-V))
    {

        Throw "Please ensure that Hyper-V role is installed with its PowerShell module"
    
    }
		
    $LMStatus = Get-VMHost -ErrorAction SilentlyContinue


    $returnValue = @{
		Status                         = if($LMStatus.VirtualMachineMigrationEnabled){'Enabled'}else{'Disabled'}
        StorageMigrations              = $LMStatus.MaximumStorageMigrations
        VMMigrations                   = $LMStatus.MaximumVirtualMachineMigrations
        UseAnyNetworkForMigration      = $LMStatus.UseAnyNetworkForMigration
        VMMigrationPerformanceOption   = $LMStatus.VirtualMachineMigrationPerformanceOption
        VMMigrationAuthenticationType  = $LMStatus.VirtualMachineMigrationAuthenticationType
	}
    $returnValue
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Enabled","Disabled")]
        [System.String]
        $Status,

        [System.UInt32]
        $StorageMigrations,

        [System.UInt32]
        $VMMigrations,

        [System.Boolean]
        $UseAnyNetworkForMigration,

        [ValidateSet("TCP/IP","Compression","SMB")]
        [System.String]
        $VMMigrationPerformanceOption,

        [ValidateSet("CredSSP","Kerberos")]
        [System.String]
        $VMMigrationAuthenticationType
    )

    # Check if Hyper-V module is present for Hyper-V cmdlets
    if(!(Get-Module -ListAvailable -Name Hyper-V))
    {
        Throw "Please ensure that Hyper-V role is installed with its PowerShell module"
    }
    
    $LMStatus = Get-VMHost -ErrorAction SilentlyContinue

    # Check if the live migration is in the requested Ensure state.
    if (($Status -eq 'Enabled' -and $LMStatus.VirtualMachineMigrationEnabled -eq $true) -or `
        ($Status -eq 'Disabled' -and $LMStatus.VirtualMachineMigrationEnabled -eq $false))
        {
            Write-Verbose -Message "live migration is already $Status"
        }
    else
        {
        if ($Status -eq 'Enabled' -and $LMStatus.VirtualMachineMigrationEnabled -eq $false)
            {
               Write-Verbose -Message "enabling live migration"
               try {Enable-VMMigration} Catch {Write-Verbose -Message "Can't enable Live Migration"}
               Write-Verbose -Message "live migration enabled"
            }
        elseif ($Status -eq 'Disabled' -and $LMStatus.VirtualMachineMigrationEnabled -eq $true)
            {
               Write-Verbose -Message "disabling live migration"
               try {Disable-VMMigration} Catch {Write-Verbose -Message "Can't disable Live Migration"}
               Write-Verbose -Message "live migration disabled"
            }
        }


    if ($Status -eq 'Enabled')
    {
        if(
        ($StorageMigrations) -and
        ($StorageMigrations -ne $LMStatus.MaximumStorageMigrations)
        )
        {
            Write-Verbose -Message "configuring MaxStorage migrations"
            Set-VMHost -MaximumStorageMigrations $StorageMigrations
        }

        if(
        ($VMMigrations) -and
        ($VMMigrations -ne $LMStatus.MaximumVirtualMachineMigrations)
        )
        {
            Write-Verbose -Message "configuring MaxVirtual Machine migrations"
            Set-VMHost -MaximumVirtualMachineMigrations $VMMigrations
        }

        if(
        ($UseAnyNetworkForMigration) -and
        ($UseAnyNetworkForMigration -ne $LMStatus.UseAnyNetworkForMigration)
        )
        {
            Write-Verbose -Message "configuring UseAnyNetworkForMigration"
            Set-VMHost -UseAnyNetworkForMigration $UseAnyNetworkForMigration
        }

        if(
        ($VMMigrationPerformanceOption) -and
        ($VMMigrationPerformanceOption -ne $LMStatus.VirtualMachineMigrationPerformanceOption)
        )
        {
            Write-Verbose -Message "configuring VirtualMachineMigrationPerformanceOption"
            Set-VMHost -VirtualMachineMigrationPerformanceOption $VMMigrationPerformanceOption
        }

        Write-Verbose -Message "$LMStatus"
    }


}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Enabled","Disabled")]
        [System.String]
        $Status,

        [System.UInt32]
        $StorageMigrations,

        [System.UInt32]
        $VMMigrations,

        [System.Boolean]
        $UseAnyNetworkForMigration,

        [ValidateSet("TCP/IP","Compression","SMB")]
        [System.String]
        $VMMigrationPerformanceOption,

        [ValidateSet("CredSSP","Kerberos")]
        [System.String]
        $VMMigrationAuthenticationType
    )

    $LMStatus = Get-VMHost -ErrorAction SilentlyContinue

    # Check if Hyper-V module is present for Hyper-V cmdlets
    if(!(Get-Module -ListAvailable -Name Hyper-V))
    {
        Throw "Please ensure that Hyper-V role is installed with its PowerShell module"
    }

    # Check if the live migration is in the requested Ensure state.
    if (($Status -eq 'Enabled' -and $LMStatus.VirtualMachineMigrationEnabled -eq $true) -or `
        ($Status -eq 'Disabled' -and $LMStatus.VirtualMachineMigrationEnabled -eq $false))
        {
            Write-Verbose -Message "live migration is already $Status"
#            return $true
        }

    if (($Status -eq 'Enabled' -and $LMStatus.VirtualMachineMigrationEnabled -eq $false) -or `
        ($Status -eq 'Disabled' -and $LMStatus.VirtualMachineMigrationEnabled -eq $true))
        {
            Write-Verbose -Message "live migration is not configured"
            return $false
            
        }


    if ($Status -eq 'Enabled'){

        #Storage migrations test

        if(
            ($StorageMigrations -eq $LMStatus.MaximumStorageMigrations) -and
            ($VMMigrations -eq $LMStatus.MaximumVirtualMachineMigrations) -and
            ($UseAnyNetworkForMigration -eq $LMStatus.UseAnyNetworkForMigration) -and
            ($VMMigrationPerformanceOption -eq $LMStatus.VirtualMachineMigrationPerformanceOption)
            )
            {
                Write-Verbose -Message "LMSettings match"
                return $true
            }
        else
            {
                Write-Verbose -Message "LMSettings do not match"
                return $false
            }
    }
}


Export-ModuleMember -Function *-TargetResource

