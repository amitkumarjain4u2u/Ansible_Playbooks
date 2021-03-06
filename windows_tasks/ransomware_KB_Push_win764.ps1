Invoke-command -ScriptBlock
$name = Get-Content C:\Patching\computerlist.txt
$ExcelObject = new-Object -comobject Excel.Application  
$ExcelObject.visible = $True 
$ExcelObject.DisplayAlerts =$false
$date= get-date -format "yyyyMMddHHss"
#write-host $date
$strPath1="C:\Patching\Active_Users_$date.xlsx" 
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
$ActiveWorksheet.cells.item(1,4) = "kb4012213.msu"
$ActiveWorksheet.cells.item(1,5) = "PSEXEC"

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
New-PSDrive -Name Z -PSProvider FileSystem -Root \\vmtool_w2k8\c$\Patching
New-PSDrive -Name Y -PSProvider FileSystem -Root \\$line\c$\

copy Z:\windows6.1-kb4012212-x64_2decefaa02e2058dcd965702509a992d8c4e92b3.msu Y:\
$setuppath = Test-Path \\$line\c$\windows6.1-kb4012212-x64_2decefaa02e2058dcd965702509a992d8c4e92b3.msu
$ActiveWorksheet.Cells.Item($intRow, 3) = $setuppath
copy Z:\win764.bat Y:\
$vmbat = Test-Path \\$line\c$\win764.bat
$ActiveWorksheet.Cells.Item($intRow, 4) = $vmbat
#copy z:\psexec.exe \\$env.computerName\c$\
#copy z:\psexec.exe c:\
$psexec = Test-Path c:\Patching\PsExec64.exe
$ActiveWorksheet.Cells.Item($intRow, 5) = $psexec
Remove-PSDrive -name Z
Remove-PSDrive -name Y

C:\Patching\PsExec64.exe \\$line -s \\$line\c$\win764.bat

$intRow = $intRow + 1
}

$ExcelObject.ActiveWorkbook.SaveAs($strPath1)
$ExcelObject.Workbooks.Close()
$ExcelObject.Quit()