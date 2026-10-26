"""Step 2 of 2 for the launch-screen wordmark (see dump_glyph_positions_test.dart).

Builds Android vector drawables of the AlgoritiQ wordmark from the bundled
font outlines and the glyph positions Flutter produced:

- splash_wordmark.xml           static logo (launch screen, Android < 12)
- splash_wordmark_animated.xml  animated logo (system splash, Android 12+)

Animation (the brand idea, an ordered queue whose active item steps out of
line): the three bars form a line one by one, the coral bar steps forward
(next patient called), then the name slides in.

Both are vectors, so Android draws them sharp at any density.

Run from `algoritiQ/app`: python tool/splash_wordmark/build_vector.py
Requires: pip install fonttools
"""

import json
from pathlib import Path

from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer

APP = Path(__file__).resolve().parents[2]
FONT = APP / "assets/fonts/PlusJakartaSans.ttf"
POSITIONS = APP / "tool/splash_wordmark/glyph_positions.json"
RES = APP / "android/app/src/main/res"

NAVY, WHITE, CORAL = "#0B1F3A", "#FFFFFF", "#FF5C39"

# Wordmark geometry from branding/logo/algoritiq/svg/algoritiq-wordmark.svg.
VIEW_W, VIEW_H = 370, 100
TEXT_X, BASELINE_Y = 100, 66
BAR_W, BAR_H, BAR_R = 56, 20, 6
BAR_TOP, BAR_MID, BAR_BOT = (8, 14), (26, 40), (8, 66)
STEP = BAR_MID[0] - BAR_TOP[0]  # how far the coral bar steps forward

# Android 12+ splash icon: 288 dp box, masked to a 192 dp circle.
BOX_DP = 288
LOGO_WIDTH_DP = 170

# Total animation length; keep in sync with SPLASH_ANIMATION_MS in
# MainActivity.kt and windowSplashScreenAnimationDuration in values-v31.
DURATION_MS = 1000


def num(v):
    return f"{v:.2f}".rstrip("0").rstrip(".")


def bar_path(x, y):
    w, h, r = BAR_W, BAR_H, BAR_R
    return (
        f"M{x + r},{y} h{w - 2 * r} a{r},{r} 0 0 1 {r},{r} v{h - 2 * r} "
        f"a{r},{r} 0 0 1 -{r},{r} h-{w - 2 * r} a{r},{r} 0 0 1 -{r},-{r} "
        f"v-{h - 2 * r} a{r},{r} 0 0 1 {r},-{r} z"
    )


def text_paths():
    """Returns (ink pathData for 'Algoriti', coral pathData for 'Q')."""
    font = instancer.instantiateVariableFont(TTFont(FONT), {"wght": 700})
    glyphs = font.getGlyphSet()
    cmap = font.getBestCmap()
    layout = json.loads(POSITIONS.read_text())
    size = layout["fontSize"] / font["head"].unitsPerEm

    ink, q = "", ""
    for g in layout["glyphs"]:
        pen = SVGPathPen(glyphs, ntos=num)
        glyphs[cmap[ord(g["char"])]].draw(
            TransformPen(pen, (size, 0, 0, -size, TEXT_X + g["x"], BASELINE_Y))
        )
        if g["char"] == "Q":
            q += pen.getCommands()
        else:
            ink += pen.getCommands()
    return ink, q


def vector(ink, animated):
    """Vector XML. When animated, attributes hold the animation's start state."""
    s = LOGO_WIDTH_DP / VIEW_W
    tx = (BOX_DP - VIEW_W * s) / 2
    ty = (BOX_DP - VIEW_H * s) / 2
    text_ink, text_q = text_paths()

    hidden_bar = ' android:scaleX="0"' if animated else ""
    mid_back = f' android:translateX="-{STEP}"' if animated else ""
    text_back = ' android:translateX="-12"' if animated else ""
    alpha = ' android:fillAlpha="0"' if animated else ""

    def bar(name, xy, color, extra="", indent=8):
        pad = " " * indent
        return (
            f'{pad}<group android:name="{name}" android:pivotX="{xy[0]}"{extra}>\n'
            f'{pad}    <path android:fillColor="{color}" '
            f'android:pathData="{bar_path(*xy)}"/>\n'
            f"{pad}</group>\n"
        )

    return (
        '<vector xmlns:android="http://schemas.android.com/apk/res/android"\n'
        f'    android:width="{BOX_DP}dp" android:height="{BOX_DP}dp"\n'
        f'    android:viewportWidth="{BOX_DP}" android:viewportHeight="{BOX_DP}">\n'
        f'    <group android:translateX="{tx:.3f}" android:translateY="{ty:.3f}"'
        f' android:scaleX="{s:.5f}" android:scaleY="{s:.5f}">\n'
        + bar("barTop", BAR_TOP, ink, hidden_bar)
        + f'        <group android:name="barMidStep"{mid_back}>\n'
        + bar("barMid", BAR_MID, CORAL, hidden_bar, indent=12)
        + "        </group>\n"
        + bar("barBot", BAR_BOT, ink, hidden_bar)
        + f'        <group android:name="text"{text_back}>\n'
        f'            <path android:name="textInk" android:fillColor="{ink}"{alpha}'
        f' android:pathData="{text_ink}"/>\n'
        f'            <path android:name="textQ" android:fillColor="{CORAL}"{alpha}'
        f' android:pathData="{text_q}"/>\n'
        "        </group>\n"
        "    </group>\n"
        "</vector>"
    )


def animator(prop, start, end, offset, duration, interpolator):
    return (
        '<objectAnimator xmlns:android="http://schemas.android.com/apk/res/android"\n'
        f'                    android:propertyName="{prop}" android:valueType="floatType"\n'
        f'                    android:valueFrom="{start}" android:valueTo="{end}"\n'
        f'                    android:startOffset="{offset}" android:duration="{duration}"\n'
        f'                    android:interpolator="@android:interpolator/{interpolator}"/>'
    )


def target(name, *animators):
    body = "\n".join(animators)
    if len(animators) > 1:
        body = (
            '<set xmlns:android="http://schemas.android.com/apk/res/android">\n'
            + body.replace(' xmlns:android="http://schemas.android.com/apk/res/android"', "")
            + "\n</set>"
        )
    return (
        f'    <target android:name="{name}">\n'
        '        <aapt:attr name="android:animation">\n'
        f"            {body}\n"
        "        </aapt:attr>\n"
        "    </target>\n"
    )


def animated_vector(ink):
    grow = "decelerate_cubic"
    return (
        '<?xml version="1.0" encoding="utf-8"?>\n'
        "<!-- Generated by tool/splash_wordmark/build_vector.py. Do not edit. -->\n"
        '<animated-vector xmlns:android="http://schemas.android.com/apk/res/android"\n'
        '    xmlns:aapt="http://schemas.android.com/aapt">\n'
        '    <aapt:attr name="android:drawable">\n'
        + vector(ink, animated=True)
        + "\n    </aapt:attr>\n"
        # 1. The queue forms: bars grow in, one after another.
        + target("barTop", animator("scaleX", 0, 1, 0, 280, grow))
        + target("barMid", animator("scaleX", 0, 1, 90, 280, grow))
        + target("barBot", animator("scaleX", 0, 1, 180, 280, grow))
        # 2. The next patient is called: the coral bar steps forward.
        + target(
            "barMidStep",
            animator("translateX", -STEP, 0, 500, 320, "overshoot"),
        )
        # 3. The name slides in.
        + target("text", animator("translateX", -12, 0, 560, 380, grow))
        + target("textInk", animator("fillAlpha", 0, 1, 560, 380, "decelerate_quad"))
        + target("textQ", animator("fillAlpha", 0, 1, 640, 360, "decelerate_quad"))
        + "</animated-vector>\n"
    )


def static_vector(ink):
    return (
        '<?xml version="1.0" encoding="utf-8"?>\n'
        "<!-- Generated by tool/splash_wordmark/build_vector.py. Do not edit. -->\n"
        + vector(ink, animated=False)
        + "\n"
    )


def write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8", newline="\n")
    print("wrote", path.relative_to(APP))


def main():
    for folder, ink in (("drawable", NAVY), ("drawable-night", WHITE)):
        write(RES / folder / "splash_wordmark.xml", static_vector(ink))
        write(RES / folder / "splash_wordmark_animated.xml", animated_vector(ink))


main()
