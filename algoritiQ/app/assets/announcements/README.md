# Voice pack

Short Bengali clips the tablet joins into the spoken call: "টোকেন নম্বর", the serial
as Bengali words (106 is "একশো ছয়", 25678 is "পঁচিশ হাজার ছয়শো আটাত্তর"; every
serial from 1 to 100000 can be spoken), then a closing phrase that depends on the queue (regular, report,
dressing) and on first call or recall. The patient's name is never spoken. Files are
`<key>.wav`: mono, 16-bit, one sample rate for all.

Every clip is spoken by **one voice**, the male Edge voice `bn-BD-PradeepNeural` (the
tool's default). A pack with some clips by a man and some by a woman sounds confusing;
`python tool/voice_pack.py pitch` fails when the voices are mixed. When you remake clips,
use the same voice, for example `EDGE_ONLY=t10,t11 EDGE_OVERWRITE=1 python tool/voice_pack.py edge`.

The tool sends "য়" as the single character U+09DF, not as য + a dot (U+09AF U+09BC, what
text normalisation gives): the voice reads the second form wrongly ("ছয়" comes out as
"ছু"). The same spelling is sent to the phone's own voice.

Run `python tool/voice_pack.py list` for every file and the words to say, and
`python tool/voice_pack.py check` to verify a finished pack.

The number clips are `n0`..`n99` (one word each), `h1`..`h9` and `h1_c`..`h9_c` (the
hundreds, alone and run on into the rest), `t1`..`t99` (the thousands, run on),
`thousand` and `lakh1` (100000). `*_c` and `t*` are cut out of a longer phrase so they
run on into the next word.

While a clip is missing the tablet falls back to the phone's own text-to-speech.
