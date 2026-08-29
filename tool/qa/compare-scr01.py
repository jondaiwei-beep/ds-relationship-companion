#!/usr/bin/env python3
"""Compare an SCR-01 implementation render against the approved design.

Reports vertical band alignment. Bands are contiguous runs of non-background
rows, so a missing or extra element shows up as a band-count mismatch and a
shifted element shows up as a delta.

    python3 tool/qa/compare-scr01.py
"""
import struct, subprocess, sys, tempfile, os

REF = "design/screens/SCR-01-today/candidates/rev-2/source.png"
IMPL = "design/qa/implementation/SCR-01/today-default.png"
BG = (7, 10, 6)
TOLERANCE = 12


def to_bmp(src, dst, height=None):
    cmd = ["sips", "-s", "format", "bmp", src, "--out", dst]
    if height:
        cmd = ["sips", "-Z", str(height), "-s", "format", "bmp", src, "--out", dst]
    subprocess.run(cmd, capture_output=True, check=True)


def load(path):
    d = open(path, "rb").read()
    off = struct.unpack("<I", d[10:14])[0]
    w, h = struct.unpack("<ii", d[18:26])
    bpp = struct.unpack("<H", d[28:30])[0]
    H, row = abs(h), ((w * bpp // 8 + 3) // 4) * 4

    def px(x, y):
        yy = H - 1 - y if h > 0 else y
        i = off + yy * row + x * (bpp // 8)
        return (d[i + 2], d[i + 1], d[i])

    return px, w, H


def bands(px, w, h):
    out, run = [], None
    for y in range(h):
        hit = any(
            not all(abs(px(x, y)[i] - BG[i]) < 10 for i in range(3))
            for x in range(10, w - 10, 6)
        )
        if hit and run is None:
            run = y
        if not hit and run is not None:
            if y - run >= 4:
                out.append((run, y))
            run = None
    if run is not None:
        out.append((run, h))
    return out


def main():
    tmp = tempfile.mkdtemp()
    ref_bmp, impl_bmp = f"{tmp}/ref.bmp", f"{tmp}/impl.bmp"
    to_bmp(REF, ref_bmp, height=844)
    to_bmp(IMPL, impl_bmp)

    a, w, h = load(ref_bmp)
    b, _, _ = load(impl_bmp)
    A, B = bands(a, w, h), bands(b, w, h)

    print(f"design {len(A)} bands / implementation {len(B)} bands\n")
    within = 0
    for i in range(max(len(A), len(B))):
        la = f"{A[i][0]:3d}" if i < len(A) else " --"
        lb = f"{B[i][0]:3d}" if i < len(B) else " --"
        note = ""
        if i < len(A) and i < len(B):
            dy = B[i][0] - A[i][0]
            if abs(dy) <= TOLERANCE:
                within += 1
            note = f"  {dy:+4d}dp" + ("   over tolerance" if abs(dy) > TOLERANCE else "")
        print(f"  {i:2d}  design {la}   impl {lb}{note}")

    n = min(len(A), len(B))
    print(f"\nwithin {TOLERANCE}dp: {within}/{n}")
    if len(A) != len(B):
        print("band count differs — an element is missing or extra")
        return 1
    return 0


if __name__ == "__main__":
    os.chdir(os.path.join(os.path.dirname(__file__), "..", ".."))
    sys.exit(main())
