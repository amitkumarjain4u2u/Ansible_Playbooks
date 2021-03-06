Invoke-command -ScriptBlock
$name = Get-Content C:\VMWARE_TOOLS_Latest\computerlist.txt
$ExcelObject = new-Object -comobject Excel.Application  
$ExcelObject.visible = $True 
$ExcelObject.DisplayAlerts =$false
$date= get-date -format "yyyyMMddHHss"
#write-host $date
$strPath1="C:\VMWARE_TOOLS_Latest\Active_Users_$date.xlsx" 
#write-host $strPath1
if (Test-Path $strPath1) {  
  #Open the document  
$ActiveWorkbook = $ExcelObject.WorkBooks.Open($strPath1)  
$ActiveWorksheet = $ActiveWorkbook.Worksheets.Item(1)  
} else {  
# Create Excel file  
$ActiveWorkbook = $ExcelObject.Workbooks.Add()  
$ActiveWorksheet = $ActiveWorkbook.Worksheets.Item(1)  

#Add Headers to excel file
$ActiveWorksheet.Cells.Item(1,1) = "ServerName"  
$ActiveWorksheet.Cells.Item(1,2) = "Operating System"  
$ActiveWorksheet.cells.item(1,3) = "BatFileCopied" 
$ActiveWorksheet.cells.item(1,4) = "Setup64.exe"
$ActiveWorksheet.cells.item(1,5) = "PSEXEC"
$ActiveWorksheet.cells.item(1,6) = "VMCI_DRIVER"
$format = $ActiveWorksheet.UsedRange
$format.Interior.ColorIndex = 19
$format.Font.ColorIndex = 11
$format.Font.Bold = "True"
$format.EntireColumn.Autofit()
$format.columns.item(2).columnWidth = 50
}
$intRow = 2
foreach ($line in $name)
{
$ActiveWorksheet.Cells.Item($intRow, 1) = $line 
#$net = new-object -ComObject WScript.Network
#$net.MapNetworkDrive("Z:", "\\VDI-DEV-127\vmtools", $false, "xray\bmisra", "Welcome123")
#$net.MapNetworkDrive("Z:", "\\VDI-COG-17\c$\vmtools", $false, "xray\bmisra", "Welcome123")

#$net = new-object -ComObject WScript.Network
#$net.MapNetworkDrive("Y:", "\\VDI-COG-17\c$", $false, "xray\bmisra", "Welcome123")
#$net.MapNetworkDrive("Y:", "\\VDI-DEV-127\c$", $false, "xray\bmisra", "Welcome123")
#$OS = Get-WMIObject Win32_OperatingSystem -ComputerName $line | select-object Caption
$OS = (Get-WmiObject Win32_OperatingSystem -computername $line).Caption
            if (!$OS)
                {$ActiveWorksheet.Cells.Item($intRow, 2) = "Not Reachable"}
            Else
                {$ActiveWorksheet.Cells.Item($intRow, 2) = $OS}
#write-host $OS
#$ActiveWorksheet.Cells.Item($intRow, 2) = $OS
New-PSDrive -Name Z -PSProvider FileSystem -Root \\vmtool_w2k8\c$\VMWARE_TOOLS_Latest
New-PSDrive -Name Y -PSProvider FileSystem -Root \\$line\c$\

copy Z:\setup64.exe Y:\
$setuppath = Test-Path \\$line\c$\setup64.exe
$ActiveWorksheet.Cells.Item($intRow, 3) = $setuppath
copy Z:\vm_noreboot.bat Y:\
$vmbat = Test-Path \\$line\c$\vm_noreboot.bat
$ActiveWorksheet.Cells.Item($intRow, 4) = $vmbat
#copy z:\psexec.exe \\$env.computerName\c$\
#copy z:\psexec.exe c:\
$psexec = Test-Path C:\VMWARE_TOOLS_Latest\psexec.exe
$ActiveWorksheet.Cells.Item($intRow, 5) = $psexec
Remove-PSDrive -name Z
Remove-PSDrive -name Y
#C:\psexec.exe \\$line -s \\$line\c$\vm.bat
C:\VMWARE_TOOLS_Latest\psexec.exe \\$line -s \\$line\c$\vm_noreboot.bat
#$errorcore = Get-Content "c:\output.txt" | select -Last 3 -skip 0
#$errorcode = Get-Content C:\output.txt | Select-String "error code 0" -quiet
#write-host $errorcode
#$vmtool = (Get-WmiObject -computer $line -class Win32_Process -filter "name like '%cmd%'").ProcessId
$vmcidriver = (Get-WmiObject -class Win32_SystemDriver -computername $line | where-object { $_.Name -match "vmci" }).State
        if (!$vmcidriver)
                {$ActiveWorksheet.Cells.Item($intRow, 6) = "Not Installed or not reachable"}
        Else
                {$ActiveWorksheet.Cells.Item($intRow, 6) = $vmcidriver}
        
#$errorvalue = "True"
#$errorcode = "False"
#$errorcode = Get-Content C:\output.txt | Select-String "error code 0" -quiet
#write-host $errorcode
#        if ( $errorcode -eq $errorvalue )
#               { 
#                  #write-host "True"
#                  $ActiveWorksheet.Cells.Item($intRow, 6) = $errorcode
#                }
#       Else 
#                {
#                    #write-host "False"
#                    $ActiveWorksheet.Cells.Item($intRow, 6) = $errorcode
#                }
#$ActiveWorksheet.Cells.Item($intRow, 6) = $errorcode
#shutdown -m $line -t 5 -r
#$net.RemoveNetworkDrive("Z:") 
#$net.RemoveNetworkDrive("Y:")
#NET USE Z: /d 
#NET USE Y: /d 
$intRow = $intRow + 1
}

$ExcelObject.ActiveWorkbook.SaveAs($strPath1)
$ExcelObject.Workbooks.Close()
$ExcelObject.Quit()