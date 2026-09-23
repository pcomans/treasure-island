from pathlib import Path
import json,hashlib,re
P=Path('/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001');W=P/'1397-1226-live-preparation-001';S=W/'source';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();bh=sha(S/'game/scripts/world/world_chunk_builder.gd');ah=sha(S/'game/scripts/world/facades/bayside_1226_live_replacement.gd');ap='res://game/scripts/world/facades/bayside_1226_live_replacement.gd'
p=S/'tools/build_facade_recognition_registry.mjs';s=p.read_text();s,n=re.subn(r'(const D5_BATCH_BUILDER_SHA256 = ")[a-f0-9]{64}',r'\g<1>'+bh,s);assert n==1;lines=s.splitlines(True);n=0
for i,line in enumerate(lines):
 if 'record_dispatch:'in line and 'var record_result := _build_record('in line:assert ', gateview_1397_plan)'in line;lines[i]=line.replace(', gateview_1397_plan)',', gateview_1397_plan, bayside_1226_plan)');n+=1
assert n==4;s=''.join(lines);needle='    ["GATEVIEW_1397_LIVE_REPLACEMENT", "gateview_1397_plan"],';assert s.count(needle)==1;s=s.replace(needle,needle+'\n    ["BAYSIDE_1226_LIVE_REPLACEMENT", "bayside_1226_plan"],');needle='  const candidateHash = {';assert s.count(needle)==1;s=s.replace(needle,needle+json.dumps(ap.removeprefix('res://'))+': '+json.dumps(ah)+', ');p.write_text(s)
oldbh=sha(P/'1397-live-preparation-001/source/game/scripts/world/world_chunk_builder.gd');changed=[]
for rel in ['game/tests/headless_facade_recognition_registry_contract.gd','game/scripts/world/facades/facade_runtime_registry_loader.gd']:
 p=S/rel;s=p.read_text();needle='\tif path in ["res://game/scripts/world/facades/gateview_1397_live_replacement.gd"';assert s.count(needle)==1;s=s.replace(needle,'\tif path in ["'+ap+'", "res://game/scripts/world/facades/gateview_1397_live_replacement.gd"');needle='\t\tvar expected_hash: String = ';assert s.count(needle)==1;s=s.replace(needle,needle+'"'+ah+'" if path == "'+ap+'" else ')
 if rel.endswith('facade_runtime_registry_loader.gd'):
  lines=s.splitlines(True)
  for i,line in enumerate(lines):
   if oldbh in line:assert re.match(r'const \w*BUILDER_SHA256 := ',line);changed.append(line.split(' := ')[0]);lines[i]=line.replace(oldbh,bh)
  s=''.join(lines)
 p.write_text(s)
# Approved narrow experiment: negative mutation text selected only after independent positive compile/dispatch validation.
p=S/'tools/test_facade_recognition_registry.mjs';s=p.read_text();needle='validateCurrentWorldBuilderDispatch(inputs);';assert s.count(needle)==1;addition='''
// Negative mutation construction only; compiler argument/hash expectations remain independent.
const currentBuilderLines = inputs.runtimeContracts.worldBuilderText.split("\\n");
const buildChunkStarts = currentBuilderLines.flatMap((line, index) => /^func build_chunk\\(/u.test(line) ? [index] : []);
assert(buildChunkStarts.length === 1, "exactly one named build_chunk body required for mutation construction");
const buildChunkStart = buildChunkStarts[0];
const followingFunction = currentBuilderLines.findIndex((line, index) => index > buildChunkStart && /^(?:static )?func /u.test(line));
assert(followingFunction > buildChunkStart, "bounded build_chunk body required for mutation construction");
const currentDispatchStatements = currentBuilderLines.slice(buildChunkStart + 1, followingFunction)
  .flatMap((line) => { const match = /^\\t\\t(var record_result := _build_record\\(record, false, [^\\n]+\\))$/u.exec(line); return match ? [match[1]] : []; });
assert(currentDispatchStatements.length === 1, "exactly one current per-record dispatch statement required for mutation construction");
const currentRecordDispatchStatement = currentDispatchStatements[0];
''';s=s.replace(needle,needle+'\n'+addition);lines=s.splitlines(True);n=0
for i,line in enumerate(lines):
 if line.strip().startswith('"var record_result := _build_record('):
  assert line.strip().endswith('",');lines[i]='  currentRecordDispatchStatement,\n';n+=1
assert n==3;p.write_text(''.join(lines));(W/'mutation-experiment.json').write_text(json.dumps({'scope':'three negative mutation selectors only','removed_duplicate_full_calls':n,'positive_compiler_expectations':'explicit independent call markers/hash retained','negative_expected_errors':['Navy Chapel per-record consumption dispatch must precede the fully-consumed assertion','D2 1441 per-record consumption dispatch must precede the fully-consumed assertion'],'baseline_token_repairs':3,'baseline_repeat_invocations':1,'current_token_repairs':0,'current_repeat_invocations':0,'actual_node_outcome':'PENDING'},indent=2)+'\n');print('consumer parity',bh,ah,'changed constants',len(changed))
