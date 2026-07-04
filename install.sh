#!/usr/bin/env bash
# Install the laravel-skills kit into a project WITHOUT overwriting anything.
# The kit is authored once in the tool-neutral kit/ dir and compiled per assistant:
#   Claude Code → .claude/ (CLAUDE.md, skills/, commands/, spdd-templates/)
#   Codex       → AGENTS.md (repo root) + .agents/skills/ (skills + commands-as-skills)
# Existing same-named files are kept; the conventions block is appended, not replaced.
# Run bare `./install.sh` for a guided interactive install (asks for dir, assistant, CI).
#   usage: ./install.sh [/path/to/project] [--target claude|codex|both] [--ci]
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
KIT="$SRC/kit"
MARK="<!-- laravel-skills conventions (managed) -->"

DST=""
TARGET=""
CI=0
ORIG_ARGC=$#

while [ $# -gt 0 ]; do
  case "$1" in
    --ci)         CI=1 ;;
    --target)     shift; TARGET="${1:-}" ;;
    --target=*)   TARGET="${1#*=}" ;;
    --claude)     TARGET="claude" ;;
    --codex)      TARGET="codex" ;;
    --both)       TARGET="both" ;;
    -h|--help)    sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*)           echo "error: unknown option: $1" >&2; exit 1 ;;
    *)            DST="$1" ;;
  esac
  shift
done

if [ "$ORIG_ARGC" -eq 0 ] && [ -t 0 ]; then
  echo "laravel-skills — interactive install"
  echo ""
fi

# Prompt for the target directory when none was given (interactive); else require it.
if [ -z "$DST" ]; then
  if [ -t 0 ]; then
    while :; do
      printf 'Install into which project directory? '
      read -r DST || exit 1
      DST="${DST/#\~/$HOME}"; DST="${DST%/}"
      [ -n "$DST" ] || { echo "  aborted."; exit 1; }
      [ -d "$DST" ] && break
      echo "  not a directory: $DST — try again (Ctrl-C to abort)."
    done
  else
    echo "usage: ./install.sh [/path/to/project] [--target claude|codex|both] [--ci]" >&2; exit 1
  fi
fi
[ -d "$DST" ] || { echo "error: $DST is not a directory" >&2; exit 1; }

# Ask interactively when no --target was given; fall back to Claude when non-interactive
# (keeps existing `./install.sh /path` scripts working as before).
if [ -z "$TARGET" ]; then
  if [ -t 0 ]; then
    printf 'Which AI assistant should this kit target?\n'
    printf '  1) Claude Code   (.claude/)\n'
    printf '  2) Codex         (AGENTS.md + .agents/skills/)\n'
    printf '  3) Both\n'
    printf '> '
    read -r choice
    case "$choice" in
      1|claude) TARGET=claude ;;
      2|codex)  TARGET=codex ;;
      3|both)   TARGET=both ;;
      *) echo "error: invalid choice '$choice'" >&2; exit 1 ;;
    esac
  else
    TARGET=claude
    echo "note: no --target given and not a TTY — defaulting to claude (use --target codex|both to change)"
  fi
fi

case "$TARGET" in claude|codex|both) ;; *) echo "error: --target must be claude|codex|both" >&2; exit 1 ;; esac

# Bare interactive run (`./install.sh` with no args): also offer CI + a final confirmation.
if [ "$ORIG_ARGC" -eq 0 ] && [ -t 0 ]; then
  if [ "$CI" -eq 0 ]; then
    printf 'Add the CI pipeline (Pint · Larastan · GitHub Actions)? [y/N] '
    read -r yn || true
    case "$yn" in y|Y|yes|YES) CI=1 ;; esac
  fi
  printf '\n→ install into %s\n  assistant:   %s\n  CI pipeline: %s\nProceed? [Y/n] ' \
    "$DST" "$TARGET" "$([ "$CI" -eq 1 ] && echo yes || echo no)"
  read -r ok || true
  case "$ok" in n|N|no|NO) echo "aborted."; exit 1 ;; esac
  echo ""
fi

# --- path rewrites: neutral kit/ references → each assistant's installed layout (stdin → stdout)
# neutral tokens:  conventions.md · commands/spdd-<x>.md · spdd-templates/<x>.md
claude_rewrite() {
  sed -e 's#commands/\(spdd-[a-z-]*\)\.md#.claude/commands/\1.md#g' \
      -e 's#commands/spdd-\*\.md#.claude/commands/spdd-*.md#g' \
      -e 's#spdd-templates/#.claude/spdd-templates/#g' \
      -e 's#conventions\.md#.claude/CLAUDE.md#g'
}
codex_rewrite() {
  sed -e 's#commands/\(spdd-[a-z-]*\)\.md#.agents/skills/\1/SKILL.md#g' \
      -e 's#commands/spdd-\*\.md#.agents/skills/spdd-*/SKILL.md#g' \
      -e 's#spdd-templates/#.agents/spdd-templates/#g' \
      -e 's#conventions\.md#AGENTS.md#g'
}

# copy every file under $1 into $2 through filter $3, skipping any that already exist
render_tree() {
  local s="$1" d="$2" filter="$3" f rel
  [ -d "$s" ] || return 0
  find "$s" -type f | while IFS= read -r f; do
    rel="${f#"$s"/}"
    [ -e "$d/$rel" ] && continue
    mkdir -p "$d/$(dirname "$rel")"
    $filter < "$f" > "$d/$rel"
  done
}

# create the conventions doc, or append our block once (idempotent via marker)
install_conventions() {
  local target="$1" label="$2" filter="$3"
  mkdir -p "$(dirname "$target")"
  if [ ! -f "$target" ]; then
    { printf '%s\n\n' "$MARK"; $filter < "$KIT/conventions.md"; } > "$target"
    echo "$label: created"
  elif grep -qF "$MARK" "$target"; then
    echo "$label: already has our block — skipped (delete the marked block + re-run to refresh)"
  else
    { printf '\n%s\n\n' "$MARK"; $filter < "$KIT/conventions.md"; } >> "$target"
    echo "$label: appended our block (your existing rules untouched)"
  fi
}

install_claude() {
  render_tree "$KIT/skills"         "$DST/.claude/skills"         claude_rewrite
  render_tree "$KIT/commands"       "$DST/.claude/commands"       claude_rewrite
  render_tree "$KIT/spdd-templates" "$DST/.claude/spdd-templates" claude_rewrite
  install_conventions "$DST/.claude/CLAUDE.md" "CLAUDE.md" claude_rewrite
  echo "claude: .claude/ (CLAUDE.md + skills/commands/templates) written (existing kept)"
}

install_codex() {
  local cmd slug out
  # conventions → AGENTS.md at repo root
  install_conventions "$DST/AGENTS.md" "AGENTS.md" codex_rewrite
  # skills → .agents/skills/<name>/
  render_tree "$KIT/skills" "$DST/.agents/skills" codex_rewrite
  # commands → command-as-skill: .agents/skills/<slug>/SKILL.md (inject name, rewrite refs)
  for cmd in "$KIT/commands"/*.md; do
    [ -e "$cmd" ] || continue
    slug="$(basename "$cmd" .md)"
    out="$DST/.agents/skills/$slug/SKILL.md"
    [ -e "$out" ] && continue
    mkdir -p "$DST/.agents/skills/$slug"
    awk -v name="$slug" 'NR==1 && $0=="---" { print; print "name: " name; next } { print }' "$cmd" \
      | codex_rewrite > "$out"
  done
  # templates → .agents/spdd-templates/
  render_tree "$KIT/spdd-templates" "$DST/.agents/spdd-templates" codex_rewrite
  echo "codex: AGENTS.md + .agents/skills/ (skills + commands-as-skills) + templates written (existing kept)"
}

case "$TARGET" in
  claude) install_claude ;;
  codex)  install_codex ;;
  both)   install_claude; install_codex ;;
esac

# CI (optional) — tool-agnostic (Pint / Larastan / Pest); never overwrite
if [ "$CI" -eq 1 ]; then
  render_tree "$SRC/ci/github-actions" "$DST/.github/workflows" cat
  for f in pint.json phpstan.neon; do [ -e "$DST/$f" ] || cp "$SRC/ci/$f" "$DST/$f"; done
  echo "ci: workflows + pint/phpstan copied (existing kept)"
fi

echo "done → $DST  (target: $TARGET)"
