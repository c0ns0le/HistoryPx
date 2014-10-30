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

function Add-ExtendedHistoryInformation {
    [CmdletBinding()]
    [OutputType('Microsoft.PowerShell.Commands.HistoryInfo#Extended')]
    param(
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.PowerShell.Commands.HistoryInfo]
        $InputObject
    )
    process {
        try {
            $ExtendedHistoryItem = [HistoryPx.ExtendedHistoryTable]::Item($InputObject.Id)
            Add-Member -InputObject $InputObject -TypeName 'Microsoft.PowerShell.Commands.HistoryInfo#Extended'
            Add-Member -InputObject $InputObject -MemberType NoteProperty -Name Duration -Value $(
                if ($InputObject.EndExecutionTime) {
                    $InputObject.EndExecutionTime - $InputObject.StartExecutionTime
                }
            )
            Add-Member -InputObject $InputObject -MemberType NoteProperty -Name Success -Value $(
                if ($InputObject.ExecutionStatus -eq [System.Management.Automation.Runspaces.PipelineState]::Failed) {
                    $false
                } elseif ($ExtendedHistoryItem) {
                    $ExtendedHistoryItem.CommandSuccessful
                } else {
                    $InputObject.ExecutionStatus -eq [System.Management.Automation.Runspaces.PipelineState]::Completed
                }
            )
            Add-Member -InputObject $InputObject -MemberType NoteProperty -Name Output -Value $(
                if ($ExtendedHistoryItem) {
                    $ExtendedHistoryItem.Output
                }
            )
            Add-Member -InputObject $InputObject -MemberType NoteProperty -Name OutputCount -Value $(
                if ($ExtendedHistoryItem -and ($ExtendedHistoryItem.OutputCount -gt 0)) {
                    $ExtendedHistoryItem.OutputCount
                }
            )
            Add-Member -InputObject $InputObject -MemberType NoteProperty -Name Error -Value $(
                if ($ExtendedHistoryItem) {
                    $ExtendedHistoryItem.Error
                }
            )
            Add-Member -InputObject $InputObject -MemberType NoteProperty -Name ErrorCount -Value $(
                if ($InputObject.Error -ne $null) {
                    @($InputObject.Error).Count
                }
            )
            $InputObject
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}