#!/usr/bin/env bash
set -euo pipefail

# 1. Clean out any existing Semgrep reports
rm -rf reports/semgrep

# 2. Recreate the reports directory with open permissions
mkdir -p reports/semgrep
chmod a+rwX reports/semgrep

# 3. Determine the Git base for diff
PREV_COMMIT="${GIT_PREVIOUS_SUCCESSFUL_COMMIT:-}"
if [ -n "$PREV_COMMIT" ] && git rev-parse --verify "$PREV_COMMIT" >/dev/null 2>&1; then
  BASE="$PREV_COMMIT"
else
  echo "⚠️ Previous commit not found; falling back to HEAD~1"
  BASE="HEAD~1"
fi

# 4. List changed files between BASE and HEAD
git diff --name-only "$BASE" HEAD -- > changed-files.txt

# 5. Filter for the extensions you want to scan
CHANGED=$(grep -E '\.(php|html|js|py|sh)$' changed-files.txt || true)

# 6. If nothing changed, emit an empty Semgrep JSON
if [ -z "$CHANGED" ]; then
  echo "🟢 No changed source files to scan with Semgrep."
  echo '{"results":[]}' > reports/semgrep/semgrep-report.json
else
  echo "📂 Running Semgrep on changed files:"
  echo "$CHANGED"

  docker run --rm \
    -u "$(id -u):$(id -g)" \
    -v "$PWD:/src" \
    returntocorp/semgrep semgrep scan \
      --config=/src/.semgrep.yml \
      --config=p/owasp-top-ten \
      --config=r/all \
      --config=r/security-audit \
      --config=r/ci-cd \
      --config=r/ci-cd-aws \
      --config=r/ci-cd-gcp \
      --config=r/ci-cd-azure \
      --config=r/ci-cd-azure-pipelines \
      --config=r/ci-cd-azure-pipelines-2 \
      --config=r/ci-cd-azure-devops \
      --config=r/ci-cd-azure-devops-2 \
      --config=r/ci-cd-github-actions \
      --config=r/ci-cd-gitlab-ci \
      --config=r/ci-cd-gitlab-ci-2 \
      --config=r/ci-cd-jenkins \
      --config=r/ci-cd-jenkinsfile \
      --config=r/ci-cd-jenkinsfile-2 \
      --config=r/ci-cd-jenkinsfile-3 \
      --config=r/ci-cd-jenkinsfile-4 \
      --config=r/ci-cd-jenkinsfile-5 \
      --json --output /src/reports/semgrep/semgrep-report.json \
      $CHANGED || true
fi

# 7. Convert JSON to HTML (if you have convert_semgrep_report.sh)
bash convert_semgrep_report.sh reports/semgrep/semgrep-report.json
