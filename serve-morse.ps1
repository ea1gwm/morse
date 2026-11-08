$port = if ($env:PORT) { $env:PORT } else { "8091" }
$root = 'C:\Users\ea1gw\Desktop\Claude\App Morse'
$mime = @{
  '.html'='text/html; charset=utf-8'
  '.js'='application/javascript; charset=utf-8'
  '.json'='application/json; charset=utf-8'
  '.webmanifest'='application/manifest+json; charset=utf-8'
  '.css'='text/css; charset=utf-8'
  '.png'='image/png'
  '.svg'='image/svg+xml'
}
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Listening on http://localhost:$port/"
while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  $rel = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath.TrimStart('/'))
  if ($rel -eq '' -or $rel -eq '/') { $rel = 'index.html' }
  $file = Join-Path $root $rel
  if (Test-Path $file -PathType Leaf) {
    $ext = [IO.Path]::GetExtension($file).ToLower()
    $ctx.Response.ContentType = if ($mime[$ext]) { $mime[$ext] } else { 'application/octet-stream' }
    $bytes = [IO.File]::ReadAllBytes($file)
    $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
  } else {
    $ctx.Response.StatusCode = 404
  }
  $ctx.Response.Close()
}
