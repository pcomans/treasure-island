"""Advance the approved Chester expression by 60 frames while the camera plays unchanged."""
import argparse
from pathlib import Path

import numpy as np

import animate_wide

WIDTH, HEIGHT = 1920, 1080
FIRST_FRAME, SETTLED_FRAME, END_FRAME = 844, 899, 965
ADVANCE_FRAMES = 60
TAG_START = 900
X0, X1, Y0, Y1 = 645, 1275, 250, 660
PAD_X, PAD_Y = 10, 15
NORM_Y, NORM_X = np.mgrid[Y0-PAD_Y:Y1+PAD_Y,X0-PAD_X:X1+PAD_X].astype(np.float32)


def neutral_geometry(wide,image,f):
    gx, rx, gy = [np.interp(f,wide.TRACK[:,0],wide.TRACK[:,k]) for k in (1,2,3)]
    s = (rx-gx)/117
    eyes = [wide.eye_bounds(image,x,gy,s,(gx+rx)/2,i) for i,x in enumerate((gx,rx))]
    if any(b is None for b in eyes):
        raise ValueError(f"Could not locate both eyes in frame {f}.")
    eyes = np.array(eyes)
    top,bottom = eyes[:,2:].mean(0)
    pupil_y = (top+bottom)*0.5
    expected_tab = pupil_y + 143.5*s
    y0 = int(expected_tab-16)
    tab = image[y0:y0+34,952:969].mean(1)
    warm = (tab[:,0]>192)&(tab[:,1]>154)&(tab[:,0]-tab[:,2]>64)
    hits = np.flatnonzero(warm[:-2]&warm[1:-1]&warm[2:])
    if not len(hits):
        raise ValueError(f"Could not locate gold latch in frame {f}.")
    tab_y = y0+hits[0]
    # Track the front rail physically on both sides. A small gradient search
    # around the expected edge uses the scene outside the rail as well.
    rail_y = int(tab_y+7*s)
    rail_row = image[rail_y-2:rail_y+3].mean(axis=(0,2))
    derivative = np.diff(rail_row)
    corners=[]
    for x,sign in ((660,-1),(1259,1)):
        guess=int(960+(x-960)*s)
        begin=guess-14
        row=derivative[begin:guess+15]
        idx=int(np.argmax(row*sign))
        corners.append(begin+idx+0.5)
    return np.array([corners[0],corners[1],pupil_y,tab_y],dtype=np.float32)


def geometry_track(wide,raw):
    tracks = np.array([neutral_geometry(wide,raw[f-FIRST_FRAME],f)
                       for f in range(FIRST_FRAME,SETTLED_FRAME+1)])
    before = np.pad(tracks,((1,1),(0,0)),mode="edge")
    tracks = .2*before[:-2] + .6*before[1:-1] + .2*before[2:]
    ref = tracks[-1].copy()
    sx = (tracks[:,1]-tracks[:,0]) / (ref[1]-ref[0])
    sy = (tracks[:,3]-tracks[:,2]) / (ref[3]-ref[2])
    tx = tracks[:,0] - sx*ref[0]
    ty = tracks[:,2] - sy*ref[2]
    fit = np.column_stack((sx,sy,tx,ty))
    if np.any((fit[:,:2]<.85)|(fit[:,:2]>1.04)):
        raise ValueError(f"Unexpected face scale {fit[:,:2].min()} to {fit[:,:2].max()}.")
    return fit


def warp_shape(wide,pixels,fit,amount,wink,idle):
    sx,sy,tx,ty = fit
    canonical = pixels.copy()
    reference = np.clip(np.rint(wide.sample(pixels,NORM_X*sx+tx,NORM_Y*sy+ty)),0,255)
    canonical[Y0-PAD_Y:Y1+PAD_Y,X0-PAD_X:X1+PAD_X] = reference.astype(np.uint8)
    artwork = wide.frame(canonical,wide.prepare_layers(canonical),0.,amount,wink,idle)
    difference = artwork[Y0:Y1,X0:X1].astype(np.float32)-canonical[Y0:Y1,X0:X1]
    x0 = int(np.floor(X0*sx+tx))-1
    x1 = int(np.ceil(X1*sx+tx))+1
    y0 = int(np.floor(Y0*sy+ty))-1
    y1 = int(np.ceil(Y1*sy+ty))+1
    yy,xx = np.mgrid[y0:y1,x0:x1].astype(np.float32)
    inverse_x=(xx-tx)/sx-X0
    inverse_y=(yy-ty)/sy-Y0
    delta = wide.sample(difference,inverse_x,inverse_y)
    result = pixels.copy()
    result[y0:y1,x0:x1] = np.clip(np.rint(pixels[y0:y1,x0:x1]+delta),0,255).astype(np.uint8)
    return result


def cues(wide,t,ambient=False):
    smile = float(wide.ease((t-0.12)/0.56)*(1-0.10*wide.ease((t-1.73)/0.35)))
    wink = float(wide.ease((t-1.08)/0.14)*(1-wide.ease((t-1.36)/0.21)))
    # Keep new breathing motion local to the settled smile.
    idle = float((1. if ambient else smile)*wide.ease(t/.30)*np.sin(t*5.05))
    return smile,wink,idle


def make_frame(wide,approved,track,neutral,layers,frame):
    source = approved[frame-FIRST_FRAME]
    # Same reviewed gesture weights, exactly two seconds earlier at 30 fps.
    smile,wink,idle = cues(wide,(frame+ADVANCE_FRAMES-TAG_START)/30.)
    if frame<TAG_START:
        return warp_shape(wide,source,track[frame-FIRST_FRAME],smile,wink,idle)
    # The approved tag is already smiling/winking. Its animation is replaced
    # from the last clean, camera-matched and direct-gaze portrait only.
    earlier_face = wide.frame(neutral,layers,1.,smile,wink,idle)
    old = cues(wide,(frame-TAG_START)/30.,ambient=True)
    previous_face = wide.frame(neutral,layers,1.,*old)
    # Both expressions start from the exact clean settled plate. Apply only
    # their difference to the approved video to retain all untouched pixels.
    result=source.copy()
    patch=np.s_[Y0:Y1,X0:X1]
    delta=earlier_face[patch].astype(np.int16)-previous_face[patch]
    result[patch] = np.clip(source[patch]+delta,0,255).astype(np.uint8)
    return result


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('approved_rgb',type=Path)
    parser.add_argument('tracking_rgb',type=Path)
    parser.add_argument('out',type=Path)
    parser.add_argument('--proof',action='store_true')
    args=parser.parse_args()
    def rgb(path,count):
        shape=(count,HEIGHT,WIDTH,3)
        if path.stat().st_size != np.prod(shape):
            parser.error(f"Expected {count} RGB24 frames in {path}.")
        return np.memmap(path,dtype=np.uint8,mode="r",shape=shape)
    wide=animate_wide
    source=rgb(args.approved_rgb,END_FRAME-FIRST_FRAME+1)
    clean=rgb(args.tracking_rgb,SETTLED_FRAME-FIRST_FRAME+1)
    track=geometry_track(wide,clean)
    neutral=clean[-1]
    layers=wide.prepare_layers(neutral)
    print("Gesture lead: 60 frames. Moving face registration",np.round(track[[0,17,28,32,-1]],3).tolist(),flush=True)
    if args.proof:
        for f in [850,861,871,877,880,885,888,899,900,965]:
            wide.png(args.out/f'{f:04d}.png',make_frame(wide,source,track,neutral,layers,f))
        return
    with args.out.open('xb') as out:
        for f in range(FIRST_FRAME,END_FRAME+1):
            out.write(make_frame(wide,source,track,neutral,layers,f).tobytes())


if __name__=="__main__":
    main()
