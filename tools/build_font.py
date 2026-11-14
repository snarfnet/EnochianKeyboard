#!/usr/bin/env python3
"""Build EnochianDee.ttf by tracing Dee's own alphabet table.

Source: John Dee, diary entry of 6 May 1583, British Library Sloane MS 3188
f.104 (public domain; Wikimedia Commons "Enochian letters (1583 manuscript).png").
Prepare it with:  tools/ref/sloane3188_white.png  (RGBA flattened onto white)

Dee wrote the table right to left:
    row 1 = B C G D F A E M I H L      row 2 = P Q N X O R Z U S T
so read left to right the glyphs are L H I M E A F D G C B / T S V Z R O X N Q P.

Unlike the Theban font, every glyph shares one scale and its row's baseline,
so letters keep the relative sizes and positions they have on Dee's page.
Glyphs are mapped onto Latin code points (A-Z, a-z), with the later
conventions K->C, J/Y->I, U/W->V.
"""
import os
import cv2
import numpy as np
from fontTools.fontBuilder import FontBuilder
from fontTools.pens.ttGlyphPen import TTGlyphPen

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "ref", "sloane3188_white.png")
OUT = os.path.join(os.path.dirname(HERE), "Resources", "EnochianDee.ttf")

ROWS = [
    {"y": (600, 860), "letters": "LHIMEAFDGCB"},
    {"y": (840, 1080), "letters": "TSVZROXNQP"},
]
MIN_MAIN_AREA = 3000      # a glyph body
MIN_PART_AREA = 40        # dots and detached strokes that belong to a glyph
UPM = 1000
CAP = 640                 # median glyph height in font units
ASCENT, DESCENT = 900, -260
SIDE = 70
UPSCALE = 4
ALIASES = {"K": "C", "J": "I", "Y": "I", "U": "V", "W": "V"}


def segment(bw):
    n, lab, st, _ = cv2.connectedComponentsWithStats(bw)
    glyphs = {}
    for row in ROWS:
        y0, y1 = row["y"]
        mains = [i for i in range(1, n)
                 if st[i][4] >= MIN_MAIN_AREA and y0 <= st[i][1] + st[i][3] / 2 <= y1]
        mains.sort(key=lambda i: st[i][0])
        assert len(mains) == len(row["letters"]), (row["letters"], len(mains))
        boxes = []
        for i in mains:
            x, y, w, h, _ = st[i]
            boxes.append([x, y, x + w, y + h, [i]])
        # attach small parts (dots, detached strokes) to the nearest glyph in the row
        for i in range(1, n):
            x, y, w, h, a = st[i]
            if i in mains or a < MIN_PART_AREA or a >= MIN_MAIN_AREA:
                continue
            cy = y + h / 2
            if not (y0 <= cy <= y1):
                continue
            cx = x + w / 2
            best = min(boxes, key=lambda b: abs((b[0] + b[2]) / 2 - cx))
            if best[0] - 30 <= cx <= best[2] + 30:
                best[4].append(i)
                best[0], best[1] = min(best[0], x), min(best[1], y)
                best[2], best[3] = max(best[2], x + w), max(best[3], y + h)
        baseline = float(np.median([b[3] for b in boxes]))
        for letter, b in zip(row["letters"], boxes):
            mask = np.isin(lab, b[4]).astype(np.uint8) * 255
            glyphs[letter] = (mask, b, baseline)
    return glyphs


def outlines(mask, box):
    x0, y0, x1, y1 = box[:4]
    pad = 8
    crop = mask[y0 - pad:y1 + pad, x0 - pad:x1 + pad]
    up = cv2.resize(crop, None, fx=UPSCALE, fy=UPSCALE, interpolation=cv2.INTER_CUBIC)
    up = cv2.GaussianBlur(up, (0, 0), sigmaX=3.2)
    _, up = cv2.threshold(up, 128, 255, cv2.THRESH_BINARY)
    cnts, hier = cv2.findContours(up, cv2.RETR_CCOMP, cv2.CHAIN_APPROX_NONE)
    result = []
    for i, c in enumerate(cnts):
        if cv2.contourArea(c) < 30 * UPSCALE:
            continue
        approx = cv2.approxPolyDP(c, 1.2, True).reshape(-1, 2).astype(float)
        if len(approx) < 3:
            continue
        # back to source pixels
        pts = approx / UPSCALE + np.array([x0 - pad, y0 - pad])
        result.append((pts, hier[0][i][3] != -1))
    return result


def main():
    img = cv2.imread(SRC, cv2.IMREAD_GRAYSCALE)
    _, bw = cv2.threshold(img, 128, 255, cv2.THRESH_BINARY_INV)
    glyphs = segment(bw)
    heights = [b[3] - b[1] for _, b, _ in glyphs.values()]
    scale = CAP / float(np.median(heights))

    order = [".notdef", "space"] + sorted(glyphs)
    tt, metrics = {}, {}
    pen = TTGlyphPen(None)
    pen.moveTo((100, 0)); pen.lineTo((100, 700)); pen.lineTo((500, 700)); pen.lineTo((500, 0)); pen.closePath()
    tt[".notdef"] = pen.glyph(); metrics[".notdef"] = (600, 100)
    tt["space"] = TTGlyphPen(None).glyph(); metrics["space"] = (360, 0)

    for name, (mask, box, baseline) in glyphs.items():
        x0 = box[0]
        pen = TTGlyphPen(None)
        xs = []
        for pts, hole in outlines(mask, box):
            fx = (pts[:, 0] - x0) * scale + SIDE
            fy = (baseline - pts[:, 1]) * scale
            poly = np.stack([fx, fy], axis=1)
            # TrueType: outer contours clockwise, holes counter-clockwise (y-up)
            area = 0.5 * np.sum(poly[:, 0] * np.roll(poly[:, 1], -1) - np.roll(poly[:, 0], -1) * poly[:, 1])
            clockwise = area < 0
            if clockwise == hole:
                poly = poly[::-1]
            pen.moveTo(tuple(np.round(poly[0]).astype(int)))
            for p in poly[1:]:
                pen.lineTo(tuple(np.round(p).astype(int)))
            pen.closePath()
            xs.extend(fx)
        tt[name] = pen.glyph()
        metrics[name] = (int(round(max(xs) + SIDE)), SIDE)

    cmap = {ord(" "): "space"}
    for c in "ABCDEFGHIJKLMNOPQRSTUVWXYZ":
        g = ALIASES.get(c, c)
        if g in glyphs:
            cmap[ord(c)] = g
            cmap[ord(c.lower())] = g

    fb = FontBuilder(UPM, isTTF=True)
    fb.setupGlyphOrder(order)
    fb.setupCharacterMap(cmap)
    fb.setupGlyf(tt)
    fb.setupHorizontalMetrics(metrics)
    fb.setupHorizontalHeader(ascent=ASCENT, descent=DESCENT)
    fb.setupNameTable(dict(
        familyName="EnochianDee", styleName="Regular", fullName="EnochianDee Regular",
        psName="EnochianDee", version="Version 1.0",
        copyright="Traced from John Dee's 1583 table, British Library Sloane MS 3188 (public domain).",
    ))
    fb.setupOS2(sTypoAscender=ASCENT, sTypoDescender=DESCENT, sTypoLineGap=0,
                usWinAscent=ASCENT, usWinDescent=-DESCENT)
    fb.setupPost()
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    fb.save(OUT)
    missing = [c for c in "ABCDEFGHIJKLMNOPQRSTUVWXYZ" if ord(c) not in cmap]
    print(f"Wrote {OUT}: {len(glyphs)} glyphs, scale {scale:.2f}, unmapped: {missing}")


if __name__ == "__main__":
    main()
