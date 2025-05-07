#!/usr/bin/env bash
set -euo pipefail

SAST_DIR="reports/sast"
mkdir -p "$SAST_DIR"

echo "🔐 1) Semgrep (full repo, no-ignore, single job, extra rule packs)"
docker run --rm -v "$PWD:/src" returntocorp/semgrep semgrep scan \
  --config=/src/.semgrep.yml \
  --config=p/owasp-top-ten \
  --config=p/python \
  --config=p/javascript \
  --no-git-ignore \
  --jobs 1 \
  --json --output "/src/$SAST_DIR/semgrep-full.json" \
  /src

echo "🔒 Converting Semgrep JSON → HTML"
bash convert_semgrep_report.sh "/src/$SAST_DIR/semgrep-full.json" "/src/$SAST_DIR/semgrep-full.html"

echo "🐍 2) Bandit (Python security linter)"
if command -v bandit >/dev/null 2>&1; then
  bandit -r . -f json -o "$SAST_DIR/bandit.json" || true
else
  echo "⚠️  bandit not installed; skipping"
fi

echo "🛡️ 3) CodeQL (PHP & JS dataflow analysis)"
# Assume CodeQL CLI is installed and QL packs are downloaded
codeql database create codeql-db --language=php --language=javascript --source-root=.  
codeql database analyze codeql-db \
  --format=sarif-latest \
  --output="$SAST_DIR/codeql-results.sarif" \
  --threads=2 \
  --search-path=node_modules

echo "📜 4) ESLint (JS security checks)"
if command -v eslint >/dev/null 2>&1; then
  eslint . --ext .js,.jsx --format json --output-file "$SAST_DIR/eslint.json" || true
else
  echo "⚠️  eslint not installed; skipping"
fi

echo "✅ All SAST tools have run. Reports in $SAST_DIR"
