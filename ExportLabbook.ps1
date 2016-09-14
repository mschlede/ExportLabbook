# define output directory
$outputDirectory = '\\ixion\las_m\Archiv\2D\ElectronicLabbooks'
$outputDirectoryAllPages = '\\ixion\las_m\Archiv\2D\ElectronicLabbooks\Full'
$outputFile = "$($outputDirectory)\$(Get-Date -format yyyyMMdd)_Summary.pdf"

# enable onenote provider
Enable-Onenote

# get list of all pages which where last modified during the last week
$allPages = dir 'OneNote:\Lithium6_Labbook\Labbook 2016' -recurse | where-object { (!$_.PSIsContainer) }
$changedPages = dir 'OneNote:\Lithium6_Labbook\Labbook 2016' -recurse | where-object {($_.Name -gt ((Get-Date).AddDays(-7) | Get-Date -format yyyyMMdd)) -and (!$_.PSIsContainer) }
# export those pages to the archive
$exportedFileNames = $changedPages | export-onenote -output $outputDirectory -format pdf
$allPages | export-onenote -output $outputDirectoryAllPages -format pdf

# add pdfsharp library
Add-Type -Path '.\PdfSharp.dll' 
# merge all resulting pdf files
$output = New-Object PdfSharp.Pdf.PdfDocument            
$PdfReader = [PdfSharp.Pdf.IO.PdfReader]            
$PdfDocumentOpenMode = [PdfSharp.Pdf.IO.PdfDocumentOpenMode]                        
        
foreach($i in $exportedFileNames) {            
    $input = New-Object PdfSharp.Pdf.PdfDocument            
    $input = $PdfReader::Open($i."ExportedFile", $PdfDocumentOpenMode::Import)            
    $input.Pages | %{$output.AddPage($_)}            
}                        
            
           
$output.Save($outputFile) 

# remove single files
foreach($i in $exportedFileNames) {            
    Remove-Item $i."ExportedFile"         
} 


# print pages to minolta, staple and punch
# Start-Process –FilePath 'C:\Program Files (x86)\Foxit Software\Foxit Reader\FoxitReader.exe' -ArgumentList "/p $outputFile" -PassThru | %{sleep 10;$_} | kill