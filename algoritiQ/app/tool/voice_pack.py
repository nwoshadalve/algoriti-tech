#!/usr/bin/env python3
# Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
# All rights reserved.
#
# Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
# or distribution is prohibited.
"""Builds and checks the Bengali voice pack the tablet speaks calls with.

The tablet joins short clips: "টোকেন নম্বর" + the serial number as words ("এক হাজার এক") +
a closing phrase that depends on the queue and on first call or recall. The clips live in
`assets/announcements/<key>.wav`. They must be mono, 16-bit PCM, all with the same
sample rate (24000 Hz is what this tool makes).

  python tool/voice_pack.py list              print every clip and the words to say
  python tool/voice_pack.py check             check the folder is complete and consistent
  python tool/voice_pack.py pitch             check every clip is one voice (needs `pip install numpy`):
                                              a man sits near 100-160 Hz, a woman near 200-260 Hz
  python tool/voice_pack.py azure             make every clip with Azure neural speech
                                              (needs AZURE_SPEECH_KEY and AZURE_SPEECH_REGION;
                                               AZURE_SPEECH_VOICE defaults to bn-BD-PradeepNeural)

  python tool/voice_pack.py edge              make every missing clip with the Edge read-aloud voice
                                              (EDGE_OVERWRITE=1 remakes all; EDGE_ONLY=h1_c,t10 only those)
                                              (no key; needs `pip install edge-tts imageio-ffmpeg`;
                                               EDGE_VOICE defaults to bn-BD-PradeepNeural, the voice of the whole
                                               pack: never mix voices in one pack)

Recorded by a person instead? Save each clip as `<key>.wav`, then convert to the
format above, for example:
  ffmpeg -i in.m4a -ac 1 -ar 24000 -sample_fmt s16 assets/announcements/n5.wav
and run `check`.
"""
import os
import sys
import time
import wave
import urllib.request
import xml.sax.saxutils as xml

sys.stdout.reconfigure(encoding="utf-8")
PACK = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "assets", "announcements")
RATE = 24000

# The voice every clip of the pack is spoken in. A pack made of two voices (a man for
# some numbers, a woman for others) is confusing to hear, so remake clips with this one.
DEFAULT_VOICE = "bn-BD-PradeepNeural"

# How fast the voice speaks, slower than normal so a waiting room can follow the
# number. Every clip must use the same rate or the joined call changes speed mid-way.
SPEAKING_RATE = "-15%"

# "য়" can be written as one character (U+09DF) or as য + a dot (U+09AF U+09BC); text that
# is normalised ends up in the second form. The voice says the two differently, and the
# second makes ছয় ("six") sound like "choo". Always send the first.
Y_DOT = "\u09af\u09bc"
Y_ONE = "\u09df"


def speakable(text):
    """The text the way the voice reads it best."""
    return text.replace(Y_DOT, Y_ONE)

NUMBERS = (
    "শূন্য এক দুই তিন চার পাঁচ ছয় সাত আট নয় দশ এগারো বারো তেরো চৌদ্দ পনেরো ষোলো সতেরো আঠারো উনিশ "
    "বিশ একুশ বাইশ তেইশ চব্বিশ পঁচিশ ছাব্বিশ সাতাশ আটাশ ঊনত্রিশ ত্রিশ "
    "একত্রিশ বত্রিশ তেত্রিশ চৌত্রিশ পঁয়ত্রিশ ছত্রিশ সাঁইত্রিশ আটত্রিশ ঊনচল্লিশ চল্লিশ "
    "একচল্লিশ বিয়াল্লিশ তেতাল্লিশ চুয়াল্লিশ পঁয়তাল্লিশ ছেচল্লিশ সাতচল্লিশ আটচল্লিশ ঊনপঞ্চাশ পঞ্চাশ "
    "একান্ন বাহান্ন তিপ্পান্ন চুয়ান্ন পঞ্চান্ন ছাপ্পান্ন সাতান্ন আটান্ন ঊনষাট ষাট "
    "একষট্টি বাষট্টি তেষট্টি চৌষট্টি পঁয়ষট্টি ছেষট্টি সাতষট্টি আটষট্টি ঊনসত্তর সত্তর "
    "একাত্তর বাহাত্তর তিয়াত্তর চুয়াত্তর পঁচাত্তর ছিয়াত্তর সাতাত্তর আটাত্তর ঊনআশি আশি "
    "একাশি বিরাশি তিরাশি চুরাশি পঁচাশি ছিয়াশি সাতাশি অষ্টাশি ঊননব্বই নব্বই "
    "একানব্বই বিরানব্বই তিরানব্বই চুরানব্বই পঁচানব্বই ছিয়ানব্বই সাতানব্বই আটানব্বই নিরানব্বই"
).split()
HUNDREDS = "একশো দুইশো তিনশো চারশো পাঁচশো ছয়শো সাতশো আটশো নয়শো".split()

# Keep in sync with lib/features/tv_live/application/call_clip_keys.dart.
CLIPS = {f"n{i}": word for i, word in enumerate(NUMBERS)}
CLIPS.update({f"h{i + 1}": word for i, word in enumerate(HUNDREDS)})
CLIPS["thousand"] = "হাজার"
CLIPS["lakh1"] = "এক লাখ"
# Words spoken as part of a longer phrase and cut out of it, so that they run on into
# the next word the way a native speaker says them: key -> (phrase, first word, end word).
SPANS = {"token_c": ("টোকেন নম্বর এক হাজার", 0, 2)}
SPANS.update({f"t{d}": (f"{NUMBERS[d]} হাজার এক", 0, 2) for d in range(1, 100)})
SPANS.update({f"h{h + 1}_c": (f"{HUNDREDS[h]} এক", 0, 1) for h in range(1, 9)})
# "একশো" cut out of a running phrase is only 0.26 s and its first syllable is swallowed
# ("অকশো"), which is heard on every number from 100 to 199. It is spoken whole instead.
CLIPS["h1_c"] = HUNDREDS[0]
CLIPS.update({key: phrase for key, (phrase, _, _) in SPANS.items()})
CLIPS["h1_c"] = HUNDREDS[0]
CLIPS["come"] = "অনুগ্রহ করে ভেতরে আসুন"
CLIPS["come_report"] = "অনুগ্রহ করে আপনার রিপোর্ট নিয়ে আসুন"
CLIPS["come_dressing"] = "ড্রেসিং এর জন্য অনুগ্রহ করে আসুন"
CLIPS["recall_come"] = "আপনাকে আবার ডাকা হচ্ছে, অনুগ্রহ করে ভেতরে আসুন"
CLIPS["recall_report"] = "আপনাকে আবার ডাকা হচ্ছে, অনুগ্রহ করে আপনার রিপোর্ট নিয়ে আসুন"
CLIPS["recall_dressing"] = "আপনাকে আবার ডাকা হচ্ছে, ড্রেসিং এর জন্য অনুগ্রহ করে আসুন"
OPTIONAL = {}


def path(key):
    return os.path.join(PACK, key + ".wav")


def cmd_list():
    for key, text in {**CLIPS, **OPTIONAL}.items():
        print(f"{key}.wav\t{text}" + ("\t(optional)" if key in OPTIONAL else ""))


def cmd_check():
    problems, formats = [], set()
    for key in CLIPS:
        if not os.path.exists(path(key)):
            problems.append(f"missing: {key}.wav ({CLIPS[key]})")
    for key in {**CLIPS, **OPTIONAL}:
        if not os.path.exists(path(key)):
            continue
        with wave.open(path(key)) as w:
            if w.getnchannels() != 1 or w.getsampwidth() != 2:
                problems.append(f"{key}.wav must be mono 16-bit")
            if w.getnframes() == 0:
                problems.append(f"{key}.wav is empty")
            formats.add(w.getframerate())
    if len(formats) > 1:
        problems.append(f"clips have different sample rates: {sorted(formats)}")
    for p in problems:
        print(p)
    print("The voice pack is complete." if not problems else f"{len(problems)} problem(s).")
    return 1 if problems else 0


def _pitch(path_):
    """The pitch of a clip in Hz (the median over its voiced stretches), or None."""
    import numpy as np

    with wave.open(path_) as w:
        rate = w.getframerate()
        x = np.frombuffer(w.readframes(w.getnframes()), dtype=np.int16).astype(np.float64)
    frame, hop = int(rate * 0.04), int(rate * 0.02)
    lo, hi = int(rate / 400), int(rate / 70)
    found = []
    for start in range(0, len(x) - frame, hop):
        seg = x[start:start + frame] - x[start:start + frame].mean()
        if np.sqrt((seg ** 2).mean()) < 300:
            continue
        ac = np.correlate(seg, seg, "full")[frame - 1:]
        if ac[0] <= 0:
            continue
        ac = ac / ac[0]
        lag = lo + int(np.argmax(ac[lo:hi]))
        if ac[lag] > 0.5:
            found.append(rate / lag)
    return float(np.median(found)) if len(found) >= 3 else None


def cmd_pitch():
    """Fails when the clips are in more than one voice (some a man, some a woman)."""
    deep, high, unknown = [], [], []
    for name in {**CLIPS, **OPTIONAL}:
        if not os.path.exists(path(name)):
            continue
        hz = _pitch(path(name))
        (unknown if hz is None else high if hz >= 195 else deep).append(name)
    print(len(deep), "clips sound like a man,", len(high), "like a woman,", len(unknown), "could not be told")
    minority = high if len(deep) >= len(high) else deep
    if minority:
        print("Mixed voices. Remake these in one voice (EDGE_ONLY=... EDGE_OVERWRITE=1):")
        print(",".join(sorted(minority)))
        return 1
    print("One voice.")
    return 0


def cmd_azure():
    key = os.environ.get("AZURE_SPEECH_KEY")
    region = os.environ.get("AZURE_SPEECH_REGION")
    voice = os.environ.get("AZURE_SPEECH_VOICE", DEFAULT_VOICE)
    if not key or not region:
        sys.exit("Set AZURE_SPEECH_KEY and AZURE_SPEECH_REGION first.")
    os.makedirs(PACK, exist_ok=True)
    for name, text in {**CLIPS, **OPTIONAL}.items():
        out = path(name)
        if os.path.exists(out):
            continue
        ssml = (
            f"<speak version='1.0' xml:lang='bn-BD'><voice name='{voice}'>"
            f"<prosody rate='{SPEAKING_RATE}'>{xml.escape(speakable(text))}</prosody></voice></speak>"
        )
        request = urllib.request.Request(
            f"https://{region}.tts.speech.microsoft.com/cognitiveservices/v1",
            data=ssml.encode("utf-8"),
            headers={
                "Ocp-Apim-Subscription-Key": key,
                "Content-Type": "application/ssml+xml",
                "X-Microsoft-OutputFormat": "riff-24khz-16bit-mono-pcm",
                "User-Agent": "algoritiq-voice-pack",
            },
        )
        with urllib.request.urlopen(request, timeout=30) as reply, open(out, "wb") as f:
            f.write(reply.read())
        print("made", name, text)
        time.sleep(0.3)
    return cmd_check()


def _edge_maker():
    """Returns make(text, out_path, span=None) that speaks `text` into a trimmed 24 kHz mono WAV.

    With span=(first, end) the whole text is spoken but only words first..end-1 are kept,
    cut where the next word starts: the kept words run on into whatever follows them.
    """
    import asyncio
    import subprocess
    import tempfile

    import edge_tts
    import imageio_ffmpeg

    voice = os.environ.get("EDGE_VOICE", DEFAULT_VOICE)
    ffmpeg = imageio_ffmpeg.get_ffmpeg_exe()
    tmp = tempfile.mkdtemp()
    # Cut the silence the voice leaves at both ends and soften both edges so the
    # joined words flow without clicks.
    trim = (
        "silenceremove=1:0:-45dB,areverse,silenceremove=1:0:-45dB,"
        "afade=t=in:d=0.006,areverse,afade=t=in:d=0.006"
    )

    async def speak(text, mp3, bounds):
        for attempt in range(4):
            try:
                bounds.clear()
                talk = edge_tts.Communicate(speakable(text), voice, rate=SPEAKING_RATE, boundary="WordBoundary")
                with open(mp3, "wb") as f:
                    async for m in talk.stream():
                        if m["type"] == "audio":
                            f.write(m["data"])
                        elif m["type"] == "WordBoundary":
                            bounds.append(m["offset"] / 1e7)
                return
            except edge_tts.exceptions.NoAudioReceived:
                if attempt == 3:
                    raise
                await asyncio.sleep(1.5)

    def valley(wav_path, near):
        """The time of the quietest moment around `near`: the gap between two words.

        The voice reports where words start only roughly, so the real gap is found
        in the audio itself.
        """
        import math
        import struct

        with wave.open(wav_path) as w:
            n = w.getnframes()
            samples = struct.unpack("<%dh" % n, w.readframes(n))
        window, step = int(RATE * 0.008), int(RATE * 0.004)
        best_time, best = near, None
        t = max(near - 0.03, 0.0)
        while t < near + 0.14 and int(t * RATE) + window <= n:
            i = int(t * RATE)
            level = math.sqrt(sum(x * x for x in samples[i:i + window]) / window)
            if best is None or level < best:
                best, best_time = level, t + 0.004
            t += step / RATE
        return best_time

    def make(text, out, span=None):
        mp3 = os.path.join(tmp, "clip.mp3")
        bounds = []
        asyncio.run(speak(text, mp3, bounds))
        source, cut = mp3, []
        if span:
            first, end = span
            if first != 0 or len(bounds) <= end:
                raise RuntimeError(f"cannot cut words {span} out of {text!r}")
            source = os.path.join(tmp, "clip.wav")
            subprocess.run(
                [ffmpeg, "-y", "-loglevel", "error", "-i", mp3, "-ac", "1", "-ar", str(RATE),
                 "-sample_fmt", "s16", source],
                check=True,
            )
            cut = ["-to", f"{valley(source, bounds[end]):.3f}"]
        subprocess.run(
            [ffmpeg, "-y", "-loglevel", "error", *cut, "-i", source, "-af", trim, "-ac", "1",
             "-ar", str(RATE), "-sample_fmt", "s16", out],
            check=True,
        )

    return make


def cmd_edge():
    """Makes every call clip with Microsoft Edge's read-aloud voices, which need no key."""
    make = _edge_maker()
    os.makedirs(PACK, exist_ok=True)
    only = {k.strip() for k in os.environ.get("EDGE_ONLY", "").split(",") if k.strip()}
    for name, text in {**CLIPS, **OPTIONAL}.items():
        if only and name not in only:
            continue
        out = path(name)
        if os.path.exists(out) and not os.environ.get("EDGE_OVERWRITE"):
            continue
        phrase, first, end = SPANS.get(name, (text, None, None))
        make(phrase, out, None if first is None else (first, end))
        print("made", name, text)
    return cmd_check()


if __name__ == "__main__":
    commands = {
        "list": cmd_list,
        "check": cmd_check,
        "azure": cmd_azure,
        "edge": cmd_edge,
        "pitch": cmd_pitch,
    }
    if len(sys.argv) != 2 or sys.argv[1] not in commands:
        sys.exit(__doc__)
    sys.exit(commands[sys.argv[1]]() or 0)
