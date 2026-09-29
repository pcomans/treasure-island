import fs from 'node:fs';
const R='/Volumes/Macintosh_HD/Users/user302070/code/treasure-island-1444-shelter-lining-20260924';
const W='/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work';
const P=W+'/housing-quality-second-pair-2026-09-23/1444-shelter-finish-001';
const native=JSON.parse(fs.readFileSync(W+'/1444-from-scratch-2026-09-23/design-004/images/geometry-material-native.json')).current.geometry;
const add=(a,b)=>a.map((x,i)=>x+b[i]),sub=(a,b)=>a.map((x,i)=>x-b[i]),mul=(a,k)=>a.map(x=>x*k),dot=(a,b)=>a.reduce((s,x,i)=>s+x*b[i],0),cross=(a,b)=>[a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]],unit=a=>mul(a,1/Math.hypot(...a));
function floats(hex,n){let b=Buffer.from(hex,'hex'),o=[];for(let i=0;i<b.length;i+=4*n)o.push(Array.from({length:n},(_,j)=>b.readFloatLE(i+4*j)));return o;}
const meshes=Object.entries(native).filter(([id,m])=>m.surfaces).map(([id,m])=>{let vertices=floats(m.surfaces[0][0].bytes,3);return {id:+id,origin:m.local_transform[3],basis:m.local_transform.slice(0,3),size:[0,1,2].map(k=>Math.max(...vertices.map(v=>v[k]))-Math.min(...vertices.map(v=>v[k]))),vertices,source:m};});
const world=(b,p)=>add(b.origin,b.basis.reduce((s,a,i)=>add(s,mul(a,p[i])),[0,0,0]));
const local=(b,p)=>b.basis.map(a=>dot(sub(p,b.origin),a)/dot(a,a));
const get=id=>meshes.find(b=>b.id===id);
const area=p=>Math.abs(p.reduce((s,a,i)=>{let b=p[(i+1)%p.length];return s+a[0]*b[1]-a[1]*b[0];},0))/2;
const cross2=(a,b)=>a[0]*b[1]-a[1]*b[0];
function half(p,a,b,inside){let o=[];for(let i=0;i<p.length;i++){let q=p[i],r=p[(i+1)%p.length],d=cross2(sub(b,a),sub(q,a)),e=cross2(sub(b,a),sub(r,a)),qi=inside?d>=0:d<=0,ri=inside?e>=0:e<=0;if(qi)o.push(q);if(qi!==ri){let t=d/(d-e);o.push(add(q,mul(sub(r,q),t)));}}return o;}
function subtract(p,clip){let inside=p,out=[];for(let i=0;i<clip.length&&inside.length;i++){let a=clip[i],b=clip[(i+1)%clip.length],piece=half(inside,a,b,false);if(piece.length>=3&&area(piece)>1e-10)out.push(piece);inside=half(inside,a,b,true);}return out;}
function footprint(b){let p=[[-1,-1],[1,-1],[1,1],[-1,1]].map(([x,z])=>world(b,[x*b.size[0]/2,-b.size[1]/2,z*b.size[2]/2])).map(v=>[v[0],v[2]]);return p;}
// Exact existing native boxes and roof triangles bound local ambient visibility.
const boxes=meshes.filter(b=>b.vertices.length===24),triangles=[];
for(let b of meshes.filter(b=>b.vertices.length!==24))for(let s of b.source.surfaces){let vs=floats(s[0].bytes,3);let bytes=Buffer.from(s[12].bytes,'hex'),ids=[];for(let i=0;i<bytes.length;i+=4)ids.push(bytes.readInt32LE(i));if(!ids.length)ids=vs.map((_,i)=>i);for(let i=0;i<ids.length;i+=3){let t=ids.slice(i,i+3).map(k=>world(b,vs[k]));triangles.push({a:t[0],e1:sub(t[1],t[0]),e2:sub(t[2],t[0])});}}
const chunk=JSON.parse(fs.readFileSync(R+'/generated/world/chunks/x_-2__z_-1.json'));
for(const land of chunk.records.filter(r=>r.feature_kind==='land_ground'&&r.collision_kind==='world_solid'))for(let i=0;i<land.indices.length;i+=3){const t=land.indices.slice(i,i+3).map(j=>land.vertices.slice(j*3,j*3+3));if(t.some(v=>Math.hypot(v[0]+375,v[2]+55)<20))triangles.push({a:t[0],e1:sub(t[1],t[0]),e2:sub(t[2],t[0])});}
function blocked(p,d){for(const b of boxes){const q=sub(p,b.origin);let lo=.0001,hi=12;for(let k=0;k<3&&lo<hi;k++){let x=dot(q,b.basis[k]),v=dot(d,b.basis[k]),h=b.size[k]/2;if(Math.abs(v)<1e-9){if(Math.abs(x)>h){hi=-1;break;}}else{let a=(-h-x)/v,c=(h-x)/v;lo=Math.max(lo,Math.min(a,c));hi=Math.min(hi,Math.max(a,c));}}if(lo<hi)return true;}
for(const t of triangles){const q=cross(d,t.e2),det=dot(t.e1,q);if(Math.abs(det)<1e-8)continue;const inv=1/det,s=sub(p,t.a),u=dot(s,q)*inv;if(u<0||u>1)continue;const r=cross(s,t.e1),v=dot(d,r)*inv;if(v<0||u+v>1)continue;const distance=dot(t.e2,r)*inv;if(distance>.0001&&distance<12)return true;}return false;}
const specs=[[122,'rear',[0,0,1],[0,1],false],[123,'return',[-1,0,0],[2,1],false],[124,'ceiling_main',[0,-1,0],[0,2],false],[125,'ceiling_north',[0,-1,0],[0,2],false],[119,'covered_source_return20',[0,0,1],[0,1],true],[121,'covered_source_return21',[0,0,1],[0,1],true],[119,'return20_underside',[0,-1,0],[0,2],true],[121,'return21_underside',[0,-1,0],[0,2],true]];
const fields=[];
for(let [id,label,nlocal,axes,finish] of specs){let b=get(id),w=Math.ceil(b.size[axes[0]]/.2)+1,h=Math.ceil(b.size[axes[1]]/.2)+1,n=unit(b.basis.reduce((s,a,i)=>add(s,mul(a,nlocal[i])),[0,0,0])),tangent=unit(cross(Math.abs(n[1])>.9?[1,0,0]:[0,1,0],n)),bitangent=cross(n,tangent),directions=[];for(let k=0;k<256;k++){let u=(k+.5)/256,phi=k*2.399963229728653;directions.push(add(add(mul(tangent,Math.sqrt(u)*Math.cos(phi)),mul(bitangent,Math.sqrt(u)*Math.sin(phi))),mul(n,Math.sqrt(1-u))));}let values=[];for(let y=0;y<h;y++)for(let x=0;x<w;x++){let q=mul(nlocal,b.size[nlocal.findIndex(v=>v!==0)]/2);q[axes[0]]=(x/(w-1)-.5)*b.size[axes[0]];q[axes[1]]=(y/(h-1)-.5)*b.size[axes[1]];let p=add(world(b,q),mul(n,.025)),visible=0;for(let d of directions)if(!blocked(p,d))visible++;values.push(visible/256);}fields.push({label,binding:{origin:b.origin,size:b.size},normal_local:nlocal,uv_axes:axes,width:w,height:h,values,soffit_finish:finish});console.log(label,w,h,Math.min(...values),Math.max(...values));}

const selected=[119,121,124,125].map(get), corners=selected.flatMap(footprint);
const xmin=Math.min(...corners.map(p=>p[0])),xmax=Math.max(...corners.map(p=>p[0])),zmin=Math.min(...corners.map(p=>p[1])),zmax=Math.max(...corners.map(p=>p[1]));
const width=Math.ceil((xmax-xmin)/.2)+1,height=Math.ceil((zmax-zmin)/.2)+1,values=[];
const planeY=selected[0].origin[1]-selected[0].size[1]/2;
for(let y=0;y<height;y++)for(let x=0;x<width;x++){let p=[xmin+x/(width-1)*(xmax-xmin),planeY-.025,zmin+y/(height-1)*(zmax-zmin)],visible=0;for(let k=0;k<256;k++){let u=(k+.5)/256,phi=k*2.399963229728653,d=[Math.sqrt(u)*Math.cos(phi),-Math.sqrt(1-u),Math.sqrt(u)*Math.sin(phi)];if(!blocked(p,d))visible++;}values.push(visible/256);}
const shared_underside={origin:[xmin,zmin],span:[xmax-xmin,zmax-zmin],width,height,values,plane_y:planeY};
fs.writeFileSync(R+'/game/scripts/world/facades/croaker_1444_shelter_visibility.json',JSON.stringify({schema:'croaker1444-material-recovery005',method:'Original opaque boxes retained; shared world-XZ underside visibility, same256cosine rays/12m/25mm origin offset/200mmgrid; AO_LIGHT_AFFECT0',fields,replacements:[],shared_underside})+'\n');
console.log('shared',width,height,planeY);
