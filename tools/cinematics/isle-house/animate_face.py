import argparse
from pathlib import Path
import subprocess

import numpy as np

WIDTH, HEIGHT = 1920, 1080
TAIL_FRAMES = 66
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
    sides = np.abs((x-960)/280)
    bounded = 1-ease((sides-0.68)/0.34)
    main_curve = 35*np.minimum(sides/0.90,1)**2 * bounded
    gap = 18*bounded*(0.64+0.36*(1-np.minimum(sides,1)**2))
    top = 535 + idle*0.85 - amount*(main_curve + gap*0.43)
    bottom = 549 + idle*0.85 + amount*(gap*0.64 - main_curve)
    y_q = np.where(y < top, 535 + (y-top)*np.clip((535-447)/(top-447),0.62,1.78),
          np.where(y > bottom, 549 + (y-bottom)*np.clip((630-549)/(630-bottom),0.62,1.78),
                   535 + (y-top)*(14/np.maximum(bottom-top,9))))
    active = edge(y-447,14)*edge(630-y,16)*edge(293-np.abs(x-960),20)
    warped = sample(layers["bare"],x,y_q)
    # Leave the original foreground latch and the dangling pearl strand
    # layered on top of the flexible lid.
    original = pixels[250:660,645:1275].astype(np.float32)
    gold = (original[...,0]-original[...,2]>40) & (original[...,1]-original[...,2]>28)
    latch = (x>916)&(x<1004)&(y>511)&(y<690)&gold
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
        dx = (X-(cx+4.0))/19.8
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


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('still',type=Path)
    parser.add_argument('output',type=Path)
    parser.add_argument('--proof',action='store_true')
    args = parser.parse_args()
    raw = subprocess.check_output(['ffmpeg','-v','error','-i',str(args.still),'-pix_fmt','rgb24','-f','rawvideo','-'])
    base = np.frombuffer(raw,dtype=np.uint8).reshape(HEIGHT,WIDTH,3)
    layers = prepare_layers(base)
    if args.proof:
        png(args.output/'smile.png',frame(base,layers,1,1,0,0))
        png(args.output/'wink.png',frame(base,layers,1,1,1,0))
        return
    with args.output.open('xb') as out:
        for n in range(TAIL_FRAMES):
            t = n/30.0
            gaze = ease((t-0.05)/0.31)
            amount = ease((t-0.12)/0.56) * (1-0.15*ease((t-1.73)/0.35))
            wink = ease((t-1.08)/0.14) * (1-ease((t-1.36)/0.21))
            idle = ease(t/0.30) * np.sin(t*5.05)
            out.write(frame(base,layers,gaze,amount,wink,idle).tobytes())


if __name__ == '__main__':
    main()
