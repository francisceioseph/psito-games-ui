"""Cuts, softens and levels the chosen sounds into the assets of psito_games_ui.

Every sound ends as mono 44.1 kHz 16-bit WAV, trimmed, with short fades, at a
loudness picked for its role, so that none jumps out of the others.

The sources are the original files (see assets/LICENSE.md), each decoded to
mono 44.1 kHz WAV under its own name, for example with GStreamer:

    gst-launch-1.0 filesrc location=card-slide-1.ogg ! decodebin ! audioconvert \
      ! audioresample ! audio/x-raw,format=S16LE,channels=1,rate=44100 \
      ! wavenc ! filesink location=sources/card-slide-1.wav

The Freesound ones are named fs_<id>. Then:

    python3 tool/make_sounds.py sources assets/sounds
"""
import array, math, os, sys, wave

SRC, OUT = sys.argv[1], sys.argv[2]
SR = 44100

def load(name):
    w = wave.open(os.path.join(SRC, name + '.wav'))
    assert w.getframerate() == SR and w.getnchannels() == 1
    return [x / 32768 for x in array.array('h', w.readframes(w.getnframes()))]

def cut(a, start=0.0, end=None):
    return a[int(start * SR): None if end is None else int(end * SR)]

def trim(a, floor_db=-45):
    peak = max(abs(x) for x in a)
    th = peak * 10 ** (floor_db / 20)
    idx = [i for i, x in enumerate(a) if abs(x) > th]
    s = max(0, idx[0] - int(.003 * SR))
    e = min(len(a), idx[-1] + int(.01 * SR))
    return a[s:e]

def lowpass(a, hz):
    k = 1 - math.exp(-2 * math.pi * hz / SR)
    out, y = [], 0.0
    for x in a:
        y += k * (x - y)
        out.append(y)
    return out

def highpass(a, hz):
    lp = lowpass(a, hz)
    return [x - l for x, l in zip(a, lp)]

def fade(a, fin=.004, fout=.03):
    n, i_in, i_out = len(a), int(fin * SR), int(min(fout, len(a) / SR / 3) * SR)
    a = list(a)
    for i in range(i_in):
        a[i] *= i / i_in
    for i in range(i_out):
        a[n - 1 - i] *= (i / i_out) ** 2
    return a

def tail(a, seconds=.45, delay=.09, feedback=.38, damp=3000):
    """A soft room after a short tune, so that it ends instead of stopping."""
    a = a + [0.0] * int(seconds * SR)
    d = int(delay * SR)
    out = list(a)
    k = 1 - math.exp(-2 * math.pi * damp / SR)
    y = 0.0
    for i in range(d, len(out)):
        y += k * (out[i - d] - y)
        out[i] += feedback * y
    return out

def loudness(a):
    """The loudest 50 ms, in dBFS RMS."""
    win = int(.05 * SR)
    best = 1e-9
    for i in range(0, max(1, len(a) - win), win // 2):
        seg = a[i:i + win]
        best = max(best, math.sqrt(sum(x * x for x in seg) / len(seg)))
    return 20 * math.log10(best)

def level(a, target_db, ceiling_db=-3):
    gain = 10 ** ((target_db - loudness(a)) / 20)
    peak = max(abs(x) for x in a) * gain
    ceiling = 10 ** (ceiling_db / 20)
    if peak > ceiling:
        gain *= ceiling / peak
    return [x * gain for x in a]

def save(name, a):
    os.makedirs(OUT, exist_ok=True)
    w = wave.open(os.path.join(OUT, name + '.wav'), 'wb')
    w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes(array.array('h', [max(-32767, min(32767, int(x * 32767))) for x in a]).tobytes())
    w.close()
    print(f'{name:12s} {len(a) / SR:5.2f}s  loudness {loudness(a):6.1f} dB  peak {20 * math.log10(max(abs(x) for x in a)):5.1f} dB')

# The loudness of each role. The table sounds sit low, the moments above them.
CARD, SOFT, MOMENT = -21, -25, -17

sounds = {
    # A card turning face up.
    'flip_1': (lambda: trim(load('card-slide-1')), CARD),
    'flip_2': (lambda: trim(load('card-slide-5'), -28), CARD),
    'flip_3': (lambda: trim(load('card-slide-6'), -28), CARD),
    # A card landing on a column, a cell or a foundation.
    'place_1': (lambda: trim(load('card-place-1')), CARD),
    'place_2': (lambda: trim(load('card-place-2')), CARD),
    'place_3': (lambda: trim(load('card-place-3'), -35), CARD),
    # A move the rules do not allow: one short tone, rounded off.
    'refuse': (lambda: lowpass(trim(load('error_004')), 1800), SOFT),
    # A row of cards dealt, and the deck shuffled for a new game.
    'deal': (lambda: trim(load('card-fan-1')), CARD),
    'shuffle': (lambda: cut(load('card-shuffle'), 0, .75), CARD),
    # A whole sequence flying to its nest.
    'gather': (lambda: trim(load('card-shove-4')), CARD),
    # Two birds of the Nest joining into the next.
    'join': (lambda: trim(load('pluck_001')), SOFT),
    # The end of a won game.
    'victory': (lambda: tail(trim(load('jingles_PIZZA02'))), MOMENT),
    # Mines: a leaf lifted, a feather put down, the cat found.
    'leaf': (lambda: highpass(trim(load('fs_57659')), 120), SOFT),
    'feather': (lambda: lowpass(trim(load('tick_004')), 4000), SOFT - 3),
    'cat': (lambda: highpass(trim(load('fs_448084')), 150), MOMENT - 3),
    # Nest: an egg cracking open.
    'hatch': (lambda: highpass(trim(load('fs_244746'), -35), 150), SOFT),
    # The cockatiel peeking at the table.
    'chirp_1': (lambda: highpass(cut(load('fs_871376'), 0, .70), 200), MOMENT - 5),
    'chirp_2': (lambda: highpass(cut(load('fs_871376'), .85), 200), MOMENT - 5),
}

for name, (make, target) in sounds.items():
    save(name, level(fade(make()), target))
