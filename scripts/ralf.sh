#!/usr/bin/env bash
# RALF — Recursive Autonomous Loop Framework
# meta-ads-pipeline | SDD Deborah Folloni
# Usage: ./scripts/ralf.sh [--tipo Banco] [--spec 1] [--issue 1.1] [--dry-run]

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PRD_JSON="$PROJECT_ROOT/prd.json"
PROGRESS_JSON="$PROJECT_ROOT/progress.json"
AGENTS_MD="$PROJECT_ROOT/agents.md"
LOGS_DIR="$PROJECT_ROOT/.ralf-logs"

# SDD execution order (matches prd.json execution_order)
EXECUTION_ORDER=("Configuração" "Banco" "UI Shell" "Backend" "UI Funcional" "Integração")

# ─── CLI Flags ────────────────────────────────────────────────────────────────
FILTER_TIPO=""
FILTER_SPEC=""
FILTER_ISSUE=""
DRY_RUN=false
RESET_PROGRESS=false
SHOW_STATUS=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tipo)
      FILTER_TIPO="$2"
      shift 2
      ;;
    --spec)
      FILTER_SPEC="$2"
      shift 2
      ;;
    --issue)
      FILTER_ISSUE="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --reset)
      RESET_PROGRESS=true
      shift
      ;;
    --status)
      SHOW_STATUS=true
      shift
      ;;
    *)
      echo "Unknown flag: $1"
      echo "Usage: $0 [--tipo Banco] [--spec 1] [--issue 1.1] [--dry-run] [--reset] [--status]"
      exit 1
      ;;
  esac
done

# ─── Validações ───────────────────────────────────────────────────────────────
if [ ! -f "$PRD_JSON" ] && [ "$SHOW_STATUS" = false ] && [ "$RESET_PROGRESS" = false ]; then
  echo "ERROR: prd.json not found at $PRD_JSON"
  echo "  Generate it with: ./scripts/spec-to-prd.sh <SPEC_NAME>"
  exit 1
fi

if ! command -v node &>/dev/null; then
  echo "ERROR: node not found. Install Node.js first."
  exit 1
fi

if ! command -v claude &>/dev/null && [ "$DRY_RUN" = false ] && [ "$SHOW_STATUS" = false ] && [ "$RESET_PROGRESS" = false ]; then
  echo "ERROR: claude CLI not found."
  echo "  Install with: npm install -g @anthropic-ai/claude-code"
  exit 1
fi

# ─── Setup ────────────────────────────────────────────────────────────────────
mkdir -p "$LOGS_DIR"

# ─── --reset ──────────────────────────────────────────────────────────────────
if [ "$RESET_PROGRESS" = true ]; then
  cat > "$PROGRESS_JSON" <<'EOF'
{
  "project": "meta-ads-pipeline",
  "started_at": null,
  "last_updated": null,
  "completed": [],
  "in_progress": null,
  "failed": [],
  "skipped": []
}
EOF
  echo "progress.json reset to empty state."
  exit 0
fi

# ─── Node helper: flatten all issues from prd.json ────────────────────────────
# Supports both:
#   - Multi-spec format: { specs: [{ id, issues: [...] }] }
#   - Single-spec format: { stories: [...] } or { issues: [...] }
FLATTEN_ISSUES_JS='
function flattenIssues(prd) {
  // Multi-spec format (real prd.json)
  if (prd.specs && Array.isArray(prd.specs)) {
    const all = [];
    for (const spec of prd.specs) {
      for (const issue of (spec.issues || [])) {
        all.push({ ...issue, _spec_id: spec.id, _spec_title: spec.title });
      }
    }
    return all;
  }
  // Fallback: flat format
  return prd.issues || prd.stories || [];
}
'

# ─── --status ─────────────────────────────────────────────────────────────────
if [ "$SHOW_STATUS" = true ]; then
  node -e "
$FLATTEN_ISSUES_JS

const fs = require('fs');
const prd      = JSON.parse(fs.readFileSync('$PRD_JSON', 'utf8'));
const progress = JSON.parse(fs.readFileSync('$PROGRESS_JSON', 'utf8'));
const completed = new Set(progress.completed || []);
const issues = flattenIssues(prd);

const executionOrder = prd.execution_order || ['Configuração','Banco','UI Shell','Backend','UI Funcional','Integração'];

const grouped = {};
for (const t of executionOrder) grouped[t] = { total: 0, done: 0 };

for (const issue of issues) {
  const tipo = issue.tipo || issue.type || 'Outros';
  if (!grouped[tipo]) grouped[tipo] = { total: 0, done: 0 };
  grouped[tipo].total++;
  const isDone = completed.has(issue.id) || issue.pass === true || issue.status === 'done';
  if (isDone) grouped[tipo].done++;
}

const bar = (done, total, width) => {
  width = width || 10;
  if (total === 0) return '░'.repeat(width);
  const filled = Math.round((done / total) * width);
  return '█'.repeat(filled) + '░'.repeat(width - filled);
};

const pad = (s, n) => String(s).padEnd(n, ' ');
const rpad = (s, n) => String(s).padStart(n, ' ');

console.log('');
console.log('RALF Status — meta-ads-pipeline');
console.log('─'.repeat(50));

let gTotal = 0, gDone = 0;
const allTipos = [...executionOrder, 'Outros'].filter(t => grouped[t] && grouped[t].total > 0);
for (const tipo of allTipos) {
  const g = grouped[tipo];
  if (g.total === 0) continue;
  gTotal += g.total; gDone += g.done;
  const pct = ((g.done / g.total) * 100).toFixed(1);
  console.log(pad(tipo, 14) + '  ' + bar(g.done, g.total) + '  ' + rpad(g.done,3) + '/' + String(g.total).padEnd(4,' ') + ' (' + pct + '%)');
}
console.log('─'.repeat(50));
const pct = gTotal > 0 ? ((gDone / gTotal) * 100).toFixed(1) : '0.0';
console.log(pad('Total', 14) + '  ' + bar(gDone, gTotal) + '  ' + rpad(gDone,3) + '/' + String(gTotal).padEnd(4,' ') + ' (' + pct + '%)');
console.log('');
if (progress.in_progress) console.log('In progress:  ' + progress.in_progress);
if (progress.last_updated) console.log('Last updated: ' + progress.last_updated);
console.log('');
"
  exit 0
fi

# ─── get_next_issue ───────────────────────────────────────────────────────────
get_next_issue() {
  node -e "
$FLATTEN_ISSUES_JS

const fs = require('fs');
const prd      = JSON.parse(fs.readFileSync('$PRD_JSON', 'utf8'));
const progress = JSON.parse(fs.readFileSync('$PROGRESS_JSON', 'utf8'));

const completed  = new Set(progress.completed || []);
const failed     = new Set(progress.failed    || []);
const allIssues  = flattenIssues(prd);
const allIds     = new Set(allIssues.map(i => i.id));

const filterTipo  = '$FILTER_TIPO';
const filterSpec  = '$FILTER_SPEC';
const filterIssue = '$FILTER_ISSUE';
const dryRunSeen  = new Set((process.env.RALF_DRY_SEEN || '').split(' ').filter(Boolean));

const executionOrder = prd.execution_order || ['Configuração','Banco','UI Shell','Backend','UI Funcional','Integração'];

function getSpec(issue) {
  return String(issue.spec_id || issue._spec_id || String(issue.id).split('.')[0]);
}

function getTipo(issue) {
  return issue.tipo || issue.type || '';
}

function isPending(issue) {
  return !completed.has(issue.id) && !failed.has(issue.id) && !dryRunSeen.has(issue.id) && issue.pass !== true && issue.status !== 'done';
}

function cleanDep(dep) {
  // Normalize dep strings like 'Issue 01.1' -> '1.1', '1.1' -> '1.1'
  return dep.replace(/^Issue\s+0*/i, '').trim();
}

function depsOk(issue) {
  const deps = (issue.depende_de || issue.depends_on || issue.dependsOn || [])
    .map(cleanDep)
    .filter(d => d && d.toLowerCase() !== 'nenhum' && d !== '');
  return deps.every(dep => {
    if (!allIds.has(dep)) return true; // unknown dep — assume ok
    const depIssue = allIssues.find(i => i.id === dep);
    return depIssue && (completed.has(dep) || depIssue.pass === true || depIssue.status === 'done');
  });
}

let candidates = allIssues.filter(issue => {
  if (!isPending(issue)) return false;
  if (filterIssue && issue.id !== filterIssue) return false;
  if (filterSpec  && getSpec(issue) !== filterSpec) return false;
  if (filterTipo) {
    const t = getTipo(issue);
    if (t.toLowerCase() !== filterTipo.toLowerCase()) return false;
  }
  if (!depsOk(issue)) return false;
  return true;
});

// Sort by execution order tier, then by id numerically
candidates.sort((a, b) => {
  const tiA = executionOrder.indexOf(getTipo(a));
  const tiB = executionOrder.indexOf(getTipo(b));
  const tA = tiA === -1 ? 99 : tiA;
  const tB = tiB === -1 ? 99 : tiB;
  if (tA !== tB) return tA - tB;
  const [specA, subA] = String(a.id).split('.').map(Number);
  const [specB, subB] = String(b.id).split('.').map(Number);
  if (specA !== specB) return specA - specB;
  return (subA || 0) - (subB || 0);
});

if (candidates.length === 0) {
  process.exit(1); // signal: no more issues
}

// Output issue id and title as JSON for the caller
const next = candidates[0];
process.stdout.write(JSON.stringify({ id: next.id, title: next.title || '' }));
" 2>/dev/null
}

# ─── get_issue_json ───────────────────────────────────────────────────────────
get_issue_json() {
  local issue_id="$1"
  node -e "
$FLATTEN_ISSUES_JS

const fs = require('fs');
const prd    = JSON.parse(fs.readFileSync('$PRD_JSON', 'utf8'));
const issues = flattenIssues(prd);
const issue  = issues.find(i => i.id === '$issue_id');
process.stdout.write(JSON.stringify(issue || {}, null, 2));
"
}

# ─── build_prompt ─────────────────────────────────────────────────────────────
build_prompt() {
  local issue_id="$1"
  local issue_json
  issue_json="$(get_issue_json "$issue_id")"

  # Write issue JSON to temp file — avoids heredoc escaping issues with backticks / ${}
  local tmp_issue
  tmp_issue=$(mktemp /tmp/ralf_issue_XXXXXX.json)
  printf '%s' "$issue_json" > "$tmp_issue"

  # Single-quoted heredoc = zero shell expansion inside Node script
  RALF_ISSUE_FILE="$tmp_issue" RALF_AGENTS_FILE="$AGENTS_MD" RALF_ISSUE_ID="$issue_id" \
  node --input-type=module <<'NODEEOF'
import fs from 'fs';

const issueFile  = process.env.RALF_ISSUE_FILE;
const agentsFile = process.env.RALF_AGENTS_FILE;
const fallbackId = process.env.RALF_ISSUE_ID;

const issue = JSON.parse(fs.readFileSync(issueFile, 'utf8'));
fs.unlinkSync(issueFile);
const agentsContent = (agentsFile && fs.existsSync(agentsFile))
  ? fs.readFileSync(agentsFile, 'utf8')
  : '';

const id         = issue.id || fallbackId;
const title      = issue.title || '(sem título)';
const tipo       = issue.tipo || issue.type || 'N/A';
const complexity = issue.complexidade || issue.complexity || 'M';

const rawDeps = issue.depende_de || issue.depends_on || issue.dependsOn || [];
const deps = rawDeps
  .filter(d => d && d.toLowerCase() !== 'nenhum')
  .join(', ') || 'nenhuma';

const cenarios   = issue.cenarios || issue.scenarios || {};
const happyPath  = cenarios.happy_path || '(ver spec)';
const edgeCase   = cenarios.edge_case  || '(ver spec)';
const errorCase  = cenarios.error      || '(ver spec)';
const dbInfo     = issue.banco_de_dados || (issue.db_tables || []).join(', ') || 'N/A';

const arquivos   = issue.arquivos || [];
const filesRows  = arquivos.length
  ? arquivos.map(a => {
      const acao = a.acao || a.action || 'Criar';
      const file = a.arquivo || a.file || a;
      const impl = a.implementar || a.implement || '(ver spec)';
      return '| ' + acao + ' | ' + file + ' | ' + impl + ' |';
    }).join('\n')
  : '| (ver spec no agents.md) | — | — |';

const todos = (issue.todo || []).map(t => '- [ ] ' + t).join('\n')
  || (issue.acceptance_criteria || []).map(t => '- [ ] ' + t).join('\n')
  || '- [ ] Implementar conforme spec';

const lines = [
  'You are implementing a specific issue from the meta-ads-pipeline project.',
  'Read agents.md carefully before writing any code.',
  '',
  '## Project Architecture',
  agentsContent,
  '',
  '## Issue to Implement: ' + id + ' — ' + title,
  '',
  '**Tipo:** ' + tipo,
  '**Complexidade:** ' + complexity,
  '**Depende de:** ' + deps,
  '',
  '**Cenários a implementar:**',
  '- Happy path: ' + happyPath,
  '- Edge case: ' + edgeCase,
  '- Error: ' + errorCase,
  '',
  '**Banco de dados:** ' + dbInfo,
  '',
  '**Arquivos a criar/modificar:**',
  '| Ação | Arquivo | O que implementar |',
  '|------|---------|-------------------|',
  filesRows,
  '',
  '**TODO:**',
  todos,
  '',
  '## /plan — Fase obrigatória ANTES de codar',
  'Antes de criar qualquer arquivo:',
  '1. Use Glob/Grep para verificar se os arquivos já existem no projeto',
  '2. Leia arquivos relacionados existentes para entender padrões reais do codebase',
  '3. Se existir arquivo similar, copie o padrão exato (nomes de variáveis, imports, estrutura)',
  '4. Só então escreva código — NUNCA de memória',
  '',
  '## Regras de implementação',
  '1. Implement EXACTLY what the spec says, nothing more',
  '2. Use the patterns from agents.md',
  '3. Use ONLY tools: Read, Write, Edit, Bash, Glob, Grep — sem exceções',
  '4. Crie os arquivos reais no filesystem com paths completos a partir de: /Users/juliocesarmacbookblack/meta-ads-pipeline/',
  '5. When ALL todo items are done, output on its own line: RALF_STORY_COMPLETE: ' + id,
  '6. If blocked by missing dependency, output: RALF_STORY_BLOCKED: ' + id + ' — reason',
];

process.stdout.write(lines.join('\n'));
NODEEOF
}

# ─── update_progress ──────────────────────────────────────────────────────────
update_progress() {
  local issue_id="$1"
  local status="$2"   # completed | failed | skipped
  local now
  now="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  node -e "
const fs = require('fs');
const p  = JSON.parse(fs.readFileSync('$PROGRESS_JSON', 'utf8'));
const id = '$issue_id';
const st = '$status';
const now = '$now';

p.last_updated = now;
if (!p.started_at) p.started_at = now;
p.in_progress = null;

if (st === 'completed') {
  if (!p.completed.includes(id)) p.completed.push(id);
  p.failed  = (p.failed  || []).filter(x => x !== id);
  p.skipped = (p.skipped || []).filter(x => x !== id);
} else if (st === 'failed') {
  if (!(p.failed || []).includes(id)) { p.failed = p.failed || []; p.failed.push(id); }
} else if (st === 'skipped') {
  p.skipped = p.skipped || [];
  if (!p.skipped.includes(id)) p.skipped.push(id);
}

fs.writeFileSync('$PROGRESS_JSON', JSON.stringify(p, null, 2) + '\n');
"
}

# ─── mark_in_progress ─────────────────────────────────────────────────────────
mark_in_progress() {
  local issue_id="$1"
  local now
  now="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  node -e "
const fs = require('fs');
const p  = JSON.parse(fs.readFileSync('$PROGRESS_JSON', 'utf8'));
p.in_progress = '$issue_id';
p.last_updated = '$now';
if (!p.started_at) p.started_at = '$now';
fs.writeFileSync('$PROGRESS_JSON', JSON.stringify(p, null, 2) + '\n');
"
}

# ─── run_claude ───────────────────────────────────────────────────────────────
run_claude() {
  local issue_id="$1"
  local prompt_file="$2"
  local timestamp
  timestamp="$(date +%Y%m%d_%H%M%S)"
  local log_file="$LOGS_DIR/${issue_id}-${timestamp}.log"

  echo "  Log: $log_file"

  local exit_code=0
  local output

  output="$(claude --model claude-sonnet-4-6 --print --dangerously-skip-permissions "$(cat "$prompt_file")" 2>&1)" || exit_code=$?

  # Save full output to log
  {
    echo "=== RALF Log — Issue $issue_id — $(date) ==="
    echo "=== Prompt ==="
    cat "$prompt_file"
    echo ""
    echo "=== Claude Output ==="
    echo "$output"
    echo "=== Exit code: $exit_code ==="
  } > "$log_file"

  printf '%s' "$output"
  return $exit_code
}

# ─── detect_completion ────────────────────────────────────────────────────────
detect_completion() {
  local output="$1"
  local issue_id="$2"

  if printf '%s' "$output" | grep -qF "RALF_STORY_COMPLETE: $issue_id"; then
    echo "completed"
  elif printf '%s' "$output" | grep -qF "RALF_STORY_BLOCKED: $issue_id"; then
    echo "blocked"
  else
    echo "uncertain"
  fi
}

# ─── main_loop ────────────────────────────────────────────────────────────────
main_loop() {
  echo ""
  echo "RALF — Recursive Autonomous Loop Framework"
  echo "Project: meta-ads-pipeline"
  [ -n "$FILTER_TIPO"  ] && echo "  Filter tipo:  $FILTER_TIPO"
  [ -n "$FILTER_SPEC"  ] && echo "  Filter spec:  $FILTER_SPEC"
  [ -n "$FILTER_ISSUE" ] && echo "  Filter issue: $FILTER_ISSUE"
  [ "$DRY_RUN" = true  ] && echo "  Mode: DRY RUN (no claude execution)"
  echo ""

  local issue_count=0
  local DRY_RUN_SEEN=""  # space-separated list of issue IDs seen in dry-run
  local prompt_file=""
  if [ "$DRY_RUN" = false ]; then
    prompt_file="$(mktemp /tmp/ralf-prompt-XXXXXX)"
    trap 'rm -f "$prompt_file"' EXIT
  fi

  while true; do
    # Get next pending issue
    local next_json
    if ! next_json="$(RALF_DRY_SEEN="$DRY_RUN_SEEN" get_next_issue 2>/dev/null)"; then
      echo "No more pending issues. RALF complete."
      break
    fi

    local issue_id issue_title
    issue_id="$(node -e "process.stdout.write(JSON.parse('$(printf '%s' "$next_json" | sed "s/'/\\\\'/g")').id)")"
    issue_title="$(node -e "process.stdout.write(JSON.parse('$(printf '%s' "$next_json" | sed "s/'/\\\\'/g")').title)")"

    issue_count=$((issue_count + 1))
    echo "━━━ Issue $issue_id — $issue_title ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [ "$DRY_RUN" = true ]; then
      echo "  [DRY RUN] Would run: claude --model claude-sonnet-4-6 --print <prompt>"
      echo ""
      # Advance the seen set so get_next_issue moves to the next candidate
      # without touching the real progress.json
      DRY_RUN_SEEN="$DRY_RUN_SEEN $issue_id"
      [ -n "$FILTER_ISSUE" ] && break
      continue
    fi

    # Build prompt to temp file
    echo "  Building prompt..."
    build_prompt "$issue_id" > "$prompt_file"

    # Mark as in-progress
    mark_in_progress "$issue_id"

    # Run claude
    echo "  Running claude..."
    local output claude_exit=0
    output="$(run_claude "$issue_id" "$prompt_file")" || claude_exit=$?

    if [ "$claude_exit" -ne 0 ]; then
      echo "  ERROR: claude exited with code $claude_exit"
      update_progress "$issue_id" "failed"
      echo ""
      [ -n "$FILTER_ISSUE" ] && break
      continue
    fi

    # Detect completion
    local result
    result="$(detect_completion "$output" "$issue_id")"

    case "$result" in
      completed)
        echo "  DONE: Issue $issue_id completed."
        update_progress "$issue_id" "completed"
        ;;
      blocked)
        local blocked_line
        blocked_line="$(printf '%s' "$output" | grep "RALF_STORY_BLOCKED:" | head -1)"
        echo "  BLOCKED: $blocked_line"
        update_progress "$issue_id" "failed"
        ;;
      uncertain)
        echo "  UNCERTAIN: No completion signal detected. Marking as failed for retry."
        update_progress "$issue_id" "failed"
        ;;
    esac

    echo ""
    [ -n "$FILTER_ISSUE" ] && break
  done

  echo ""
  echo "RALF session complete. Issues processed: $issue_count"
  echo ""

  # Show final status inline
  node -e "
$FLATTEN_ISSUES_JS

const fs = require('fs');
if (!fs.existsSync('$PRD_JSON')) process.exit(0);
const prd      = JSON.parse(fs.readFileSync('$PRD_JSON', 'utf8'));
const progress = JSON.parse(fs.readFileSync('$PROGRESS_JSON', 'utf8'));
const completed = new Set(progress.completed || []);
const issues = flattenIssues(prd);
const done = issues.filter(i => completed.has(i.id) || i.pass === true || i.status === 'done').length;
const total = issues.length;
const pct = total > 0 ? ((done / total) * 100).toFixed(1) : '0.0';
console.log('Progress: ' + done + '/' + total + ' (' + pct + '%)');
" 2>/dev/null || true
}

# ─── Entry point ──────────────────────────────────────────────────────────────
main_loop
