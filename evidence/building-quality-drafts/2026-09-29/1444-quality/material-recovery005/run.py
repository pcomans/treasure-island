# Existing successful pair runner, bounded second-pair import/capture adaptation.
import pathlib,subprocess,json,hashlib,sys,datetime,os
P=pathlib.Path(__file__).parent
W=pathlib.Path("/Volumes/Macintosh_HD/Users/user302070/code/treasure-island-1444-shelter-lining-20260924")
G="/Volumes/Macintosh_HD/Users/user302070/code/treasure-island/.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot"
HEAD="01845490ecab848400888126a84fa513740fda5d"
def sha(p):return hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
def census():
 rows=subprocess.check_output(["ps","-axo","pid=,comm="],text=True).splitlines()
 return [r.strip() for r in rows if r.strip().split(maxsplit=1)[-1].endswith("/Godot")]
def write(p,v):p.write_text(json.dumps(v,indent=2)+"\n")
name=sys.argv[1]
assert name in ("capture-001", "capture-002", "capture-003")
input_map=P/("input-map.json" if name=="capture-001" else "input-map-capture003.json" if name=="capture-003" else "input-map-capture002.json")
assert subprocess.check_output(["git","rev-parse","HEAD"],cwd=W,text=True).strip()==HEAD
original=P.parent/"1444-ceiling-native-diagnostic-001/diagnostic-001/images/receipt.json"
assert sha(original)=="33a573a8512845ebd683d9d6bd4229daf9b703e664478ad1e844ad8ca4eb9632"
inputs=json.loads(input_map.read_text())
for path,digest in inputs["inputs"].items():assert sha(path)==digest,path
donor_binding={}
if name=="capture-003":
 prior=json.loads((P/"input-map-capture002.json").read_text())
 for path,digest in prior["inputs"].items():
  if "/game/" in path or "/generated/" in path or path.endswith("/project.godot"):assert sha(path)==digest,path
 for rel in ["images/receipt.json","images/original-contact-comparison.json","images/119-candidate.png","images/588-candidate.png"]:
  path=P/"capture-002"/rel;donor_binding[str(path)]=sha(path)
 assert json.loads((P/"capture-002/images/original-contact-comparison.json").read_text())["exact_original_geometry_contacts_roles"]
assert not census(),"Serialized engine slot occupied"
run=P/name;run.mkdir()
args=[G,"--path",str(W)]
if name=="import-001":args += ["--headless","--editor","--import"]
else:args += ["--rendering-method","forward_plus","--rendering-driver","metal","--display-driver","macos","--audio-driver","Dummy","--resolution",("1440x900" if name=="capture-003" else "1280x800"),"--script",str(P/"capture.gd"),"--","--output="+str(run/"images")]
if name=="capture-003":args.append("--ordinary-only")
start=datetime.datetime.now(datetime.timezone.utc).isoformat();proc=None;code=None;error=None
try:
 with (run/"engine.log").open("w") as log:
  proc=subprocess.Popen(args,cwd=W,stdout=log,stderr=subprocess.STDOUT)
  write(run/"process.json",{"pid":proc.pid,"argv":args,"start":start,"original_receipt":str(original),"original_receipt_sha256":sha(original),"input_map_sha256":sha(input_map),"completed_capture002_donor":donor_binding})
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
 write(run/"completed-output-map.json",{"original_receipt":str(original),"original_receipt_sha256":sha(original),"input_map_sha256":sha(input_map),"completed_capture002_donor":donor_binding,"outputs":{str(p):sha(p) for p in sorted(run.rglob("*")) if p.is_file()}})
 print(json.dumps(result),flush=True)
if code!=0 or alive or error:sys.exit(1)
if any(t in (run/"engine.log").read_text() for t in ["SCRIPT ERROR:","Parse Error","ERROR:"]):sys.exit(1)
if name!="import-001":
 receipt=run/"images/receipt.json"
 if not receipt.exists() or not json.loads(receipt.read_text()).get("ok",False):sys.exit(1)
