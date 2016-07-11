function cleanstring
{param($dirtystring)
cls
write-host "Cleaning.." -nonewline
$chk = "> > "," >"," > ",">>","> "
$chk | foreach{
$dirtystring = $dirtystring.tostring()
if (($_ -like ">>") -or ($_ -like "> > ")){$dirtystring = $dirtystring.replace($_,">")} else {$dirtystring = $dirtystring.replace($_,"")}
write-host "." -nonewline
}
$dirtystring
}
function sectionparse
{param($gporeport,$sectionname)
cls
Write-host "Parsing.." -nonewline
$sectionfilename = $sectionname.replace("/"," ") +".html"
Clear-content $sectionfilename
add-content $sectionfilename (Get-content testheader.html)
$search = 1
While ($i -eq 0){
Write-host "." -nonewline
$parseloop = $gporeport | select-string $sectionname -context 0,$search
#$parseloop = $parseloop.tostring()
if ($parseloop -like "*</table>*"){ $i = 1; add-content $sectionfilename $parseloop}
$search = $search + 1
}
$stringtoclean =  (get-content $sectionfilename) | out-string
$cleaned = cleanstring $stringtoclean
set-content $sectionfilename $cleaned
}
#get-gporeport -name "default domain Policy" -reporttype HTML -path gpotest.html
$i = 0
clear-content testheader.html
$gpo = get-content gpotest.html 
$gpoheader = get-content c:\cbatlpci\gpotest.html | select-string -simplematch 'Computer Configuration (Enabled)' -context 1344,0 
$gpoheader = ($gpoheader.tostring()).replace('<div class="he0_expanded"><span class="sectionTitle" tabindex="0">Computer Configuration (Enabled)</span><a class="expando" href="#"></a></div>','')
add-content testheader.html $gpoheader

#$gpo | select-string "Event Log" -context 0,1
$sectionheaders = "Account Policies/Password Policy","Control Panel/Personalization","Account Policies/Account Lockout Policy","Local Policies/User Rights Assignment"
$sectionheaders | foreach{
$insertsection = sectionparse $gpo $_
}
#convert csv reports to pdf
$path = "C:\cbatlpci\" 
#$xlFixedFormat = "Microsoft.Office.Interop.word.xlFixedFormatType" -as [type] 
$wordFiles = Get-ChildItem -Path $path -include *.html -recurse 
 $objword = New-Object -ComObject word.application 
$objword.visible = $false
$objword
# foreach($wb in $wordFiles) 
# { 
 # $filepath = Join-Path -Path $path -ChildPath ($wb.BaseName + ".pdf") 
 # $workbook = $objword.workbooks.open($wb.fullname, 3) 
 # $workbook.ActiveSheet.Cells.Font.Size = 4
 # $Workbook.ActiveSheet.PageSetup.Orientation = 2
 # $Workbook.ActiveSheet.PageSetup.FitToPagesWide = 1
 # $Workbook.ActiveSheet.PageSetup.FitToPagesTall = 1
 # $workbook.ActiveSheet.ListObjects.add(1,$workbook.ActiveSheet.UsedRange,0,1)
 # $workbook.ActiveSheet.Cells.HorizontalAlignment = -4108 
 # $workbook.ActiveSheet.UsedRange.EntireColumn.AutoFit()
 # $workbook.Saved = $true 
 # $workbook.ExportAsFixedFormat($xlFixedFormat::xlTypePDF, $filepath) 
# $objExcel.Workbooks.close() 
# } 
# $objExcel.Quit() 
