$outFile = Join-Path $env:USERPROFILE 'Desktop\system-specs.md'

Function Convert-Size {
    param(
        [UInt64]$Bytes
    )

    if ($Bytes -ge 1GB) { '{0:N2} GB' -f ($Bytes / 1GB) }
    elseif ($Bytes -ge 1MB) { '{0:N2} MB' -f ($Bytes / 1MB) }
    elseif ($Bytes -ge 1KB) { '{0:N2} KB' -f ($Bytes / 1KB) }
    else { "$Bytes bytes" }
}

# Use try/catch so the script continues even if some info is restricted
try { $os  = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop } catch { $os = $null }
try { $cs  = Get-CimInstance Win32_ComputerSystem  -ErrorAction Stop } catch { $cs = $null }
try { $cpu = Get-CimInstance Win32_Processor       -ErrorAction Stop } catch { $cpu = @() }
try { $ram = Get-CimInstance Win32_PhysicalMemory  -ErrorAction Stop } catch { $ram = @() }
try { $gpu = Get-CimInstance Win32_VideoController -ErrorAction Stop } catch { $gpu = @() }

@"
# System Specs

## OS
- **Name:** $($os.Caption)
- **Version:** $($os.Version)

## Computer System
- **Manufacturer:** $($cs.Manufacturer)
- **Model:** $($cs.Model)
- **Total Physical Memory:** $(if ($cs) { Convert-Size $cs.TotalPhysicalMemory } else { 'N/A' })

## CPU
- **Name:** $($cpu[0].Name)
- **Cores:** $($cpu[0].NumberOfCores)

## RAM Modules
| Manufacturer | Part Number | Capacity |
|--------------|-------------|----------|
$(foreach ($r in $ram) {
    "| $($r.Manufacturer) | $($r.PartNumber) | $(Convert-Size $r.Capacity) |"
})

## GPU
| Name | Processor | Memory |
|------|-----------|--------|
$(foreach ($g in $gpu) {
    "| $($g.Name) | $($g.VideoProcessor) | $(Convert-Size $g.AdapterRAM) |"
})
"@ | Out-File -FilePath $outFile -Encoding UTF8

Write-Host "Specs saved to: $outFile"
