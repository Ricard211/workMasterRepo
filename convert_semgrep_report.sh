#!/bin/bash
set -e

INPUT="reports/semgrep-report.json"
OUTPUT="reports/semgrep-report.html"

mkdir -p reports

if [ ! -f "$INPUT" ]; then
    echo "❌ Semgrep report not found: $INPUT"
    exit 1
fi

if [ ! -s "$INPUT" ]; then
    echo "❌ Semgrep report exists but is empty."
    exit 1
fi

# Begin HTML file
cat <<EOF > "$OUTPUT"
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Semgrep Report</title>
    <style>
        body { font-family: sans-serif; padding: 20px; }
        h1 { color: #333; }
        .issue { border-bottom: 1px solid #ddd; padding: 10px 0; }
        .severity { font-weight: bold; color: darkred; }
        .path { font-family: monospace; color: #555; }
        .rule { font-size: 0.9em; color: #666; }
        .message { margin-top: 5px; }
    </style>
</head>
<body>
    <h1>Semgrep Report</h1>
EOF

# Loop through each result and append to HTML
jq -c '.results[]' "$INPUT" | while read -r issue; do
    message=$(echo "$issue" | jq -r '.extra.message')
    severity=$(echo "$issue" | jq -r '.extra.severity')
    path=$(echo "$issue" | jq -r '.path')
    line=$(echo "$issue" | jq -r '.start.line')
    rule_id=$(echo "$issue" | jq -r '.check_id')

    cat <<EOF >> "$OUTPUT"
    <div class="issue">
        <div class="severity">[$severity]</div>
        <div class="path">$path:$line</div>
        <div class="rule">$rule_id</div>
        <div class="message">$message</div>
    </div>
EOF
done

# End HTML file
cat <<EOF >> "$OUTPUT"
</body>
</html>
EOF

echo "✅ HTML report generated: $OUTPUT"
