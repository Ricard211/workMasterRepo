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

# 3. Bootstrap ESLint if missing
if ! command -v eslint >/dev/null 2>&1; then
  echo "Installing ESLint…"
  npm install --no-save eslint eslint-plugin-security
  export PATH="$PWD/node_modules/.bin:$PATH"
fi

# 4. Semgrep full-repo scan
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

# 5. Bandit for Python
echo "2️⃣ Bandit: Python code analysis"
bandit -r . -f json -o "$SAST_DIR"/bandit-full.json || true

# 6. CodeQL for PHP & JS using the agent-installed CLI
echo "3️⃣ CodeQL: PHP & JS deep dataflow analysis"
codeql database create codeql-db --language=php --language=javascript --source-root=.  
codeql database analyze codeql-db \
  --format=sarif-latest \
  --output="$SAST_DIR"/codeql-full.sarif \
  --threads=1 || true

# 7. ESLint for JavaScript security
echo "4️⃣ ESLint: JavaScript security linting"
eslint . --ext .js,.jsx --format json --output-file "$SAST_DIR"/eslint-full.json || true

echo "✅ Extended SAST complete. Reports in $SAST_DIR"
