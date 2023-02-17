Function Invoke-PSPPS {  
    param ( 
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)] $List, 
        [Parameter(Mandatory = $false)][switch]$Domain,
        [Parameter(Mandatory = $false)][switch]$PromptForCredentials
    )     
    if ($PromptForCredentials) {
        $TempCred = Get-Credential
    }
    
    if ($List) { Write-Host "Using List from CommandLine" } 
    
    if ($Domain) {
        Write-Host "Enumerating Domain Computers"
        $AD = [adsisearcher]"objectcategory=computer"
        $Computers = $AD.FindAll()
        ForEach ($Computer in $Computers) { Write-Host $Computer.Properties.name; $List += $Computer.Properties.name }
        Write-Host "Done Enumerating Domain Computers"
    }

    
    $i = 0
    $output = ""
    $MaxThreads = 10
    Get-Job | Remove-Job
    
    $block = {
        Param([string] $comp)
        $Array = @()
        $Comp = $Comp.Trim()
        Write-Verbose "Processing $Comp"
        Try {
            $Procs = $null
            $Procs = Invoke-Command $Comp -ErrorAction Stop -ScriptBlock { Get-Process -IncludeUserName }
            If ($Procs) {
                Foreach ($P in $Procs) {
                    $Object = $Mem = $CPU = $null
                    $Object = New-Object PSObject -Property ([ordered]@{    
                            "ServerName"  = $Comp
                            "UserName"    = $P.username
                            "ProcessName" = $P.processname
                            "Session"     = $P.SI
                        })
                    $Array += $Object 
                }
            }
            Else {
                Write-Verbose "No process found for $Username on $Comp"
            }
        }
        Catch {
            Write-Verbose "Failed to query $Comp"
            Continue
        }
        $Array
    }
    
    ForEach ($Computer in $List) {
        While ($(Get-Job -state running).count -ge $MaxThreads) {
            Start-Sleep -Milliseconds 500
        }
        $i++
        write-host $Computer.name
        Write-Progress -Activity "Querying Computers" -status "Status: " -PercentComplete (($i / $List.count) * 100) 

        If ($PromptForCredentials) {
            Start-Job -Verbose -Name $Computer -Scriptblock $block -ArgumentList $Computer -Credential $TempCred
        }
        else {
            Start-Job -Verbose -Name $Computer -Scriptblock $block -ArgumentList $Computer
        }
        
    }
    
    While ($(Get-Job -State Running).count -gt 0) {
        start-sleep 1
    }
    
    $info = @()
    foreach ($job in Get-Job) {
        $info += Receive-Job -Id ($job.Id) -Keep
    }
    
    #Get-Job | Remove-Job
    
    $info | Out-GridView
}

Function Get-LastPSPPSOutput {
    $info = @()
    foreach ($job in Get-Job) {
        $info += Receive-Job -Id ($job.Id) -Keep
    }
    
    $info | Out-GridView
}

Write-Host "Usage: Invoke-PSPPS -List COMPUTER1,COMPUTER2,COMPUTER3 [-PromptForCredentials]"
Write-Host "       Invoke-PSPPS -Domain [-PromptForCredentials]"
Write-Host "       Get-LastPSPPSOutput"
