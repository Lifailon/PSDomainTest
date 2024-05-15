function Get-DomainTest {
    <#
    .SYNOPSIS
    Test DNS records of any domain using ZoneMaster api
    .DESCRIPTION
    Example:
    Get-DomainTest -Domain github.com
    Get-DomainTest -Domain github.com -json -Warning
    Get-DomainTest -Domain github.com -html | Out-File .\result.html
    .LINK
    https://github.com/Lifailon/PSDomainTest
    https://github.com/zonemaster/zonemaster
    https://zonemaster.net/en/run-test
    #>
    param (
        [string]$Domain,
        [switch]$Warning,
        [switch]$json,
        [switch]$html
    )
    $UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36"
    $headers = @{
        "Accept"             = "application/json, text/plain, */*"
        "Accept-Encoding"    = "gzip, deflate, br, zstd"
        "Accept-Language"    = "ru,en-US;q=0.9,en;q=0.8,ru-RU;q=0.7"
        "Origin"             = "https://zonemaster.net"
        "Sec-Fetch-Dest"     = "empty"
        "Sec-Fetch-Mode"     = "cors"
        "Sec-Fetch-Site"     = "same-origin"
        "sec-ch-ua"          = "`"Google Chrome`";v=`"125`", `"Chromium`";v=`"125`", `"Not.A/Brand`";v=`"24`""
        "sec-ch-ua-mobile"   = "?0"
        "sec-ch-ua-platform" = "`"Windows`""
    }

    ### Start domain test and get the id
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $session.UserAgent = $UserAgent
    $Result_id = Invoke-RestMethod -UseBasicParsing -Uri "https://zonemaster.net/api" -Method "POST" -ContentType "application/json" -WebSession $session -Headers $headers -Body "{
        `"jsonrpc`":`"2.0`",
        `"id`":1715713208665,
        `"method`":`"start_domain_test`",
        `"params`":{
            `"language`":`"en`",
            `"domain`":`"$Domain`",
            `"profile`":`"default`",
            `"nameservers`":[],
            `"ds_info`":[],
            `"client_version`":`"4.2.0`",
            `"client_id`":`"Zonemaster-GUI`"
        }
    }"
    $id = $Result_id.result

    ### Test progress (check the status of tests execution)
    $Code_Response = 0
    while ($Code_Response -ne 100) {
        Start-Sleep 1
        $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
        $session.UserAgent = $UserAgent
        $Result_Code = Invoke-RestMethod -UseBasicParsing -Uri "https://zonemaster.net/api" -Method "POST" -ContentType "application/json" -WebSession $session -Headers $headers -Body "{
            `"jsonrpc`":`"2.0`",
            `"id`":1715713214227,
            `"method`":`"test_progress`",
            `"params`":{
                `"test_id`":`"$id`"
            }
        }"
        $Code_Response = $Result_Code.result
    }

    ### Get test results
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $session.UserAgent = $UserAgent
    $Result = Invoke-RestMethod -UseBasicParsing -Uri "https://zonemaster.net/api" -Method "POST" -ContentType "application/json" -WebSession $session -Headers $headers -Body "{
        `"jsonrpc`":`"2.0`",
        `"id`":1715713214790,
        `"method`":`"get_test_results`",
        `"params`":{
            `"id`":`"$id`",`"language`":`"en`"
        }
    }"

    ### Rebuild the array of results with test comments
    $Collections = New-Object System.Collections.Generic.List[System.Object]
    foreach ($res in $($Result.result.results)) {
        $testcase_descriptions = $Result.result.testcase_descriptions | Get-Member | Where-Object Name -like $res.testcase
        $test_descriptions = $Result.result.testcase_descriptions.$($testcase_descriptions.Name)
        $Collections.Add([PSCustomObject]@{
                Module       = $res.Module
                Test         = $res.testcase
                Descriptions = $test_descriptions
                Level        = $res.level
                Result       = $res.message
            })
    }

    if ($Warning) {
        $Collections = $Collections | where-Object Level -ne "info"
    }

    if ($json) {
        $Result_Domain = "{`"Domain`": `"$($Result.result.params.domain)`"}"
        $Date_json = "{`"Date`": `"$($Result.result.created_at.ToString())`"}"
        $Result_url = "{`"Url`": `"$("https://zonemaster.net/en/result/$id")`"}"
        $Result_json = $Collections | ConvertTo-Json
        $Collections = "[$Result_Domain,$Date_json,$Result_url,$Result_json]"
    }

    elseif ($html) {
        $Style = '
            <style>
                header {
                    background-color: #4051B5;
                    color: white;
                    text-align: center;
                    padding: 20px 0;
                    position: fixed;
                    width: 100%;
                    top: 0;
                    left: 0;
                    z-index: 1000;
                }
                header a {
                    color: white;
                    text-decoration: none;
                    font-size: 26px;
                }
                body {
                    margin: 0;
                    padding-top: 50px;
                    padding-left: 150px;
                    padding-right: 150px;
                }
                h1 {
                    color: #4051B5;
                }
                h2 {
                    color: #4051B5;
                }
                h3 {
                    color: #4051B5;
                }
                table {
                    border-collapse: collapse;
                    width: 100%;
                    margin: auto;
                    font-size: 14px;
                }
                th, td {
                    border: 1px solid black;
                    padding: 8px;
                    text-align: left;
                    cursor: pointer;
                }
                th {
                    background-color: #6495ED;
                    color: white;
                    cursor: pointer;
                    transition: background-color 0.3s;
                }
                th:hover {
                    background-color: #4051B5;
                }
                .ascending::after {
                    content: " ▲";
                }
                .descending::after {
                    content: " ▼";
                }
                .custom-heading .heading {
                    color: #6495ED;
                    font-weight: bold;
                    font-size: 20px;
                }
                .custom-heading .text {
                    color: #000;
                    font-size: 20px;
                }
            </style>
        '
        $Script = '
            <script>
                document.addEventListener("DOMContentLoaded", function() {
                    var tableLinks = document.querySelectorAll("table a");
                    tableLinks.forEach(function(link) {
                        link.setAttribute("target", "_blank");
                    });
                });
                document.addEventListener("DOMContentLoaded", function() {
                    var tables = document.querySelectorAll("table");
                    tables.forEach(function(table) {
                        makeTableSortable(table);
                    });
                });
                function makeTableSortable(table) {
                    var headers = table.querySelectorAll("th");
                    headers.forEach(function(header, index) {
                        header.addEventListener("click", function() {
                            sortTable(table, index);
                        });
                    });
                }
                function sortTable(table, columnIndex) {
                    var rows = Array.from(table.rows).slice(1);
                    var ascending = !table.rows[0].cells[columnIndex].classList.contains("ascending");
                    rows.sort(function(rowA, rowB) {
                        var cellA = rowA.cells[columnIndex].textContent.trim();
                        var cellB = rowB.cells[columnIndex].textContent.trim();
                        return ascending ? cellA.localeCompare(cellB) : cellB.localeCompare(cellA);
                    });
                    rows.forEach(function(row) {
                        table.appendChild(row);
                    });
                    updateHeaderClasses(table, columnIndex, ascending);
                }
                function updateHeaderClasses(table, columnIndex, ascending) {
                    var headers = table.querySelectorAll("th");
                    headers.forEach(function(header, index) {
                        if (index === columnIndex) {
                            if (ascending) {
                                header.classList.add("ascending");
                                header.classList.remove("descending");
                            } else {
                                header.classList.add("descending");
                                header.classList.remove("ascending");
                            }
                        } else {
                            header.classList.remove("ascending");
                            header.classList.remove("descending");
                        }
                    });
                }
            </script>
        '
        $Head = "
            <div class='custom-heading'>
                <span class='heading'>Domain:</span> <span class='text'>$($Result.result.params.domain)</span>
                <br>
                <br>
                <span class='heading'>Date:</span> <span class='text'>$(Get-Date -Format "HH:mm dd.MM.yyyy" -Date $Result.result.created_at)</span>
                <br>
                <br>
                <br>
            </div>
        "
        $collections = $collections | ConvertTo-Html -Title "Domain Test Result" -Head $Style -Body $Script
        $collections = $collections -replace "<table>","$head<table>"
    }

    return $Collections
}