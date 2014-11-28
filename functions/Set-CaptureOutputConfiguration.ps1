﻿<#############################################################################
HistoryPx uses proxy commands to add extended history information to
PowerShell. This includes the duration of a command, a flag indicating whether
a command was successful or not, the output generated by a command (limited to
a configurable maximum value), the error generated by a command, and the
actual number of objects returned as output and as error records.  HistoryPx
also adds a "__" variable to PowerShell that captures the last output that you
may have wanted to capture, and includes commands to configure how it decides
when output should be captured.  Lastly, HistoryPx includes commands to manage
the memory footprint that is used by extended history information.

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
    Sets the capture output configuration for the session.
.DESCRIPTION
    The Set-CaptureOutputConfiguration command sets the capture output configuration for the session.
.PARAMETER WhatIf
    Shows what would happen if the command was run unrestricted. The command is run, but any changes it would make are prevented, and text descriptions of those changes are written to the console instead.
.PARAMETER Confirm
    Prompts you for confirmation before any system changes are made using the command.
.INPUTS
    None
.OUTPUTS
    HistoryPx.CaptureOutputConfiguration
.NOTES
    By default, HistoryPx is configured with the following settings:
      VariableName: __
      MaximumItemCount: 1000
      CaptureValueTypes: false
      CaptureNull: $false
      ExcludedTypes:
        HistoryPx.ExtendedHistoryConfiguration
        HistoryPx.CaptureOutputConfiguration
        System.String
        System.Management.Automation.Runspaces.ConsolidatedString
        HelpInfoShort
        MamlCommandHelpInfo
        System.Management.Automation.CommandInfo
        Microsoft.PowerShell.Commands.GenericMeasureInfo
        System.Management.Automation.PSMemberInfo
        Microsoft.PowerShell.Commands.MemberDefinition
        System.Type
        System.Management.Automation.PSVariable
.EXAMPLE
    PS C:\> Set-CaptureOutputConfiguration -MaximumItemCount 2000

    Set the maximum number of items to capture from a single command to 2000.
.EXAMPLE
    PS C:\> Set-CaptureOutputConfiguration -VariableName x

    Changes the capture output variable name to "x".
.EXAMPLE
    PS C:\> Set-CaptureOutputConfiguration -CaptureValueTypes -CaptureNull

    Configures output capture so that the output of value types or no output at all will results in the output variable being updated.
.EXAMPLE
    PS C:\> Set-CaptureOutputConfiguration -CaptureValueTypes:$false -CaptureNull:$false

    Configures output capture such that the output variable will not be updated when value types or null are output from a command.
.EXAMPLE
    PS C:\> Set-CaptureOutputConfiguration -ExcludeType 'System.Management.Automation.Language.Ast'

    Adds [System.Management.Automation.Language.Ast] to the list of output types that will not be captured in the last captured output variable.
.EXAMPLE
    PS C:\> Set-CaptureOutputConfiguration -IncludeType 'System.String'

    Removes [System.String] from the list of output types that will not be captured in the last captured output variable.
.LINK
    Get-CaptureOutputConfiguration
#>
function Set-CaptureOutputConfiguration {
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType('HistoryPx.CaptureOutputConfiguration')]
    param(
        # The name of the variable that will be used to store the last captured output. When changing the variable name, that the old capture variable is not automatically removed.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $VariableName,

        # The maximum number of output items that will be retained in the last captured output variable.
        [Parameter()]
        [ValidateNotNull()]
        [ValidateRange(1,[System.Int32]::MaxValue)]
        [System.Int32]
        $MaximumItemCount,

        # When true, value types will be captured in the last captured output variable.
        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $CaptureValueTypes,

        # When true, a null value will be captured in the last captured output variable.
        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $CaptureNull,

        # The additional type names that you want to exclude from capture.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $ExcludeType,

        # The type names that are excluded by default that you do not want to exclude from capture.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $IncludeType,

        # If true, the updated capture output configuration will be returned to the caller.
        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $PassThru
    )
    try {
        #region Update our CaptureOutputConfiguration settings using the parameters that were provided.

        foreach ($parameterName in @('VariableName','MaximumItemCount','CaptureValueTypes','CaptureNull')) {
            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey($parameterName)) {
                if ($PSCmdlet.ShouldProcess($parameterName)) {
                    [HistoryPx.CaptureOutputConfiguration]::$parameterName = $PSCmdlet.MyInvocation.BoundParameters.$parameterName
                }
            }
        }
        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('ExcludeType')) {
            if ($PSCmdlet.ShouldProcess('ExcludeType')) {
                foreach ($typeName in $ExcludeType) {
                    if ([HistoryPx.CaptureOutputConfiguration]::ExcludedTypes -notcontains $typeName) {
                        [HistoryPx.CaptureOutputConfiguration]::ExcludedTypes.Add($typeName)
                    }
                }
            }
        }
        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('IncludeType')) {
            if ($PSCmdlet.ShouldProcess('IncludeType')) {
                foreach ($typeName in $IncludeType) {
                    if ([HistoryPx.CaptureOutputConfiguration]::ExcludedTypes -contains $typeName) {
                        [HistoryPx.CaptureOutputConfiguration]::ExcludedTypes.Remove($typeName)
                    }
                }
            }
        }

        #endregion

        #region If the caller wants the resulting configuration object returned, return it.

        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('PassThru') -and $PassThru) {
            Get-CaptureOutputConfiguration
        }

        #endregion
    } catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}

Export-ModuleMember -Function Set-CaptureOutputConfiguration