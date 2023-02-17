# PSPPS
## (pronounced like the sound you make when you're calling a cat.)
PowerShell Parallel Process Scanner

Sometimes you've got broad system admin access but do not have the account you're looking for. BloodHound will only show you results based on Sessions and LoggedOn, which missed a large amount of potential identities that can be abused. What PSPPS does is spin up a bunch of background jobs that use PowerShell Remoting to pull process names and owners from the specified list of servers or all reachable Domain computers where you have administrative access, and returns those in a PowerShell GridView for parsing and user hunting. 

```
Usage: Invoke-PSPPS -List COMPUTER1,COMPUTER2,COMPUTER3 [-PromptForCredentials]
       Invoke-PSPPS -Domain [-PromptForCredentials]
       Get-LastPSPPSOutput
```
