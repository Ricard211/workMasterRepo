#!/usr/bin/env bash
set -euo pipefail

SAST_DIR="reports/sast-full"

echo "🔐 Starting extended SAST suite…"

# 1. Clean out any old reports
rm -rf "$SAST_DIR"
mkdir -p "$SAST_DIR"
chmod a+rwX "$SAST_DIR"

# 2. Bootstrap Bandit if missing
if ! command -v bandit >/dev/null 2>&1; then
  echo "Installing Bandit…"
  pip3 install --user bandit
  export PATH="$HOME/.local/bin:$PATH"
fi

# 3. Bootstrap CodeQL CLI if missing
if ! command -v codeql >/dev/null 2>&1; then
  echo "Downloading CodeQL CLI…"
  curl -sSL "https://github.com/github/codeql-cli-binaries/releases/download/v2.25.3/codeql.zip" -o codeql.zip
  unzip -q codeql.zip -d codeql
  export PATH="$PWD/codeql:$PATH"
fi

# 4. Bootstrap ESLint if missing
if ! command -v eslint >/dev/null 2>&1; then
  echo "Installing ESLint…"
  npm install --no-save eslint eslint-plugin-security
  export PATH="$PWD/node_modules/.bin:$PATH"
fi

# 5. Run Semgrep over the entire workspace, single-threaded, no ignores
echo "1️⃣ Semgrep: full repo scan, no-ignore, single job, all packs, metrics on"
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

# 6. Bandit for Python
echo "2️⃣ Bandit: Python code analysis"
bandit -r . -f json -o "$SAST_DIR"/bandit-full.json || true

# 7. CodeQL deep analysis for PHP & JS
echo "3️⃣ CodeQL: PHP & JS deep dataflow analysis"
codeql database create codeql-full-db --language=php --language=javascript --source-root=.  
codeql database analyze codeql-full-db \
  --format=sarif-latest \
  --output="$SAST_DIR"/codeql-full.sarif \
  --threads=1 || true

# 8. ESLint for JavaScript security patterns
echo "4️⃣ ESLint: JavaScript security linting"
eslint . --ext .js,.jsx --format json --output-file "$SAST_DIR"/eslint-full.json || true

echo "✅ Extended SAST complete. Reports in $SAST_DIR"
