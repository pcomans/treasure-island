"""Reference coordinates and local deformation for the Isle House portrait."""

import subprocess

import numpy as np


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


def png(path,pixels):
    subprocess.run(['ffmpeg','-nostdin','-n','-v','error','-f','rawvideo','-pix_fmt','rgb24',
                    '-s','1920x1080','-i','-','-frames:v','1','-update','1',str(path)],
                    input=pixels.tobytes(),check=True)


# These guide points seed the eye search; each frame is measured again.
TRACK = np.array([
    [711,953,962,575],[715,953,963,563],[720,952,964,547],[730,948,967,508],
    [745,937,973,449],[760,927,984,393],[775,918,995,345],[780,916,998,334],
    [790,914,1003,315],[800,912,1006,307],[809,910,1008,310],[820,908,1010,316],
    [830,906,1012,328],[840,904,1015,343],[860,901,1018,361],
    [876,902,1019,368],[899,902,1019,368],
],dtype=np.float32)


CANONICAL = ((902.,368.),(1019.,368.))
