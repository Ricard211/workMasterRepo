#!/usr/bin/env bash
set -euo pipefail

SAST_DIR="reports/sast-full"
rm -rf "$SAST_DIR"
mkdir -p "$SAST_DIR"
chmod a+rwX "$SAST_DIR"

echo "🔐 Starting extended SAST suite…"

echo "1️⃣ Semgrep: full repo, no-ignore, single job, all packs, metrics on"
docker run --rm \
  -u "$(id -u):$(id -g)" \
  -e HOME=/src \
  -v "$PWD:/src" \
  returntocorp/semgrep semgrep scan \
    --no-git-ignore \
    --jobs 1 \
    --metrics=on \
    --config=/src/.semgrep.yml \
    --config=p/owasp-top-ten \
    --config=p/python \
    --config=p/javascript \
    --config=p/security-audit \
    --config=p/ci-cd \
    --config=p/ci-cd-aws \
    --config=p/ci-cd-gcp \
    --config=p/ci-cd-azure \
    --config=p/dockerfile \
    --config=p/kubernetes \
    --config=p/terraform \
    --config=p/secrets \
    --config=p/coding-practices \
    --json --output /src/"$SAST_DIR"/semgrep-full.json \
    /src || true

echo "2️⃣ Bandit: Python linting"
if command -v bandit >/dev/null 2>&1; then
  bandit -r . -f json -o "$SAST_DIR"/bandit-full.json || true
else
  echo "⚠️  Bandit not installed, skipping"
fi

echo "3️⃣ CodeQL: PHP & JS deep analysis"
if command -v codeql >/dev/null 2>&1; then
  codeql database create codeql-full-db --language=php --language=javascript --source-root=.  
  codeql database analyze codeql-full-db \
    --format=sarif-latest \
    --output="$SAST_DIR"/codeql-full.sarif \
    --threads=1 || true
else
  echo "⚠️  CodeQL CLI not installed, skipping"
fi

echo "4️⃣ ESLint: JavaScript security"
if command -v eslint >/dev/null 2>&1; then
  eslint . --ext .js,.jsx --format json --output-file "$SAST_DIR"/eslint-full.json || true
else
  echo "⚠️  ESLint not installed, skipping"
fi

echo "✅ Extended SAST complete. Reports in $SAST_DIR"
