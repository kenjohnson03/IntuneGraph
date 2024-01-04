# Write the comment-based HELP for Invoke-GraphBatchRequest
<#
.SYNOPSIS
    Invokes a batch request against the Microsoft Graph API.

.DESCRIPTION
    Invokes a batch request against the Microsoft Graph API.

.PARAMETER BatchRequest
    The batch request to invoke.

.PARAMETER Environment
    The environment to connect to. Valid values are Global, USGov, USGovDoD. Default is Global.

.EXAMPLE
    # Invoke a batch request.
    Invoke-GraphBatchRequest -BatchRequest $batchRequest

.EXAMPLE
    # Invoke a batch request in the USGov environment.
    Invoke-GraphBatchRequest -BatchRequest $batchRequest -Environment USGov

.EXAMPLE
    # Invoke a batch request in the USGovDoD environment.
    Invoke-GraphBatchRequest -BatchRequest $batchRequest -Environment USGovDoD
#>
function Invoke-GraphBatchRequest
{
    param (
        [Parameter(Mandatory, Position=0)]
        [PSObject[]]$BatchRequest,
        [ValidateSet("Global", "USGov", "USGovDoD")]
        [string]$Environment="Global"
    )
    begin {
        if($false -eq (Initialize-IntuneAccess -Scopes @("DeviceManagementConfiguration.ReadWrite.All") -Modules @("Microsoft.Graph.Authentication") -Environment $Environment))
        {
            return
        }
        
        switch ($Environment) {
            "USGov" { $uri = "https://graph.microsoft.us" }
            "USGovDoD" { $uri = "https://dod-graph.microsoft.us" }
            Default { $uri = "https://graph.microsoft.com" }
        }

        $graphVersion = "v1.0"        
    }
    process {
        $requestUri = "$uri/$graphVersion/`$batch"

        $body = @{
            requests = [array]$BatchRequest
        }
        
        $response = Invoke-MgRestMethod -Method Post -Uri $requestUri -Body ($body | ConvertTo-Json -Depth 50) -ContentType "application/json" -OutputType Json | ConvertFrom-Json
        return $response
    }
}