$output = Get-Content -Path "$(System.DefaultWorkingDirectory)/MyLog.log";

$warnings = $output | Select-String -Pattern ".*:\s";
$hasErrors = $false;

[regex]$issueTypeRegex = "(warning|error)";

[regex]$issueLocationRegex = "(\d+,\d+)";

[regex]$sourcePathRegex = "^[^/(]*";

[regex]$issueCodeRegex = "(?<=(warning|error) )[A-Za-z0-9]+";

[regex]$messageRegex = "(?<=((warning|error) [A-Za-z0-9]+: )).*";

$warnings | Foreach-Object { 
    $issueLocationMatch = $issueLocationRegex.Matches($_)[0];

    if($issueLocationMatch -ne $null)
    {
        if ($issueLocationMatch) 
        { 
            $issueLocation = $issueLocationMatch.value.split(","); 
        }
        else 
        { 
            $issueLocation = "unknown"; 
        }

        $issueLocation = $issueLocationMatch.value.split(",");
        $issueType = $issueTypeRegex.Matches($_)[0];
        $sourcepath = $sourcePathRegex.Matches($_)[0];
        $linenumber = $issueLocation[0];
        $columnnumber = $issueLocation[1];
        $issueCode = $issueCodeRegex.Matches($_)[0];
        $message = $messageRegex.Matches($_)[0]; 

        Write-Host "##vso[task.logissue type=$issueType;sourcepath=$sourcepath;linenumber=$linenumber;columnnumber=$columnnumber;code=$issueCode;]$message";

        if($issueType.Value -eq "error") { $hasErrors = $true; }

    }
};

if($warnings.Count -gt 0 -and $hasErrors -eq $true) { Write-Host "##vso[task.complete result=Failed;]There are build errors"; } 

elseif($warnings.Count -gt 0 -and $hasErrors -eq $false) { Write-Host "##vso[task.complete result=SucceededWithIssues;]There are build warnings"; }