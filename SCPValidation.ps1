#################################################
# Created by: Josh Jerdon                       #
# Email: jojerd@microsoft.com                   #     
# Version: 1.16                                 #
# Date Created: 5/31/2016                       #
# Purpose: To query in-site domain controllers, #
# and compare the Autodiscover SCP records      #
#                                               #
# Special thanks goes to Michael Van Horenbeeck #
# for providing the base PowerShell script.     #
# Jason Slaughter for assisting with the ForEach#
# loop refinement.                              #
# Ryan Ries for helping me optimize the LDAP    #
# query.                                        #
#################################################

# Change log: v1.16
#
# 2016JUN01
# - Corrected misspellings.
#
# 2016JUN02
# - Added support for error handling as well as counting the number of records found.
# - Corrected the way the script searches for Domain Controllers by retrieving the current Active Directory site.
# - Added the ability for the script to count the number of in site domain controllers it locates.
#
# 2016JUN03
#
# - Increased the efficiency of the script locating the Workstation / Servers AD site.
#
# 2016JUN06
#
# - Optimized LDAP query.
#
# 2016SEP30
#
# - Added additional output parameter for displaying which Domain Controller an individual SCP record was located on.
# - Added Exchange Server name field to help identitify which Exchange Server an SCP record is associated with.

Import-Module ActiveDirectory

$obj = @()
$ADSite = [System.DirectoryServices.ActiveDirectory.ActiveDirectorySite]::GetComputerSite().Name
$DomainControllers = Get-ADDomainController -Filter {Site -eq "$ADSite"}
$ADDomain = (Get-ADRootDSE).ConfigurationNamingContext

Write-Host "Searching $ADDomain..."

    foreach ($DC in $DomainControllers)
    
{
    $DomainController = $DC.Name
    $DSSearch = New-Object System.DirectoryServices.DirectorySearcher
    $DSSearch.Filter = '(&(objectClass=serviceConnectionPoint)(|(keywords=67661d7F-8FC4-4fa7-BFAC-E1D7794C1F68)(keywords=77378F46-2C66-4aa9-A6A6-3E7A48B19596)))'
    $DSSearch.SearchRoot = 'LDAP://' + $DomainController + '/' + $ADDomain
$DSSearchResult = $DSSearch.FindAll()

                If ($DSSearchResult.Count -gt 0)
{
Write-Host "Found"$DSSearchResult.Count"Record(s) on $DomainController"
$DSSearchResult | %{
        $ADSI = [ADSI]$_.Path
        $autodiscover = New-Object psobject -Property @{
            ExchangeServer = [string]$ADSI.cn
            Site = $adsi.keywords[0]
            DateCreated = $adsi.WhenCreated.ToShortDateString()
            AutoDiscoverInternalURI = [string]$adsi.ServiceBindingInformation
            DomainController = $DC.name
            }
            $obj += $autodiscover
        }
}
else
{
Write-Host "No SCP records found on $DC"
}
}

Write-Output $obj | select DomainController,ExchangeServer,Site,DateCreated,AutoDiscoverInternalURI | ft -AutoSize
Write-Output "Found $($DomainControllers.count) domain controllers in the AD Site $ADSite"
