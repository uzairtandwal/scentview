param(
  [switch]$Apply,
  [switch]$WriteMap
)

$ErrorActionPreference = 'Stop'

function Get-Dimensions {
  param([string]$Path)
  $folder = Split-Path -Parent $Path
  $leaf = Split-Path -Leaf $Path
  $sh = New-Object -ComObject Shell.Application
  $ns = $sh.NameSpace($folder)
  if (-not $ns) { return $null }
  $fi = $ns.ParseName($leaf)
  if (-not $fi) { return $null }
  $dim = $ns.GetDetailsOf($fi, 31) # image dimensions
  if ($dim -and ($dim -match '([0-9]{2,6})\s*x\s*([0-9]{2,6})')) {
    return @{ W = [int]$matches[1]; H = [int]$matches[2] }
  }
  # Video metadata
  $vw = $ns.GetDetailsOf($fi, 316) # frame width
  $vh = $ns.GetDetailsOf($fi, 314) # frame height
  if ($vw -and $vh -and $vw -match '\d+' -and $vh -match '\d+') {
    $fr = $ns.GetDetailsOf($fi, 315) # frame rate
    $fps = $null
    if ($fr -match '([0-9]+\.?[0-9]*)') { $fps = $matches[1] }
    return @{ W = [int]$vw; H = [int]$vh; FPS = $fps }
  }
  return $null
}

function Get-Category {
  param([int]$W,[int]$H,[string]$Path)
  if (-not $W -or -not $H) { return 'misc' }
  if ($Path -match '\\logo-name\\') { return 'brand' }
  $ratio = [double]$W / [double]$H
  if ($ratio -ge 2.4 -and $W -ge 1200) { return 'banner' }
  $sq = [math]::Abs($W - $H) -le [math]::Round([math]::Max($W,$H) * 0.05)
  if ($sq -and $W -ge 1000) { return 'home' }
  if ($ratio -lt 1.0) { return 'product' }
  return 'secondary'
}

Write-Host "Scanning assets..." -ForegroundColor Cyan
$root = Join-Path (Get-Location) 'assets'
if (-not (Test-Path $root)) { throw "assets folder not found at $root" }

$imageExts = '*.png','*.jpg','*.jpeg','*.gif','*.webp','*.svg'
$videoExts = '*.mp4','*.mov','*.avi','*.webm','*.mkv'
$files = Get-ChildItem -Recurse -File -Include @($imageExts + $videoExts) -Path $root

$items = @()
foreach ($f in $files) {
  if ($f.FullName -match '\\logo-name\\') { continue }
  $dim = Get-Dimensions -Path $f.FullName
  $W = $dim.W
  $H = $dim.H
  $FPS = $dim.FPS
  $cat = if ($f.Extension -match '(mp4|mov|avi|webm|mkv)') { 'video' } else { Get-Category -W $W -H $H -Path $f.FullName }
  $base = switch ($cat) {
    'banner'      { "banner-${W}x${H}" }
    'home'        { "home-${W}x${H}" }
    'product'     { "product-${W}x${H}" }
    'secondary'   { "secondary-${W}x${H}" }
    'video'       { $fpsStr = if ($FPS) { "-${([int][double]$FPS)}fps" } else { '' }; "home-video-${W}x${H}${fpsStr}" }
    default       { "asset-${W}x${H}" }
  }
  $items += [pscustomobject]@{
    Path = $f.FullName
    Dir  = $f.DirectoryName
    Old  = $f.Name
    W    = $W
    H    = $H
    FPS  = $FPS
    Cat  = $cat
    Ext  = $f.Extension.ToLower()
    Base = $base
  }
}

# ensure unique names within each directory
$map = @()
$groups = $items | Group-Object Dir,Base,Ext
foreach ($g in $groups) {
  $i = 1
  foreach ($it in $g.Group) {
    $suffix = if ($g.Count -gt 1) { "-$i" } else { '' }
    $new = "$($it.Base)$suffix$($it.Ext)"
    $map += [pscustomobject]@{
      Path = $it.Path
      ProposedName = $new
      Category = $it.Cat
      WH = if ($it.W -and $it.H) { "$($it.W)x$($it.H)" } else { '' }
      FPS = $it.FPS
    }
    $i++
  }
}

if ($WriteMap) {
  $csv = $map | Select-Object Path,ProposedName,Category,WH,FPS | ConvertTo-Csv -NoTypeInformation
  $outPath = Join-Path $root '_proposed_renames.csv'
  Set-Content -Path $outPath -Value $csv -Encoding UTF8
  Write-Host "Wrote mapping to $outPath" -ForegroundColor Green
}

if ($Apply) {
  foreach ($m in $map) {
    $dir = Split-Path -Parent $m.Path
    $target = Join-Path $dir $m.ProposedName
    if ((Split-Path -Leaf $m.Path) -ieq $m.ProposedName) { continue }
    if (Test-Path $target) {
      Write-Warning "Target exists, skipping: $target"
      continue
    }
    Write-Host ("Renaming: {0} -> {1}" -f $m.Path, $target) -ForegroundColor Yellow
    Rename-Item -LiteralPath $m.Path -NewName $m.ProposedName
  }
  Write-Host "Renames complete." -ForegroundColor Green
} else {
  Write-Host "Preview (no changes). Use -Apply to rename, -WriteMap to export CSV." -ForegroundColor Cyan
  $map | Sort-Object Path | Format-Table -AutoSize
}

