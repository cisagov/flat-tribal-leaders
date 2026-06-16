#!/usr/bin/env bash
#
# vendor-flat.sh
#
# Helper to vendor the flat library into a local vendor/ folder so the GitHub workflow
# never downloads it from the internet. This is a one-time operation, but you can re-run 
# it to update the version.
#
# Run it:
#   ./vendor-flat.sh          # default version (0.0.15)
#   ./vendor-flat.sh 0.0.16   # or pick a version
#
# Then commit: postprocess.ts, deno.json, deno.lock, vendor/
#
# Needs deno installed: e.g. brew install deno

set -euo pipefail

# Recommended default
FLAT_VERSION="${1:-0.0.15}"

# Repo root
cd "$(dirname "${BASH_SOURCE[0]}")"

POSTPROCESS="postprocess.ts"
DENO_JSON="deno.json"

# preconditions
if ! command -v deno >/dev/null; then
  echo "ERROR: deno is not installed. Install it with:" >&2
  echo "       brew install deno      (or see https://deno.land)" >&2
  exit 1
fi
[ -f "$POSTPROCESS" ] || { echo "ERROR: $POSTPROCESS not found - run from the repo root." >&2; exit 1; }

echo ">> Vendoring flat@${FLAT_VERSION} for ${POSTPROCESS}"
echo "   $(deno --version | head -1)"

# re-pin the flat version in the imports (portable in-place edit)
tmp="$(mktemp)"
sed -E "s#(deno\.land/x/flat@)[0-9]+\.[0-9]+\.[0-9]+#\1${FLAT_VERSION}#g" "$POSTPROCESS" > "$tmp"
mv "$tmp" "$POSTPROCESS"

# make sure deno.json turns vendoring on
if [ ! -f "$DENO_JSON" ]; then
  printf '{\n  "vendor": true\n}\n' > "$DENO_JSON"
  echo "   created $DENO_JSON  (\"vendor\": true)"
elif ! grep -q '"vendor"[[:space:]]*:[[:space:]]*true' "$DENO_JSON"; then
  echo "   WARNING: $DENO_JSON exists but does not set \"vendor\": true - add it, then re-run." >&2
fi

# vendor the dependency tree + (re)write the lockfile
rm -rf vendor deno.lock
deno cache --reload "$POSTPROCESS"

# Verify it runs fully offline
# Run the same command the workflow uses (--cached-only). If the
# data file is present we run end-to-end against a backup copy and restore it
# afterward, so this leaves nothing changed and confirms the new version works.
SAMPLE="tribal-leaders.csv"
echo ">> Verifying postprocess.ts runs offline (--cached-only) ..."
if [ -f "$SAMPLE" ]; then
  out="$(mktemp)"
  cp "$SAMPLE" "${SAMPLE}.vendorbak"
  if deno run --allow-read --allow-write --cached-only "$POSTPROCESS" "$SAMPLE" >"$out" 2>&1; then
    mv -f "${SAMPLE}.vendorbak" "$SAMPLE"
    rm -f "$out"
    echo "   OK - ran end-to-end with no network."
  else
    mv -f "${SAMPLE}.vendorbak" "$SAMPLE"
    echo "   ERROR: offline run failed - vendor/ may be incomplete:" >&2
    cat "$out" >&2
    rm -f "$out"
    exit 1
  fi
else
  deno info "$POSTPROCESS" >/dev/null
  echo "   OK - dependency graph resolves (no data file to run end-to-end)."
fi

echo ""
echo ">> Done. Vendored size:"
du -sh vendor 2>/dev/null || true
echo ">> Commit these: $POSTPROCESS  $DENO_JSON  deno.lock  vendor/"
