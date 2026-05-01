#!/usr/bin/env bash
# ralf-status.sh — RALF Progress Dashboard
# meta-ads-pipeline | SDD Deborah Folloni
# Usage: ./scripts/ralf-status.sh

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PRD_JSON="$PROJECT_ROOT/prd.json"
PROGRESS_JSON="$PROJECT_ROOT/progress.json"

if ! command -v node &>/dev/null; then
  echo "ERROR: node not found."
  exit 1
fi

if [ ! -f "$PRD_JSON" ]; then
  echo "ERROR: prd.json not found at $PRD_JSON"
  exit 1
fi

if [ ! -f "$PROGRESS_JSON" ]; then
  echo "ERROR: progress.json not found. Run: ./scripts/ralf.sh --reset"
  exit 1
fi

PRD_JSON="$PRD_JSON" PROGRESS_JSON="$PROGRESS_JSON" node -e "
function flattenIssues(prd) {
  if (prd.specs && Array.isArray(prd.specs)) {
    const all = [];
    for (const spec of prd.specs) {
      for (const issue of (spec.issues || [])) {
        all.push(Object.assign({}, issue, { _spec_id: spec.id, _spec_title: spec.title }));
      }
    }
    return all;
  }
  return prd.issues || prd.stories || [];
}

const fs = require('fs');
const prd      = JSON.parse(fs.readFileSync(process.env.PRD_JSON,      'utf8'));
const progress = JSON.parse(fs.readFileSync(process.env.PROGRESS_JSON, 'utf8'));

const completed = new Set(progress.completed || []);
const failed    = new Set(progress.failed    || []);
const skipped   = new Set(progress.skipped   || []);

const issues = flattenIssues(prd);
const executionOrder = prd.execution_order ||
  ['Configuração', 'Banco', 'UI Shell', 'Backend', 'UI Funcional', 'Integração'];

const grouped = {};
for (const t of executionOrder) grouped[t] = { total: 0, done: 0, fail: 0, skip: 0 };

for (const issue of issues) {
  const tipo = issue.tipo || issue.type || 'Outros';
  if (!grouped[tipo]) grouped[tipo] = { total: 0, done: 0, fail: 0, skip: 0 };
  grouped[tipo].total++;
  const id = issue.id;
  if (completed.has(id) || issue.pass === true || issue.status === 'done') {
    grouped[tipo].done++;
  } else if (failed.has(id)) {
    grouped[tipo].fail++;
  } else if (skipped.has(id)) {
    grouped[tipo].skip++;
  }
}

const GREEN  = '\x1b[32m';
const GRAY   = '\x1b[90m';
const RED    = '\x1b[31m';
const YELLOW = '\x1b[33m';
const BOLD   = '\x1b[1m';
const RESET  = '\x1b[0m';

function bar(done, total, width) {
  width = width || 10;
  if (total === 0) return GRAY + '░'.repeat(width) + RESET;
  const filled = Math.round((done / total) * width);
  return GREEN + '█'.repeat(filled) + GRAY + '░'.repeat(width - filled) + RESET;
}

const pad  = function(s, n) { return String(s).padEnd(n,   ' '); };
const rpad = function(s, n) { return String(s).padStart(n, ' '); };

console.log('');
console.log(BOLD + 'RALF Status — meta-ads-pipeline' + RESET);
console.log('─'.repeat(52));

let gTotal = 0, gDone = 0, gFail = 0, gSkip = 0;
const allTipos = executionOrder.concat(['Outros']).filter(function(t) {
  return grouped[t] && grouped[t].total > 0;
});

for (const tipo of allTipos) {
  const g = grouped[tipo];
  if (!g || g.total === 0) continue;

  gTotal += g.total;
  gDone  += g.done;
  gFail  += g.fail;
  gSkip  += g.skip;

  const pct      = ((g.done / g.total) * 100).toFixed(1);
  const fraction = rpad(g.done, 3) + '/' + String(g.total).padEnd(4, ' ');
  let extras = '';
  if (g.fail > 0) extras += '  ' + RED    + g.fail + ' failed'  + RESET;
  if (g.skip > 0) extras += '  ' + YELLOW + g.skip + ' skipped' + RESET;

  console.log(pad(tipo, 14) + '  ' + bar(g.done, g.total) + '  ' + fraction + ' (' + pct + '%)' + extras);
}

console.log('─'.repeat(52));

const totalPct  = gTotal > 0 ? ((gDone / gTotal) * 100).toFixed(1) : '0.0';
const totalFrac = rpad(gDone, 3) + '/' + String(gTotal).padEnd(4, ' ');
let totalExtras = '';
if (gFail > 0) totalExtras += '  ' + RED    + gFail + ' failed'  + RESET;
if (gSkip > 0) totalExtras += '  ' + YELLOW + gSkip + ' skipped' + RESET;

console.log(BOLD + pad('Total', 14) + RESET + '  ' + bar(gDone, gTotal) + '  ' + totalFrac + ' (' + totalPct + '%)' + totalExtras);
console.log('');

if (progress.in_progress) {
  console.log(YELLOW + 'In progress:' + RESET + '  ' + progress.in_progress);
}
if (progress.started_at) {
  console.log('Started:      ' + progress.started_at);
}
if (progress.last_updated) {
  console.log('Updated:      ' + progress.last_updated);
}

const pending = gTotal - gDone - gFail - gSkip;
console.log('Pending:      ' + pending + ' issues');
console.log('');
"
