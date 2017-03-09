# xLiveMigration

The xHyper-V DSC module configures and manages a Hyper-V live migration options

* **Status**: VM migration status {enabled | disabled}
* **StorageMigrations**: Number of simultaneous storage migrations
* **VMMigrations**: Number of simultaneous VM migrations
* **UseAnyNetworkForMigration**: Do you want to use any network for live migration {True | False} 
* **VMMigrationPerformanceOption**: The desired VMMigration performance option {TCP/IP | Compression | SMB"}
* **VMMigrationAuthenticationType**: The desired VMMigration authentication type {CredSSP | Kerberos}

##Examples
###Sample configuration
This configuration will enable VM migration with following options: 4 simultaneous storage migrations, 10 simultaneous VM Migrations, use any network for live migration, compression performance option, credSSP auth type
```powershell
configuration HypervHost {  
    Import-DscResource -ModuleName xLivemigration
    Node HWHost {
      xLivemigration livemigration{
                  Status = "Enabled"
                  StorageMigrations = 4
                  VMMigrations = 10
                  UseAnyNetworkForMigration = $true
                  VMMigrationPerformanceOption = "Compression"
                  VMMigrationAuthenticationType = "CredSSP"
                  }
    }
}    
```
