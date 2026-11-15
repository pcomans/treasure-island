import argparse
from pathlib import Path
import subprocess

import numpy as np

WIDTH, HEIGHT = 1920, 1080
FIRST_FRAME = 711
FINAL_FRAME = 965
TAIL_FRAMES = FINAL_FRAME - FIRST_FRAME + 1
Y, X = np.mgrid[250:660, 645:1275].astype(np.float32)


def ease(value):
    t = np.clip(value, 0, 1)
    return t * t * (3 - 2 * t)


def edge(position, width=1.45):
    return ease(position / width + 0.5)


def sample(pixels, x, y):
    x = np.clip(x, 0, pixels.shape[1]-1)
    y = np.clip(y, 0, pixels.shape[0]-1)
    ix, iy = np.floor(x).astype(np.int32), np.floor(y).astype(np.int32)
    xx, yy = np.minimum(ix+1, pixels.shape[1]-1), np.minimum(iy+1, pixels.shape[0]-1)
    fx, fy = (x-ix)[..., None], (y-iy)[..., None]
    return (pixels[iy, ix]*(1-fx)+pixels[iy, xx]*fx)*(1-fy) + (pixels[yy, ix]*(1-fx)+pixels[yy, xx]*fx)*fy


def mix(a, b, strength):
    return a + (b-a)*strength[..., None]


def smile(pixels, layers, amount, idle):
    # The horizontal coin slit becomes the chest's smile. Lift the wood and
    # rim at the corners, then open the dark gap slightly below its gold edge.
    x = np.arange(645,1275,dtype=np.float32)[None,:]
    y = np.arange(250,660,dtype=np.float32)[:,None]
    x, y = np.broadcast_arrays(x,y)
    # Front bevel corners are x=663 and x=1257 in the settled portrait.
    # Continue the grin through both corners; the silhouette, not inward
    # taper, limits the horizontal reach.
    sides = np.minimum(np.abs((x-960)/294),1)
    main_curve = 45*sides**1.62
    gap = 24*(1-0.65*sides**1.55)
    top = 535 + idle*0.85 - amount*(main_curve + gap*0.43)
    bottom = 549 + idle*0.85 + amount*(gap*0.64 - main_curve)
    y_q = np.where(y < top, 535 + (y-top)*np.clip((535-447)/(top-447),0.62,1.78),
          np.where(y > bottom, 549 + (y-bottom)*np.clip((630-549)/(630-bottom),0.62,1.78),
                   535 + (y-top)*(14/np.maximum(bottom-top,9))))
    active = edge(y-447,14)*edge(630-y,16)*edge(x-657.6,2.8)*edge(1262.4-x,2.8)
    warped = sample(layers["bare"],x,y_q)
    # Leave the original foreground latch and the dangling pearl strand
    # layered on top of the flexible lid.
    original = pixels[250:660,645:1275].astype(np.float32)
    gold = (original[...,0]-original[...,2]>40) & (original[...,1]-original[...,2]>28)
    tab = (x>=936)&(x<=983)&(y>=512)&(y<=581)
    plaque = (x>=916)&(x<=1004)&(y>=577)&(y<=690)
    latch = (tab | plaque) & gold
    active *= ~latch
    warped = mix(original,warped,active)
    return mix(warped,original,layers["pearls"])


CONTOUR_Y = np.array([316, 319, 323, 329, 337, 345, 353, 362, 372, 383, 393, 402, 410, 416, 419])
CONTOUR_LEFT = (
    [905, 895, 886, 876, 869, 864, 859, 856, 853, 853, 854, 858, 872, 888, 911],
    [1020, 1007, 1000, 992, 984, 980, 975, 971, 969, 969, 970, 973, 982, 998, 1020],
)
CONTOUR_RIGHT = (
    [905, 925, 933, 938, 943, 946, 949, 951, 951, 951, 950, 947, 938, 925, 911],
    [1020, 1036, 1043, 1049, 1055, 1060, 1063, 1066, 1068, 1069, 1068, 1063, 1049, 1035, 1020],
)


def prepare_layers(base):
    bare = base.copy()
    original = base[250:660,645:1275].astype(np.float32)
    pearl_bounds = (X>=743)&(X<=865)&(Y>=535)&(Y<=637)
    pearl_core = pearl_bounds & (original.min(axis=2)>151) & (np.ptp(original,axis=2)<83)
    pearl_area = pearl_core.copy()
    for _ in range(2):
        larger = pearl_area.copy()
        for axis in (0,1):
            larger |= np.roll(pearl_area,-1,axis=axis)
            larger |= np.roll(pearl_area,1,axis=axis)
        pearl_area = larger
    area = bare[250:660,645:1275]
    for iy in range(area.shape[0]):
        row = pearl_area[iy]
        if not np.any(row):
            continue
        left = np.flatnonzero(row)
        right = np.flatnonzero(~row)
        for channel in range(3):
            area[iy,left,channel] = np.interp(left,right,area[iy,right,channel])
    return {"bare":bare,"pearls":pearl_area.astype(np.float32)}


def eyes(pixels, base, gaze, wink, idle):
    original = base[250:660,645:1275].astype(np.float32)
    for eye, cx in enumerate((902.,1019.)):
        cy = 368. + idle*0.46
        ny = (Y-cy)/49.5
        contour = Y-idle*0.46
        left = np.interp(contour,CONTOUR_Y,CONTOUR_LEFT[eye])
        right = np.interp(contour,CONTOUR_Y,CONTOUR_RIGHT[eye])
        rim_dist = np.minimum(X-left,right-X)
        inside = edge(rim_dist,2.1)*edge(contour-316,3)*edge(419-contour,3)
        nx = np.clip((X-(left+right)*0.5)/np.maximum((right-left)*0.5,4),-1,1)
        # Preserve the stock pie-cut iris silhouette and sheen while bringing
        # its center to the lens. The natural image at the contour stays put.
        dx = (X-cx)/19.8
        dy = (Y-(cy-0.4))/34.5
        angle = np.arctan2(-dy,dx*(1 if eye else -1))
        old_cut = (angle>0.34)&(angle<1.0)&(np.hypot(dx,dy)>.31)
        pupil = edge((1-np.hypot(dx,dy))*20,1.7)*(~old_cut)
        pearl = np.array([254.,254.,252.],dtype=np.float32)
        iris = (169+22*np.clip(dy,-1,1))[...,None]+np.array([17.,11.,0.])
        sparkle = np.exp(-((dx+0.23)/.32)**2-((dy+.14)/.31)**2)
        iris += 14*sparkle[...,None]
        target = mix(pearl,iris,pupil)
        rim = ease((rim_dist+1)/5.0)*inside
        moved = mix(original,target,rim)
        pixels = mix(pixels,moved,inside*gaze)
        if eye == 0 or wink <= 0:
            continue
        # The real avatar has wooden eyelids over the existing round bulb.
        dome = np.sqrt(np.clip(1-nx*nx-ny*ny,0,1))
        grain = (np.sin(Y*0.28+nx*2.4)+0.36*np.sin(Y*0.57-nx*3.3))*2.0
        light = (0.68+0.37*dome-0.10*nx-0.10*ny)[...,None]
        wood = light*np.array([165.,105.,65.])+grain[...,None]
        meet = cy + 6.0 + (1-nx*nx)*7.4
        upper = cy - 53.5 + wink*(meet - (cy-53.5))
        lower = cy + 54.5 - wink*((cy+54.5)-meet)
        lid = np.maximum(edge(upper-Y,2.2),edge(Y-lower,2.2))
        bulb = inside
        # Diminish the same bulb's bloom as its wood covers the glowing white.
        halo = 40*np.exp(-((X-cx)/50)**2-((Y-cy)/55)**2)
        halo *= edge(X-958,20)*edge(1101-X,28)
        pixels -= (halo*wink*(1-inside))[...,None]*np.array([1.,0.88,0.66])
        pixels = mix(pixels,wood,bulb*lid)
        seam_distance = np.minimum(np.abs(Y-upper),np.abs(Y-lower))
        seam = edge(2.5-seam_distance,2.0)*inside*ease((wink-0.09)/0.23)
        pixels = mix(pixels,np.array([43.,27.,18.]),seam)
    return pixels


def frame(base, layers, gaze, mouth, wink, idle):
    image = base.copy()
    face = smile(base,layers,mouth,idle) if mouth or idle else base[250:660,645:1275].astype(np.float32)
    image[250:660,645:1275] = np.clip(np.rint(eyes(face,base,gaze,wink,idle)),0,255).astype(np.uint8)
    return image


def png(path,pixels):
    subprocess.run(['ffmpeg','-nostdin','-n','-v','error','-f','rawvideo','-pix_fmt','rgb24',
                    '-s','1920x1080','-i','-','-frames:v','1','-update','1',str(path)],
                    input=pixels.tobytes(),check=True)


# Guide samples only initialize the eye search on the actual frames.
# Connected bright sclera is measured independently on each side and frame.
TRACK = np.array([
    [711,953,962,575],[715,953,963,563],[720,952,964,547],[730,948,967,508],
    [745,937,973,449],[760,927,984,393],[775,918,995,345],[780,916,998,334],
    [790,914,1003,315],[800,912,1006,307],[809,910,1008,310],[820,908,1010,316],
    [830,906,1012,328],[840,904,1015,343],[860,901,1018,361],
    [876,902,1019,368],[899,902,1019,368],
],dtype=np.float32)
CANONICAL = ((902.,368.),(1019.,368.))


def eye_bounds(image, cx, cy, scale, split, eye):
    half_width = max(4.0, 55.0*scale+1.5)
    left = max(0,int(cx-half_width))
    right = min(WIDTH, int(cx+half_width+1))
    if eye == 0:
        right = min(right, int(split))
    else:
        left = max(left, int(split))
    half_height = max(4.0, 53.0*scale+6)
    top = max(0,int(cy-half_height))
    bottom = min(HEIGHT,int(cy+half_height+1))
    mask = image[top:bottom,left:right].min(axis=2)>224
    yy,xx = np.where(mask)
    if len(xx)<5:
        return None
    return np.array([xx.min()+left,xx.max()+left,yy.min()+top,yy.max()+top],dtype=np.float32)


def measured_tracks(raw):
    ref = raw[899-FIRST_FRAME]
    baseline = [eye_bounds(ref, cx,cy,1.,960.5,i) for i,(cx,cy) in enumerate(CANONICAL)]
    assert all(b is not None for b in baseline)
    result = []
    for f in range(FIRST_FRAME,900):
        lx,rx,cy = [np.interp(f, TRACK[:,0], TRACK[:,k]) for k in (1,2,3)]
        scale = (rx-lx)/117.
        eyes = []
        for i,eye_center in enumerate((lx,rx)):
            got = eye_bounds(raw[f-FIRST_FRAME],eye_center,cy,scale,(lx+rx)/2,i)
            cor = baseline[i]
            if got is None or got[1]-got[0]+1 < 22*scale or got[3]-got[2]+1<38*scale:
                eyes.append([eye_center,cy,scale,scale,0.])
                continue
            sx = (got[1]-got[0]+1)/(cor[1]-cor[0]+1)
            sy = (got[3]-got[2]+1)/(cor[3]-cor[2]+1)
            # Convert bright-pixel positions to the existing stock silhouette.
            cx,cy0 = CANONICAL[i]
            tx = got[:2].mean() + sx*(cx-cor[:2].mean())
            ty = got[2:].mean() + sy*(cy0-cor[2:].mean())
            eyes.append([tx,ty,sx,sy,1.])
        result.append(eyes)
    result = np.array(result,dtype=np.float32)
    padded = np.pad(result,((1,1),(0,0),(0,0)),mode='edge')
    # Small deterministic temporal filter removes integer subpixel mask jitter
    # while retaining the actual motion of the zooming camera.
    result[:,:,:4] = 0.20*padded[:-2,:,:4]+0.60*padded[1:-1,:,:4]+0.20*padded[2:,:,:4]
    return result


def steer_approach(image, tracking, strength):
    out = image.copy()
    for i,(tx,ty,sx,sy,valid) in enumerate(tracking):
        if not valid:
            continue
        x0,x1 = max(0,int(tx-sx*55-2)), min(WIDTH,int(tx+sx*55+3))
        y0,y1 = max(0,int(ty-sy*59-2)), min(HEIGHT,int(ty+sy*59+3))
        yy,xx = np.mgrid[y0:y1,x0:x1].astype(np.float32)
        cx,cy = CANONICAL[i]
        x = (xx-tx)/max(sx,.03)+cx
        y = (yy-ty)/max(sy,.03)+cy
        left = np.interp(y,CONTOUR_Y,CONTOUR_LEFT[i])
        right = np.interp(y,CONTOUR_Y,CONTOUR_RIGHT[i])
        rim_dist = np.minimum(x-left,right-x)
        coverage = edge(rim_dist,2.1/max(sx,.05))*edge(y-316,2.2/max(sy,.05))*edge(419-y,2.2/max(sy,.05))
        dx = (x-cx)/19.8
        dy = (y-cy+0.4)/34.5
        wedge = np.arctan2(-dy,dx*(1 if i else -1))
        cut = (wedge>0.34)&(wedge<1.0)&(np.hypot(dx,dy)>.31)
        pupil = edge((1-np.hypot(dx,dy))*20,1.7/max(sx,.05))*(~cut)
        iris = (169+22*np.clip(dy,-1,1))[...,None]+np.array([17.,11.,0.])
        iris += (14*np.exp(-((dx+0.23)/.32)**2-((dy+.14)/.31)**2))[...,None]
        target = mix(np.array([254.,254.,252.]),iris,pupil)
        original=image[y0:y1,x0:x1].astype(np.float32)
        weight = strength*coverage*ease((rim_dist+1)/5.0)
        out[y0:y1,x0:x1] = np.clip(np.rint(mix(original,target,weight)),0,255).astype(np.uint8)
    return out


def edit(raw, f, base, layers, tracking):
    source = raw[f-FIRST_FRAME]
    if f < 900:
        strength = ease((f-FIRST_FRAME)/4)
        return steer_approach(source,tracking[f-FIRST_FRAME],strength)
    t = (f-900)/30.
    amount = ease((t-0.12)/0.56)*(1-0.10*ease((t-1.73)/0.35))
    wink = ease((t-1.08)/0.14)*(1-ease((t-1.36)/0.21))
    idle = ease(t/.30)*np.sin(t*5.05)
    new = frame(base,layers,1.,amount,wink,idle)
    out = source.copy()
    # Move no pixels from the actual source outside the face region.
    out[250:660,645:1275] = new[250:660,645:1275]
    return out


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('source_rgb',type=Path)
    parser.add_argument('output',type=Path)
    parser.add_argument('--proof',action='store_true')
    args = parser.parse_args()
    expected = TAIL_FRAMES * WIDTH * HEIGHT * 3
    if args.source_rgb.stat().st_size != expected:
        parser.error("Source must be the 255 decoded source frames from 711 through 965.")
    raw = np.memmap(args.source_rgb,dtype=np.uint8,mode='r',shape=(TAIL_FRAMES,HEIGHT,WIDTH,3))
    base = raw[899-FIRST_FRAME]
    layers = prepare_layers(base)
    tracking = measured_tracks(raw)
    print('Valid source eye tracks per side',tracking[:,:,4].sum(axis=0),flush=True)
    if args.proof:
        for f in [715,730,745,780,850,899,922,938,965]:
            source=raw[f-FIRST_FRAME]
            png(args.output/f'{f:04d}-source.png',source)
            png(args.output/f'{f:04d}-edit.png',edit(raw,f,base,layers,tracking))
        return
    with args.output.open('xb') as out:
        for f in range(FIRST_FRAME,FINAL_FRAME+1):
            out.write(edit(raw,f,base,layers,tracking).tobytes())


if __name__ == '__main__':
    main()
