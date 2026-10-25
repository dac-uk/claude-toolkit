#!/usr/bin/env bash
# Install dac-toolkit bundles at user scope, so every repo on this machine gets them.
#
#   setup/install.sh                  # the core bundle
#   setup/install.sh core ios web     # several bundles
#   setup/install.sh all
#
# Works on macOS (bash 3.2) and Linux, and as a cloud environment setup script (see
# README). Safe to re-run: installed plugins are skipped, missing ones are added.
#
#   TOOLKIT_SOURCE  marketplace source to add (default: dac-uk/claude-toolkit; a local
#                   path works for testing a checkout)
#   TOOLKIT_SOFT=1  never exit non-zero — for setup scripts, where a failure would
#                   stop the session from starting
set -uo pipefail

SOURCE="${TOOLKIT_SOURCE:-dac-uk/claude-toolkit}"
MARKET=dac-toolkit
ALL="core ios web agents security aws"

fail() {
  echo "claude-toolkit: $*" >&2
  [ "${TOOLKIT_SOFT:-}" = 1 ] && exit 0
  exit 1
}

if [ $# -eq 0 ]; then
  set -- core
elif [ "$1" = all ]; then
  # shellcheck disable=SC2086
  set -- $ALL
fi

for bundle in "$@"; do
  case " $ALL " in *" $bundle "*) ;; *) fail "unknown bundle '$bundle' (have: $ALL)" ;; esac
done

command -v claude >/dev/null 2>&1 || fail "claude CLI not found — install Claude Code first"

# Language servers the LSP plugins in core drive. SourceKit-LSP (ios) ships with Xcode.
if command -v npm >/dev/null 2>&1; then
  missing=""
  command -v typescript-language-server >/dev/null 2>&1 || missing="$missing typescript-language-server typescript"
  command -v pyright-langserver >/dev/null 2>&1 || missing="$missing pyright"
  # shellcheck disable=SC2086
  [ -n "$missing" ] && { npm install -g --no-fund --no-audit $missing >/dev/null 2>&1 || echo "claude-toolkit: could not install$missing (npm)" >&2; }
else
  echo "claude-toolkit: npm not found — skipping language servers" >&2
fi

if claude plugin marketplace list 2>/dev/null | grep -q "> $MARKET\$"; then
  claude plugin marketplace update "$MARKET" >/dev/null 2>&1 || true
else
  claude plugin marketplace add "$SOURCE" --scope user || fail "could not add marketplace $SOURCE"
fi

failed=""
for bundle in "$@"; do
  echo "→ $bundle"
  claude plugin install "$bundle@$MARKET" --scope user || failed="$failed $bundle"
done

[ -n "$failed" ] && fail "failed to install:$failed"
echo "claude-toolkit: done — restart Claude Code (or run /reload-plugins) to load them."
