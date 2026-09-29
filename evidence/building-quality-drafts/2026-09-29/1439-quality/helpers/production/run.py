# Existing successful pair runner, bounded second-pair import/capture adaptation.
import pathlib,subprocess,json,hashlib,sys,datetime,os
P=pathlib.Path(__file__).parent
W=pathlib.Path("/Volumes/Macintosh_HD/Users/user302070/code/treasure-island-1439-from-scratch-20260923")
G="/Volumes/Macintosh_HD/Users/user302070/code/treasure-island/.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot"
HEAD="6f44545c4c22eb722fe66abcf7039674ccd3c8b6"
def sha(p):return hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
def census():
 rows=subprocess.check_output(["ps","-axo","pid=,comm="],text=True).splitlines()
 return [r.strip() for r in rows if r.strip().split(maxsplit=1)[-1].endswith("/Godot")]
def write(p,v):p.write_text(json.dumps(v,indent=2)+"\n")
name=sys.argv[1]
assert name in ["actual-world-002","parser-repair-002"]
assert subprocess.check_output(["git","rev-parse","HEAD"],cwd=W,text=True).strip()==HEAD
inputs=json.loads((P/"input-map-003.json").read_text())
for path,digest in inputs["inputs"].items():assert sha(path)==digest,path
if name!="import-001":
 prior=json.loads((P.parent/"import-001/terminal.json").read_text())
 assert prior["exit_code"]==0 and not prior["pid_alive"]
 assert not any(t in (P.parent/"import-001/engine.log").read_text() for t in ["SCRIPT ERROR:","Parse Error","ERROR:"])
 assert (W/".godot/global_script_class_cache.cfg").exists(),"Successful class cache absent"
 # New scripts have no class_name and are loaded explicitly by resource path.
 # Reuse the successful study import; no cold setup replay is required.
assert not census(),"Serialized engine slot occupied"
run=P/name;run.mkdir()
args=[G,"--path",str(W)]
if name=="import-001":args += ["--headless","--editor","--import"]
else:args += ["--rendering-method","forward_plus","--rendering-driver","metal","--display-driver","macos","--audio-driver","Dummy","--resolution","1440x900","--script",str(P/"capture.gd"),"--","--output="+str(run/"images")]
start=datetime.datetime.now(datetime.timezone.utc).isoformat();proc=None;code=None;error=None
try:
 with (run/"engine.log").open("w") as log:
  proc=subprocess.Popen(args,cwd=W,stdout=log,stderr=subprocess.STDOUT)
  write(run/"process.json",{"pid":proc.pid,"argv":args,"start":start,"input_map_path":str(P/"input-map-003.json"),"input_map_sha256":sha(P/"input-map-003.json")})
  print(json.dumps({"pid":proc.pid,"stage":name,"process":str(run/"process.json")}),flush=True)
  try:code=proc.wait(timeout=300)
  except subprocess.TimeoutExpired:
   error="timeout";proc.terminate()
   try:code=proc.wait(timeout=15)
   except subprocess.TimeoutExpired:proc.kill();code=proc.wait(timeout=15)
except Exception as exc:error=repr(exc)
finally:
 alive=False
 if proc is not None:
  try:os.kill(proc.pid,0);alive=True
  except ProcessLookupError:pass
 result={"exit_code":code,"pid":proc.pid if proc else None,"pid_alive":alive,"finished":datetime.datetime.now(datetime.timezone.utc).isoformat(),"error":error,"godot_census":census(),"slot_released":not alive}
 write(run/"terminal.json",result);write(run/"SLOT_RELEASE.json",result)
 write(run/"completed-output-map.json",{"input_map_path":str(P/"input-map-003.json"),"input_map_sha256":sha(P/"input-map-003.json"),"outputs":{str(p):sha(p) for p in sorted(run.rglob("*")) if p.is_file()}})
 print(json.dumps(result),flush=True)
if code!=0 or alive or error:sys.exit(1)
if any(t in (run/"engine.log").read_text() for t in ["SCRIPT ERROR:","Parse Error","ERROR:"]):sys.exit(1)
if name!="import-001":
 receipt=run/"images/receipt.json"
 if not receipt.exists() or not json.loads(receipt.read_text()).get("ok",False):sys.exit(1)
