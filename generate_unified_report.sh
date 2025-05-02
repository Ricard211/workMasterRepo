#!/bin/bash
set -e

OUTPUT="reports/security-report.html"
SEMGREP="reports/semgrep-report.json"
ZAP_DIR="reports"
ZAP_JSON_PATTERN="zap-report-*.json"

echo "🔧 Generating unified security report..."

# Start HTML
cat <<EOF > "$OUTPUT"
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Unified Security Report</title>
  <style>
    body { font-family: sans-serif; padding: 20px; }
    h1 { color: #222; }
    .section { margin-bottom: 30px; }
    .issue { border-bottom: 1px solid #ccc; margin-bottom: 10px; padding-bottom: 10px; }
    .severity { font-weight: bold; color: darkred; }
    .path { font-family: monospace; }
    h2, h3 { margin-top: 1em; }
  </style>
</head>
<body>
<h1>Unified Security Report</h1>
EOF

# Semgrep Section
if [ -s "$SEMGREP" ]; then
  echo "<div class='section'><h2>Semgrep Findings</h2>" >> "$OUTPUT"
  jq -c '.results[]' "$SEMGREP" | while read -r issue; do
    message=$(echo "$issue" | jq -r '.extra.message')
    severity=$(echo "$issue" | jq -r '.extra.severity')
    path=$(echo "$issue" | jq -r '.path')
    line=$(echo "$issue" | jq -r '.start.line')
    rule=$(echo "$issue" | jq -r '.check_id')

    echo "<div class='issue'>
      <div class='severity'>[$severity]</div>
      <div class='path'>$path:$line</div>
      <div><strong>Rule:</strong> $rule</div>
      <div>$message</div>
    </div>" >> "$OUTPUT"
  done
  echo "</div>" >> "$OUTPUT"
else
  echo "<div class='section'><h2>Semgrep: No findings or report missing.</h2></div>" >> "$OUTPUT"
fi

# ZAP Section
echo "<div class='section'><h2>ZAP Findings</h2>" >> "$OUTPUT"
ZAP_FOUND=false

for zapfile in "$ZAP_DIR"/$ZAP_JSON_PATTERN; do
  if [ -s "$zapfile" ]; then
    ZAP_FOUND=true
    PORT=$(echo "$zapfile" | grep -o '[0-9]\{4,5\}')
    echo "<h3>Container on port $PORT</h3>" >> "$OUTPUT"

    jq -c '.site[].alerts[]?' "$zapfile" | while read -r alert; do
      name=$(echo "$alert" | jq -r '.alert')
      risk=$(echo "$alert" | jq -r '.risk')
      url=$(echo "$alert" | jq -r '.instances[0].uri')
      desc=$(echo "$alert" | jq -r '.desc')

      echo "<div class='issue'>
        <div class='severity'>[$risk]</div>
        <div class='path'>$url</div>
        <div><strong>$name</strong></div>
        <div>$desc</div>
      </div>" >> "$OUTPUT"
    done
  fi
done

if [ "$ZAP_FOUND" = false ]; then
  echo "<p>No ZAP findings found in any reports.</p>" >> "$OUTPUT"
fi

# Close HTML
echo "</div></body></html>" >> "$OUTPUT"

echo "✅ Report generated: $OUTPUT"
