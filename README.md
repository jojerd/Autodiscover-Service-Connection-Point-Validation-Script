# Autodiscover Service Connection Point Validation Script

This script is used to retrieve Autodiscover Service Connection Points (SCP) from individual in-Site Domain Controllers. A couple of reasons why you may want to do that is to validate that the SCP records are consistent among all of your in-site Domain Controllers. The other reasons may be you've discovered a stale SCP record and want to locate which Domain Controller is issuing a stale record.

 
This script is unsigned, so it does require changing the PowerShell execution policy to unrestricted. You can do that by running this command within the PowerShell window. "Set-ExecutionPolicy unrestricted". It is not advisable leaving the execution policy as unrestricted in place long term. Recommendation would be to change it back to restricted after you retrieve the Autodiscover SCP records. You can do that by running "Set-ExecutionPolicy restricted" in the PowerShell window after you have retrieved the Autodiscover SCP records.

 
# Requirements

This script will require it to be executed on a workstation or server that has ADSIedit installed.
