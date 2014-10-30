﻿<#############################################################################
DESCRIPTION

Copyright 2014 Kirk Munro

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
#############################################################################>

<#
.SYNOPSIS
    Sets the extended history configuration for the session.
.DESCRIPTION
    The Set-ExtendedHistoryConfiguration command sets the extended history configuration for the session.
.PARAMETER WhatIf
    Shows what would happen if the command was run unrestricted. The command is run, but any changes it would make are prevented, and text descriptions of those changes are written to the console instead.
.PARAMETER Confirm
    Prompts you for confirmation before any system changes are made using the command.
.INPUTS
    None
.OUTPUTS
    HistoryPx.ExtendedHistoryConfiguration
.NOTES
    By default, extended history is configured to use a maximum entry count of 200 and a maximum item count per entry of 1000.
.EXAMPLE
    PS C:\> Set-ExtendedHistoryConfiguration -MaximumEntryCount 400

    Set the maximum extended history entry count to 400.
.EXAMPLE
    PS C:\> Set-ExtendedHistoryConfiguration -MaximumItemCountPerEntry 2000

    Set the maximum output item count per extended history entry to 2000.
.LINK
    Get-ExtendedHistoryConfiguration
.LINK
    Get-History
.LINK
    Clear-History
#>
function Set-ExtendedHistoryConfiguration {
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType('HistoryPx.ExtendedHistoryConfiguration')]
    param(
        # The maximum number of extended history entries that will be retained in the session.
        [Parameter()]
        [ValidateNotNull()]
        [ValidateRange(1,[System.Int32]::MaxValue)]
        [System.Int32]
        $MaximumEntryCount,

        # The maximum number of output items that will be retained for any single extended history entry.
        [Parameter()]
        [ValidateNotNull()]
        [ValidateRange(1,[System.Int32]::MaxValue)]
        [System.Int32]
        $MaximumItemCountPerEntry,

        # If true, the updated extended history configuration will be returned to the caller.
        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $PassThru
    )
    try {
        #region Update our ExtendedHistoryTable settings using the parameters that were provided.

        foreach ($parameterName in @('MaximumEntryCount','MaximumItemCountPerEntry')) {
            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey($parameterName)) {
                if ($PSCmdlet.ShouldProcess($parameterName)) {
                    [HistoryPx.ExtendedHistoryTable]::$parameterName = $PSCmdlet.MyInvocation.BoundParameters.$parameterName
                }
            }
        }

        #endregion

        #region If the caller wants the resulting configuration object returned, return it.

        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('PassThru') -and $PassThru) {
            Get-ExtendedHistoryConfiguration
        }

        #endregion
    } catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}

Export-ModuleMember -Function Set-ExtendedHistoryConfiguration