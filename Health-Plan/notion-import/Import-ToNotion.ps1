# Imports the meal-planner CSVs into a Notion page as four databases.
# Usage:
#   $env:NOTION_TOKEN = "<integration token>"
#   .\Import-ToNotion.ps1 -ParentPageId "3c86104b-076c-80d2-9de8-fcdb8b394719"

param(
  [Parameter(Mandatory = $true)]
  [string]$ParentPageId
)

$ErrorActionPreference = "Stop"
$token = $env:NOTION_TOKEN
if (-not $token) {
  throw "Set NOTION_TOKEN to your Notion integration token, then re-run."
}

$version = "2022-06-28"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$headers = @{
  Authorization = "Bearer $token"
  "Notion-Version" = $version
  "Content-Type" = "application/json"
}

function ConvertTo-Utf8Json($obj) {
  return ($obj | ConvertTo-Json -Depth 20 -Compress)
}

function Invoke-Notion {
  param([string]$Method, [string]$Path, $Body, [string]$Json)
  $uri = "https://api.notion.com/v1/$Path"
  try {
    $payload = $null
    if ($Json) { $payload = $Json }
    elseif ($null -ne $Body) { $payload = ConvertTo-Utf8Json $Body }
    if ($null -ne $payload) {
      return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -Body $payload
    }
    return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers
  } catch {
    $detail = $_.ErrorDetails.Message
    throw "Notion $Method $Path failed: $($_.Exception.Message) $detail"
  }
}

function Escape-Json([string]$text) {
  if ($null -eq $text) { $text = "" }
  if ($text.Length -gt 1900) { $text = $text.Substring(0, 1900) }
  $text = $text.Replace('\', '\\').Replace('"', '\"').Replace("`r", '').Replace("`n", '\n')
  return $text
}

function New-RichArrayJson([string]$text) {
  return '[{"type":"text","text":{"content":"' + (Escape-Json $text) + '"}}]'
}

function Get-ChildDatabases {
  $found = @{}
  $cursor = $null
  do {
    $path = "blocks/$ParentPageId/children?page_size=100"
    if ($cursor) { $path += "&start_cursor=$cursor" }
    $resp = Invoke-Notion -Method Get -Path $path
    foreach ($block in $resp.results) {
      if ($block.type -eq "child_database") {
        $found[$block.child_database.title] = $block.id
      }
    }
    if ($resp.has_more) { $cursor = $resp.next_cursor } else { $cursor = $null }
  } while ($cursor)
  return $found
}

function Get-ExistingTitles($databaseId) {
  $titles = New-Object 'System.Collections.Generic.HashSet[string]'
  $cursor = $null
  do {
    $json = '{"page_size":100}'
    if ($cursor) { $json = '{"page_size":100,"start_cursor":"' + $cursor + '"}' }
    $resp = Invoke-Notion -Method Post -Path "databases/$databaseId/query" -Json $json
    foreach ($row in $resp.results) {
      $titleBits = $row.properties.Name.title
      if ($titleBits) {
        $name = ($titleBits | ForEach-Object { $_.plain_text }) -join ""
        if ($name) { [void]$titles.Add($name) }
      }
    }
    if ($resp.has_more) { $cursor = $resp.next_cursor } else { $cursor = $null }
  } while ($cursor)
  return ,$titles
}

function New-Database($title, $properties) {
  $body = @{
    parent = @{ type = "page_id"; page_id = $ParentPageId }
    title = @(@{ type = "text"; text = @{ content = $title } })
    properties = $properties
  }
  $db = Invoke-Notion -Method Post -Path "databases" -Body $body
  Write-Host "Created database: $title ($($db.id))"
  $script:existing[$title] = $db.id
  return $db.id
}

function Get-OrCreateDatabase($title, $properties) {
  if ($script:existing.ContainsKey($title)) {
    Write-Host "Reusing database: $title ($($script:existing[$title]))"
    return $script:existing[$title]
  }
  return New-Database $title $properties
}

function Add-RowJson($databaseId, [string]$propertiesJson) {
  $json = '{"parent":{"database_id":"' + $databaseId + '"},"properties":' + $propertiesJson + '}'
  Invoke-Notion -Method Post -Path "pages" -Json $json | Out-Null
  Start-Sleep -Milliseconds 350
}

Write-Host "Checking token..."
$me = Invoke-Notion -Method Get -Path "users/me"
Write-Host ("Authenticated as " + $me.name + " (" + $me.type + ")")

Write-Host "Checking parent page..."
$page = Invoke-Notion -Method Get -Path "pages/$ParentPageId"
Write-Host ("Parent page ok: " + $page.id)

$script:existing = Get-ChildDatabases
if (-not $script:existing) { $script:existing = @{} }

# --- Monthly Planner ---
$plannerId = Get-OrCreateDatabase "Monthly Planner" @{
  Name = @{ title = @{} }
  "Day Number" = @{ number = @{ format = "number" } }
  "Day of Week" = @{
    select = @{
      options = @(
        @{ name = "Monday"; color = "blue" }
        @{ name = "Tuesday"; color = "green" }
        @{ name = "Wednesday"; color = "yellow" }
        @{ name = "Thursday"; color = "orange" }
        @{ name = "Friday"; color = "red" }
        @{ name = "Saturday"; color = "purple" }
        @{ name = "Sunday"; color = "pink" }
      )
    }
  }
  Breakfast = @{ rich_text = @{} }
  Lunch = @{ rich_text = @{} }
  Dinner = @{ rich_text = @{} }
  "Snack / Notes" = @{ rich_text = @{} }
  Status = @{
    select = @{
      options = @(
        @{ name = "Not started"; color = "gray" }
        @{ name = "In progress"; color = "blue" }
        @{ name = "Done"; color = "green" }
      )
    }
  }
}

$plannerTitles = Get-ExistingTitles $plannerId
if (-not $plannerTitles) { $plannerTitles = New-Object 'System.Collections.Generic.HashSet[string]' }
$plannerCsv = Import-Csv -LiteralPath (Join-Path $here "Notion_Monthly_Planner.csv")
$plannerAdded = 0
foreach ($row in $plannerCsv) {
  if ($plannerTitles.Contains($row.Name)) { continue }
  $props = '{' +
    '"Name":{"title":[{"text":{"content":"' + (Escape-Json $row.Name) + '"}}]},' +
    '"Day Number":{"number":' + [int]$row."Day Number" + '},' +
    '"Day of Week":{"select":{"name":"' + (Escape-Json $row."Day of Week") + '"}},' +
    '"Breakfast":{"rich_text":' + (New-RichArrayJson $row.Breakfast) + '},' +
    '"Lunch":{"rich_text":' + (New-RichArrayJson $row.Lunch) + '},' +
    '"Dinner":{"rich_text":' + (New-RichArrayJson $row.Dinner) + '},' +
    '"Snack / Notes":{"rich_text":' + (New-RichArrayJson $row."Snack / Notes") + '},' +
    '"Status":{"select":{"name":"' + (Escape-Json $row.Status) + '"}}' +
    '}'
  Add-RowJson $plannerId $props
  $plannerAdded++
}
Write-Host "Loaded $plannerAdded new monthly planner rows (skipped $($plannerTitles.Count) existing)"

# --- Meal Ideas Bank ---
$ideasId = Get-OrCreateDatabase "Meal Ideas Bank" @{
  Name = @{ title = @{} }
  Category = @{
    select = @{
      options = @(
        @{ name = "Breakfast"; color = "yellow" }
        @{ name = "Lunch"; color = "green" }
        @{ name = "Dinner"; color = "blue" }
        @{ name = "Snack / Side"; color = "orange" }
      )
    }
  }
}
$ideasTitles = Get-ExistingTitles $ideasId
if (-not $ideasTitles) { $ideasTitles = New-Object 'System.Collections.Generic.HashSet[string]' }
$ideasCsv = Import-Csv -LiteralPath (Join-Path $here "Notion_Meal_Ideas_Bank.csv")
$ideasAdded = 0
foreach ($row in $ideasCsv) {
  if ($ideasTitles.Contains($row.Name)) { continue }
  $props = '{' +
    '"Name":{"title":[{"text":{"content":"' + (Escape-Json $row.Name) + '"}}]},' +
    '"Category":{"select":{"name":"' + (Escape-Json $row.Category) + '"}}' +
    '}'
  Add-RowJson $ideasId $props
  $ideasAdded++
}
Write-Host "Loaded $ideasAdded new meal ideas"

# --- Shopping List ---
$shopId = Get-OrCreateDatabase "Shopping List" @{
  Name = @{ title = @{} }
  Category = @{
    select = @{
      options = @(
        @{ name = "Proteins"; color = "red" }
        @{ name = "Healthy Fats & Dairy"; color = "yellow" }
        @{ name = "Low-Carb Vegetables"; color = "green" }
        @{ name = "Pantry & Other"; color = "gray" }
      )
    }
  }
  Needed = @{ checkbox = @{} }
}
$shopTitles = Get-ExistingTitles $shopId
if (-not $shopTitles) { $shopTitles = New-Object 'System.Collections.Generic.HashSet[string]' }
$shopCsv = Import-Csv -LiteralPath (Join-Path $here "Notion_Shopping_List.csv")
$shopAdded = 0
foreach ($row in $shopCsv) {
  if ($shopTitles.Contains($row.Name)) { continue }
  $needed = if ($row.Needed -eq "Yes") { "true" } else { "false" }
  $props = '{' +
    '"Name":{"title":[{"text":{"content":"' + (Escape-Json $row.Name) + '"}}]},' +
    '"Category":{"select":{"name":"' + (Escape-Json $row.Category) + '"}},' +
    '"Needed":{"checkbox":' + $needed + '}' +
    '}'
  Add-RowJson $shopId $props
  $shopAdded++
}
Write-Host "Loaded $shopAdded new shopping items"

# --- Macro Guide ---
$guideId = Get-OrCreateDatabase "Macro Guide & Principles" @{
  Name = @{ title = @{} }
  Type = @{
    select = @{
      options = @(
        @{ name = "Principle"; color = "blue" }
        @{ name = "Macro Target"; color = "green" }
        @{ name = "Disclaimer"; color = "gray" }
      )
    }
  }
  Details = @{ rich_text = @{} }
}
$guideTitles = Get-ExistingTitles $guideId
if (-not $guideTitles) { $guideTitles = New-Object 'System.Collections.Generic.HashSet[string]' }
$guideCsv = Import-Csv -LiteralPath (Join-Path $here "Notion_Macro_Guide.csv")
$guideAdded = 0
foreach ($row in $guideCsv) {
  if ($guideTitles.Contains($row.Name)) { continue }
  $props = '{' +
    '"Name":{"title":[{"text":{"content":"' + (Escape-Json $row.Name) + '"}}]},' +
    '"Type":{"select":{"name":"' + (Escape-Json $row.Type) + '"}},' +
    '"Details":{"rich_text":' + (New-RichArrayJson $row.Details) + '}' +
    '}'
  Add-RowJson $guideId $props
  $guideAdded++
}
Write-Host "Loaded $guideAdded new guide rows"
Write-Host "Done."
Write-Host "Planner=$plannerId"
Write-Host "Ideas=$ideasId"
Write-Host "Shopping=$shopId"
Write-Host "Guide=$guideId"
