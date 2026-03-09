#!/usr/bin/env python3
"""
Pixel Art Sprite Sheet Generator for The Bichon's Run
Generates all game sprite sheets as PNG files.
"""
from PIL import Image, ImageDraw
import os
import math

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), '..', 'assets', 'images')
os.makedirs(OUTPUT_DIR, exist_ok=True)

# ============================================================
# Helpers
# ============================================================

def create_sheet(frame_w, frame_h, num_frames):
    """Create a transparent sprite sheet image."""
    img = Image.new('RGBA', (frame_w * num_frames, frame_h), (0, 0, 0, 0))
    return img

def get_frame(img, frame_w, frame_h, idx):
    """Get a draw context offset to a specific frame."""
    return idx * frame_w  # x offset

def px(draw, x, y, color, ox=0):
    """Draw a single pixel (2x2 for crispness at 36x40)."""
    draw.rectangle([ox + x*2, y*2, ox + x*2 + 1, y*2 + 1], fill=color)

def px1(draw, x, y, color, ox=0):
    """Draw a single 1x1 pixel."""
    if 0 <= x and 0 <= y:
        draw.point((ox + x, y), fill=color)

def rect(draw, x, y, w, h, color, ox=0):
    """Draw a filled rectangle in pixel coords."""
    draw.rectangle([ox + x, y, ox + x + w - 1, y + h - 1], fill=color)

def circle_pixels(draw, cx, cy, r, color, ox=0):
    """Draw a filled circle."""
    draw.ellipse([ox + cx - r, cy - r, ox + cx + r, cy + r], fill=color)

# ============================================================
# BICHON (Player) - 36x40, animations: idle(4), run(6), jump(3), attack(3)
# ============================================================

# Colors
WHITE_FUR = (250, 250, 250, 255)
CREAM_FUR = (240, 232, 216, 255)
BODY_SHADOW = (230, 225, 215, 255)
EYE_BLACK = (44, 44, 44, 255)
EYE_SHINE = (255, 255, 255, 255)
NOSE_BLACK = (51, 51, 51, 255)
EAR_COLOR = (240, 232, 216, 255)
TONGUE_PINK = (255, 140, 140, 255)
SWORD_BLADE = (180, 180, 200, 255)
SWORD_GUARD = (255, 215, 0, 255)
SWORD_HANDLE = (139, 90, 43, 255)
TAIL_COLOR = (245, 245, 245, 255)

def draw_bichon_body(draw, ox, body_y_offset=0, leg_phase=0, tail_phase=0,
                      show_sword=False, sword_angle=0, mouth_open=False, squash=0):
    """Draw the bichon at given frame offset."""
    # Body center at roughly (18, 22) in 36x40 space
    bx, by = 18, 20 + body_y_offset

    # === Tail ===
    tail_y = by + 2 + int(math.sin(tail_phase) * 2)
    rect(draw, 2, tail_y - 1, 5, 3, TAIL_COLOR, ox)
    rect(draw, 1, tail_y, 2, 2, WHITE_FUR, ox)
    # Fluffy tail tip
    rect(draw, 0, tail_y - 2, 3, 2, (248, 248, 248, 255), ox)

    # === Body (oval-ish) ===
    # Main body
    rect(draw, 8, by - 2 - squash, 18, 12 + squash, WHITE_FUR, ox)
    rect(draw, 6, by, 22, 8, WHITE_FUR, ox)
    rect(draw, 10, by - 3 - squash, 14, 2, WHITE_FUR, ox)
    # Belly shadow
    rect(draw, 9, by + 6, 16, 3, BODY_SHADOW, ox)
    # Fluffy texture dots
    for fx, fy in [(8, by-1), (24, by-1), (7, by+4), (25, by+4)]:
        px1(draw, fx, fy, (245, 240, 235, 255), ox)

    # === Legs ===
    leg_anim = int(math.sin(leg_phase) * 3)
    # Back legs
    rect(draw, 9, by + 9, 4, 6 - leg_anim, WHITE_FUR, ox)
    rect(draw, 8, by + 14 - leg_anim, 5, 2, CREAM_FUR, ox)  # paw
    rect(draw, 21, by + 9, 4, 6 + leg_anim, WHITE_FUR, ox)
    rect(draw, 20, by + 14 + leg_anim, 5, 2, CREAM_FUR, ox)  # paw

    # === Head ===
    hy = by - 10 - squash
    # Head base
    rect(draw, 11, hy, 14, 12, WHITE_FUR, ox)
    rect(draw, 9, hy + 2, 18, 8, WHITE_FUR, ox)
    rect(draw, 13, hy - 1, 10, 2, WHITE_FUR, ox)
    # Fluffy cheeks
    rect(draw, 8, hy + 5, 3, 4, (248, 245, 240, 255), ox)
    rect(draw, 25, hy + 5, 3, 4, (248, 245, 240, 255), ox)

    # === Ears ===
    # Left ear
    rect(draw, 9, hy - 3, 4, 5, EAR_COLOR, ox)
    rect(draw, 10, hy - 4, 2, 2, EAR_COLOR, ox)
    px1(draw, 10, hy - 1, (230, 200, 180, 255), ox)  # inner ear
    # Right ear
    rect(draw, 23, hy - 3, 4, 5, EAR_COLOR, ox)
    rect(draw, 24, hy - 4, 2, 2, EAR_COLOR, ox)
    px1(draw, 25, hy - 1, (230, 200, 180, 255), ox)

    # === Face ===
    # Eyes
    rect(draw, 14, hy + 4, 3, 3, EYE_BLACK, ox)
    rect(draw, 21, hy + 4, 3, 3, EYE_BLACK, ox)
    # Eye shine
    px1(draw, 15, hy + 4, EYE_SHINE, ox)
    px1(draw, 22, hy + 4, EYE_SHINE, ox)

    # Nose
    rect(draw, 17, hy + 8, 3, 2, NOSE_BLACK, ox)

    # Mouth
    if mouth_open:
        rect(draw, 16, hy + 10, 5, 2, (60, 40, 40, 255), ox)
        rect(draw, 17, hy + 11, 3, 2, TONGUE_PINK, ox)
    else:
        px1(draw, 18, hy + 10, NOSE_BLACK, ox)
        px1(draw, 17, hy + 10, NOSE_BLACK, ox)

    # === Sword (when attacking) ===
    if show_sword:
        sx = 28
        sy = by - 4
        if sword_angle == 0:  # raised
            rect(draw, sx, sy - 10, 2, 12, SWORD_BLADE, ox)
            rect(draw, sx - 1, sy, 4, 2, SWORD_GUARD, ox)
            rect(draw, sx, sy + 2, 2, 3, SWORD_HANDLE, ox)
        elif sword_angle == 1:  # mid swing
            rect(draw, sx, sy - 6, 10, 2, SWORD_BLADE, ox)
            rect(draw, sx - 1, sy - 5, 2, 4, SWORD_GUARD, ox)
            rect(draw, sx - 2, sy - 4, 2, 2, SWORD_HANDLE, ox)
        else:  # down swing
            rect(draw, sx + 2, sy - 2, 2, 12, SWORD_BLADE, ox)
            rect(draw, sx, sy - 2, 4, 2, SWORD_GUARD, ox)
            rect(draw, sx + 1, sy - 4, 2, 3, SWORD_HANDLE, ox)


def generate_bichon():
    """Generate bichon sprite sheet: idle(4) + run(6) + jump(3) + attack(3) = 16 frames."""
    W, H = 36, 40
    total = 16
    img = create_sheet(W, H, total)
    draw = ImageDraw.Draw(img)

    # Idle (4 frames) - gentle breathing
    for i in range(4):
        ox = i * W
        squash = [0, 0, -1, 0][i]
        tail_p = i * 1.5
        draw_bichon_body(draw, ox, body_y_offset=squash, leg_phase=0,
                        tail_phase=tail_p, mouth_open=(i==2))

    # Run (6 frames) - legs pumping
    for i in range(6):
        ox = (4 + i) * W
        leg_p = i * (math.pi * 2 / 6)
        bounce = int(math.sin(leg_p) * 1.5)
        draw_bichon_body(draw, ox, body_y_offset=bounce, leg_phase=leg_p,
                        tail_phase=i * 1.2, mouth_open=(i % 3 == 0))

    # Jump (3 frames) - up, peak, down
    for i in range(3):
        ox = (10 + i) * W
        if i == 0:  # crouching to jump
            draw_bichon_body(draw, ox, body_y_offset=2, leg_phase=0,
                            tail_phase=0, squash=1)
        elif i == 1:  # peak - legs tucked
            draw_bichon_body(draw, ox, body_y_offset=-2, leg_phase=math.pi/2,
                            tail_phase=2, squash=-1)
        else:  # falling
            draw_bichon_body(draw, ox, body_y_offset=0, leg_phase=math.pi,
                            tail_phase=4)

    # Attack (3 frames) - sword swing
    for i in range(3):
        ox = (13 + i) * W
        draw_bichon_body(draw, ox, body_y_offset=0, leg_phase=0,
                        tail_phase=i, show_sword=True, sword_angle=i)

    img.save(os.path.join(OUTPUT_DIR, 'bichon.png'))
    print(f'  bichon.png ({total} frames: idle=0-3, run=4-9, jump=10-12, attack=13-15)')


# ============================================================
# COIN - 16x16, spin animation (8 frames)
# ============================================================

COIN_GOLD = (255, 193, 7, 255)
COIN_LIGHT = (255, 213, 79, 255)
COIN_DARK = (255, 160, 0, 255)
COIN_SHINE = (255, 255, 200, 255)

def generate_coin():
    W, H = 16, 16
    frames = 8
    img = create_sheet(W, H, frames)
    draw = ImageDraw.Draw(img)

    for i in range(frames):
        ox = i * W
        # Simulate 3D rotation by squishing width
        phase = i / frames * math.pi * 2
        width_factor = abs(math.cos(phase))

        cx, cy = 8, 8
        r = 6
        squeeze = max(1, int(r * width_factor))

        # Coin body
        draw.ellipse([ox + cx - squeeze, cy - r, ox + cx + squeeze, cy + r],
                     fill=COIN_GOLD)

        if width_factor > 0.3:
            # Inner ring
            inner_sq = max(1, int((r - 2) * width_factor))
            draw.ellipse([ox + cx - inner_sq, cy - r + 2, ox + cx + inner_sq, cy + r - 2],
                        fill=COIN_LIGHT, outline=COIN_DARK)

            # $ symbol or C
            if width_factor > 0.5:
                # Simple "C" mark
                mark_sq = max(1, int(2 * width_factor))
                rect(draw, cx - mark_sq, cy - 2, mark_sq * 2, 1, COIN_DARK, ox)
                rect(draw, cx - mark_sq, cy - 2, 1, 5, COIN_DARK, ox)
                rect(draw, cx - mark_sq, cy + 2, mark_sq * 2, 1, COIN_DARK, ox)

            # Shine
            shine_x = cx - int(squeeze * 0.4)
            px1(draw, shine_x, cy - 3, COIN_SHINE, ox)
            px1(draw, shine_x, cy - 2, (255, 255, 255, 180), ox)

    img.save(os.path.join(OUTPUT_DIR, 'coin.png'))
    print(f'  coin.png ({frames} frames)')


# ============================================================
# ENEMIES - each 32x32, 4 frames (idle/move)
# ============================================================

ENEMY_SIZE = 32

def draw_slime(draw, ox, frame):
    """Green slime - bouncy."""
    color = (102, 187, 106, 255)
    dark = (76, 175, 80, 255)
    light = (165, 214, 167, 255)

    bounce = [0, -2, -3, -1][frame]
    squish_w = [0, 1, 2, 1][frame]
    squish_h = [0, -1, -2, -1][frame]

    # Body
    by = 18 + bounce
    draw.ellipse([ox + 6 - squish_w, by, ox + 26 + squish_w, by + 14 - squish_h], fill=color)
    # Highlight
    draw.ellipse([ox + 10, by + 1, ox + 16, by + 5], fill=light)
    # Eyes
    rect(draw, 11, by + 4, 2, 3, (26, 26, 26, 255), ox)
    rect(draw, 19, by + 4, 2, 3, (26, 26, 26, 255), ox)
    px1(draw, 11, by + 4, EYE_SHINE, ox)
    px1(draw, 19, by + 4, EYE_SHINE, ox)

def draw_mushroom(draw, ox, frame):
    """Red mushroom."""
    cap = (229, 57, 53, 255)
    stem = (245, 230, 208, 255)
    spots = (255, 255, 255, 255)
    sway = [0, 0, 1, 0][frame]

    # Stem
    rect(draw, 13 + sway, 18, 6, 12, stem, ox)
    # Cap
    draw.ellipse([ox + 5 + sway, 6, ox + 27 + sway, 20], fill=cap)
    # Spots
    circle_pixels(draw, 12 + sway, 11, 2, spots, ox)
    circle_pixels(draw, 20 + sway, 9, 1, spots, ox)
    circle_pixels(draw, 16 + sway, 14, 1, spots, ox)
    # Eyes
    rect(draw, 12 + sway, 16, 2, 2, EYE_BLACK, ox)
    rect(draw, 18 + sway, 16, 2, 2, EYE_BLACK, ox)

def draw_bird(draw, ox, frame):
    """Blue bird."""
    body = (66, 165, 245, 255)
    wing = (33, 150, 243, 255)
    beak = (255, 152, 0, 255)
    wing_up = [-4, -2, 0, -3][frame]

    # Body
    draw.ellipse([ox + 8, 12, ox + 26, 24], fill=body)
    # Wing
    wing_y = 12 + wing_up
    draw.polygon([(ox + 10, 16), (ox + 4, wing_y), (ox + 14, 14)], fill=wing)
    # Beak
    draw.polygon([(ox + 24, 16), (ox + 30, 18), (ox + 24, 19)], fill=beak)
    # Eye
    rect(draw, 21, 15, 2, 2, EYE_BLACK, ox)
    px1(draw, 21, 15, EYE_SHINE, ox)
    # Tail
    rect(draw, 6, 16, 3, 2, wing, ox)

def draw_butterfly(draw, ox, frame):
    """Purple butterfly."""
    color = (186, 104, 200, 255)
    body_c = (74, 74, 74, 255)
    wing_scale = [1.0, 0.7, 0.4, 0.7][frame]

    cx, cy = 16, 16
    ws = int(6 * wing_scale)
    # Wings
    draw.ellipse([ox + cx - ws - 6, cy - 6, ox + cx - 6, cy + 6], fill=color)
    draw.ellipse([ox + cx + 6, cy - 6, ox + cx + ws + 6, cy + 6], fill=color)
    # Body
    rect(draw, 15, 10, 2, 14, body_c, ox)
    # Antennae
    px1(draw, 13, 8, body_c, ox)
    px1(draw, 12, 7, body_c, ox)
    px1(draw, 19, 8, body_c, ox)
    px1(draw, 20, 7, body_c, ox)

def draw_goblin(draw, ox, frame):
    """Green goblin."""
    skin = (56, 142, 60, 255)
    dark = (46, 125, 50, 255)
    sway = [-1, 0, 1, 0][frame]

    # Body
    draw.ellipse([ox + 9 + sway, 16, ox + 23 + sway, 30], fill=skin)
    # Head
    circle_pixels(draw, 16 + sway, 12, 6, skin, ox)
    # Pointy ears
    draw.polygon([(ox + 8 + sway, 10), (ox + 4 + sway, 4), (ox + 11 + sway, 8)], fill=dark)
    draw.polygon([(ox + 24 + sway, 10), (ox + 28 + sway, 4), (ox + 21 + sway, 8)], fill=dark)
    # Red eyes
    rect(draw, 13 + sway, 10, 2, 2, (255, 0, 0, 255), ox)
    rect(draw, 19 + sway, 10, 2, 2, (255, 0, 0, 255), ox)
    # Teeth
    px1(draw, 14 + sway, 15, (255, 255, 255, 255), ox)
    px1(draw, 18 + sway, 15, (255, 255, 255, 255), ox)

def draw_spider(draw, ox, frame):
    """Dark spider."""
    body_c = (66, 66, 66, 255)
    leg_c = (90, 90, 90, 255)

    # Body
    draw.ellipse([ox + 10, 12, ox + 22, 22], fill=body_c)
    # Abdomen
    draw.ellipse([ox + 8, 18, ox + 24, 28], fill=body_c)
    # Legs (4 pairs)
    leg_anim = [0, 1, 0, -1][frame]
    for i in range(4):
        ly = 14 + i * 3
        la = leg_anim if i % 2 == 0 else -leg_anim
        # Left
        draw.line([(ox + 12, ly), (ox + 4, ly + 4 + la)], fill=leg_c, width=1)
        # Right
        draw.line([(ox + 20, ly), (ox + 28, ly + 4 - la)], fill=leg_c, width=1)
    # Eyes (red dots)
    for i in range(4):
        px1(draw, 13 + i * 2, 13, (255, 0, 0, 255), ox)

def draw_bat(draw, ox, frame):
    """Purple bat."""
    body_c = (94, 53, 177, 255)
    wing_c = (69, 39, 160, 255)
    wing_up = [-5, -2, 1, -3][frame]

    # Body
    draw.ellipse([ox + 12, 12, ox + 20, 24], fill=body_c)
    # Wings
    wy = 14 + wing_up
    draw.polygon([(ox + 12, 16), (ox + 2, wy), (ox + 8, 20)], fill=wing_c)
    draw.polygon([(ox + 20, 16), (ox + 30, wy), (ox + 24, 20)], fill=wing_c)
    # Ears
    draw.polygon([(ox + 13, 12), (ox + 12, 6), (ox + 15, 10)], fill=body_c)
    draw.polygon([(ox + 19, 12), (ox + 20, 6), (ox + 17, 10)], fill=body_c)
    # Eyes
    rect(draw, 13, 15, 2, 2, (255, 82, 82, 255), ox)
    rect(draw, 18, 15, 2, 2, (255, 82, 82, 255), ox)

def draw_fairy(draw, ox, frame):
    """Glowing fairy."""
    glow = (178, 255, 89, 255)
    body_c = (200, 230, 120, 255)
    wing_c = (220, 255, 150, 128)
    pulse = [3, 4, 5, 4][frame]
    wing_s = [1.0, 0.8, 0.6, 0.8][frame]

    # Glow aura
    circle_pixels(draw, 16, 16, pulse + 4, (200, 255, 100, 40), ox)
    circle_pixels(draw, 16, 16, pulse + 2, (200, 255, 100, 60), ox)
    # Body
    circle_pixels(draw, 16, 16, 4, body_c, ox)
    # Wings
    ws = int(5 * wing_s)
    draw.ellipse([ox + 16 - ws - 6, 10, ox + 10, 22], fill=wing_c)
    draw.ellipse([ox + 22, 10, ox + 16 + ws + 6, 22], fill=wing_c)
    # Eyes
    px1(draw, 14, 15, EYE_BLACK, ox)
    px1(draw, 18, 15, EYE_BLACK, ox)

def draw_scorpion(draw, ox, frame):
    """Orange scorpion."""
    body_c = (230, 150, 50, 255)
    dark = (200, 120, 30, 255)
    tail_pos = [0, -1, -2, -1][frame]

    # Body
    draw.ellipse([ox + 8, 18, ox + 24, 28], fill=body_c)
    # Head
    draw.ellipse([ox + 18, 16, ox + 28, 24], fill=body_c)
    # Tail
    draw.line([(ox + 8, 22), (ox + 4, 14 + tail_pos), (ox + 6, 8 + tail_pos)], fill=dark, width=2)
    # Stinger
    circle_pixels(draw, 6, 7 + tail_pos, 2, (255, 0, 0, 255), ox)
    # Claws
    draw.line([(ox + 26, 18), (ox + 30, 14)], fill=dark, width=2)
    draw.line([(ox + 30, 14), (ox + 28, 11)], fill=dark, width=1)
    # Eye
    px1(draw, 24, 18, EYE_BLACK, ox)

def draw_mummy(draw, ox, frame):
    """Beige mummy."""
    wrap = (222, 210, 180, 255)
    band = (200, 190, 160, 255)
    sway = [-1, 0, 1, 0][frame]

    # Body
    rect(draw, 11 + sway, 14, 10, 16, wrap, ox)
    # Head
    circle_pixels(draw, 16 + sway, 10, 5, wrap, ox)
    # Bandage lines
    for i in range(5):
        y = 12 + i * 4
        rect(draw, 10 + sway, y, 12, 1, band, ox)
    # Green eyes
    rect(draw, 13 + sway, 8, 2, 2, (0, 230, 118, 255), ox)
    rect(draw, 18 + sway, 8, 2, 2, (0, 230, 118, 255), ox)

def draw_eagle(draw, ox, frame):
    """Brown eagle."""
    body_c = (141, 110, 99, 255)
    wing_c = (121, 85, 72, 255)
    beak = (255, 152, 0, 255)
    wing_up = [-5, -2, 1, -4][frame]

    # Body
    draw.ellipse([ox + 10, 14, ox + 22, 24], fill=body_c)
    # Wings (wide)
    wy = 14 + wing_up
    draw.polygon([(ox + 10, 18), (ox + 0, wy), (ox + 8, 22)], fill=wing_c)
    draw.polygon([(ox + 22, 18), (ox + 32, wy), (ox + 24, 22)], fill=wing_c)
    # Beak
    draw.polygon([(ox + 22, 17), (ox + 28, 19), (ox + 22, 20)], fill=beak)
    # Eye
    rect(draw, 19, 16, 2, 2, EYE_BLACK, ox)
    # White head
    circle_pixels(draw, 19, 15, 3, (240, 230, 220, 255), ox)
    rect(draw, 19, 16, 2, 2, EYE_BLACK, ox)

def draw_spirit(draw, ox, frame, color, inner_color):
    """Generic spirit (sand/ice)."""
    pulse = [4, 5, 6, 5][frame]

    # Aura
    circle_pixels(draw, 16, 16, pulse + 3, (*color[:3], 50), ox)
    circle_pixels(draw, 16, 16, pulse + 1, (*color[:3], 80), ox)
    # Core
    circle_pixels(draw, 16, 16, pulse, color, ox)
    # Inner
    circle_pixels(draw, 16, 14, 3, inner_color, ox)
    # Eyes
    px1(draw, 14, 15, EYE_BLACK, ox)
    px1(draw, 18, 15, EYE_BLACK, ox)

def draw_sand_spirit(draw, ox, frame):
    draw_spirit(draw, ox, frame, (255, 183, 77, 255), (255, 213, 79, 255))

def draw_ice_spirit(draw, ox, frame):
    draw_spirit(draw, ox, frame, (129, 212, 250, 255), (179, 229, 252, 255))

def draw_snow_golem(draw, ox, frame):
    """White snow golem."""
    body_c = (224, 247, 250, 255)
    ice = (129, 212, 250, 255)
    shake = [0, 1, 0, -1][frame]

    # Body (big)
    draw.ellipse([ox + 6 + shake, 14, ox + 26 + shake, 30], fill=body_c)
    # Head
    circle_pixels(draw, 16 + shake, 10, 6, body_c, ox)
    # Ice crystals
    circle_pixels(draw, 12 + shake, 4, 2, ice, ox)
    circle_pixels(draw, 20 + shake, 5, 2, ice, ox)
    # Eyes
    rect(draw, 13 + shake, 8, 2, 2, (66, 165, 245, 255), ox)
    rect(draw, 19 + shake, 8, 2, 2, (66, 165, 245, 255), ox)

def draw_wolf(draw, ox, frame):
    """Gray wolf."""
    body_c = (120, 130, 140, 255)
    light = (170, 180, 190, 255)
    run = [0, 1, 0, -1][frame]

    # Body
    draw.ellipse([ox + 6, 16, ox + 26, 26], fill=body_c)
    # Head
    draw.ellipse([ox + 18, 10, ox + 30, 22], fill=body_c)
    # Muzzle
    draw.ellipse([ox + 24, 14, ox + 32, 20], fill=light)
    # Ears
    draw.polygon([(ox + 20, 10), (ox + 19, 4), (ox + 23, 8)], fill=body_c)
    draw.polygon([(ox + 26, 10), (ox + 28, 4), (ox + 24, 8)], fill=body_c)
    # Eye
    rect(draw, 24, 13, 2, 2, (255, 235, 59, 255), ox)
    px1(draw, 24, 13, EYE_BLACK, ox)
    # Legs
    rect(draw, 10, 24, 3, 6 + run, body_c, ox)
    rect(draw, 19, 24, 3, 6 - run, body_c, ox)
    # Nose
    px1(draw, 30, 16, EYE_BLACK, ox)

def draw_owl(draw, ox, frame):
    """Brown owl."""
    body_c = (141, 110, 99, 255)
    belly = (215, 204, 200, 255)
    blink = (frame == 3)

    # Body
    draw.ellipse([ox + 8, 14, ox + 24, 30], fill=body_c)
    # Belly
    draw.ellipse([ox + 10, 18, ox + 22, 28], fill=belly)
    # Head
    circle_pixels(draw, 16, 10, 6, body_c, ox)
    # Ear tufts
    draw.polygon([(ox + 9, 6), (ox + 7, 0), (ox + 13, 4)], fill=body_c)
    draw.polygon([(ox + 19, 4), (ox + 25, 0), (ox + 23, 6)], fill=body_c)
    # Eyes
    if blink:
        rect(draw, 11, 9, 4, 1, EYE_BLACK, ox)
        rect(draw, 19, 9, 4, 1, EYE_BLACK, ox)
    else:
        draw.ellipse([ox + 11, 7, ox + 15, 12], fill=(255, 214, 0, 255))
        draw.ellipse([ox + 19, 7, ox + 23, 12], fill=(255, 214, 0, 255))
        circle_pixels(draw, 13, 9, 1, EYE_BLACK, ox)
        circle_pixels(draw, 21, 9, 1, EYE_BLACK, ox)
    # Beak
    draw.polygon([(ox + 15, 12), (ox + 16, 14), (ox + 17, 12)], fill=(255, 179, 0, 255))

def draw_fire_imp(draw, ox, frame):
    """Red imp."""
    body_c = (211, 47, 47, 255)
    dark = (183, 28, 28, 255)
    hop = [0, -2, -3, -1][frame]

    # Body
    draw.ellipse([ox + 9, 16 + hop, ox + 23, 28 + hop], fill=body_c)
    # Head
    circle_pixels(draw, 16, 11 + hop, 5, body_c, ox)
    # Horns
    draw.line([(ox + 12, 6 + hop), (ox + 10, 1 + hop)], fill=dark, width=2)
    draw.line([(ox + 20, 6 + hop), (ox + 22, 1 + hop)], fill=dark, width=2)
    # Glow
    circle_pixels(draw, 16, 20 + hop, 3, (255, 152, 0, 80), ox)
    # Yellow eyes
    rect(draw, 13, 10 + hop, 2, 2, (255, 214, 0, 255), ox)
    rect(draw, 19, 10 + hop, 2, 2, (255, 214, 0, 255), ox)

def draw_dragonkin(draw, ox, frame):
    """Dark red dragonkin."""
    body_c = (183, 28, 28, 255)
    horn = (255, 152, 0, 255)
    breathe = [0, 0, 1, 0][frame]

    # Body
    draw.ellipse([ox + 6, 16 + breathe, ox + 24, 28 + breathe], fill=body_c)
    # Head
    draw.ellipse([ox + 14, 6, ox + 28, 18], fill=body_c)
    # Horns
    draw.polygon([(ox + 17, 6), (ox + 15, 0), (ox + 19, 4)], fill=horn)
    draw.polygon([(ox + 23, 6), (ox + 26, 0), (ox + 25, 4)], fill=horn)
    # Tail
    draw.line([(ox + 6, 22 + breathe), (ox + 2, 18), (ox + 3, 14)], fill=body_c, width=2)
    # Eye
    rect(draw, 22, 10, 2, 2, (255, 214, 0, 255), ox)

def draw_fire_bat(draw, ox, frame):
    """Orange fire bat."""
    body_c = (255, 111, 0, 255)
    wing_c = (230, 81, 0, 255)
    wing_up = [-5, -2, 1, -3][frame]

    draw.ellipse([ox + 12, 12, ox + 20, 24], fill=body_c)
    wy = 14 + wing_up
    draw.polygon([(ox + 12, 16), (ox + 2, wy), (ox + 8, 20)], fill=wing_c)
    draw.polygon([(ox + 20, 16), (ox + 30, wy), (ox + 24, 20)], fill=wing_c)
    draw.polygon([(ox + 13, 12), (ox + 12, 6), (ox + 15, 10)], fill=body_c)
    draw.polygon([(ox + 19, 12), (ox + 20, 6), (ox + 17, 10)], fill=body_c)
    rect(draw, 13, 15, 2, 2, (255, 214, 0, 255), ox)
    rect(draw, 18, 15, 2, 2, (255, 214, 0, 255), ox)

def draw_phoenix_enemy(draw, ox, frame):
    """Golden phoenix."""
    body_c = (255, 111, 0, 255)
    wing_c = (255, 160, 0, 255)
    flame = (255, 235, 59, 255)
    wing_up = [-4, -1, 2, -3][frame]

    # Fire aura
    circle_pixels(draw, 16, 16, 10, (255, 111, 0, 30), ox)
    # Body
    draw.ellipse([ox + 10, 12, ox + 22, 24], fill=body_c)
    # Wings
    wy = 14 + wing_up
    draw.polygon([(ox + 10, 16), (ox + 2, wy), (ox + 8, 20)], fill=wing_c)
    draw.polygon([(ox + 22, 16), (ox + 30, wy), (ox + 24, 20)], fill=wing_c)
    # Head crest
    circle_pixels(draw, 18, 10, 3, body_c, ox)
    draw.polygon([(ox + 16, 6), (ox + 18, 2), (ox + 20, 6)], fill=flame)
    # Eye
    px1(draw, 20, 10, EYE_BLACK, ox)
    # Tail flames
    for i in range(3):
        flicker = [1, -1, 0, 1][frame]
        draw.ellipse([ox + 8 - i*2 + flicker, 22 + i*2, ox + 12 - i*2 + flicker, 25 + i*2], fill=flame)


ENEMY_RENDERERS = {
    'slime': draw_slime, 'mushroom': draw_mushroom, 'bird': draw_bird, 'butterfly': draw_butterfly,
    'goblin': draw_goblin, 'spider': draw_spider, 'bat': draw_bat, 'fairy': draw_fairy,
    'scorpion': draw_scorpion, 'mummy': draw_mummy, 'eagle': draw_eagle, 'sand_spirit': draw_sand_spirit,
    'snow_golem': draw_snow_golem, 'wolf': draw_wolf, 'snow_owl': draw_owl, 'ice_spirit': draw_ice_spirit,
    'fire_imp': draw_fire_imp, 'dragonkin': draw_dragonkin, 'fire_bat': draw_fire_bat, 'phoenix': draw_phoenix_enemy,
}

def generate_enemies():
    W, H = ENEMY_SIZE, ENEMY_SIZE
    frames = 4
    for name, renderer in ENEMY_RENDERERS.items():
        img = create_sheet(W, H, frames)
        draw = ImageDraw.Draw(img)
        for i in range(frames):
            renderer(draw, i * W, i)
        img.save(os.path.join(OUTPUT_DIR, f'enemy_{name}.png'))
        print(f'  enemy_{name}.png ({frames} frames)')


# ============================================================
# BOSSES - 64x64, 4 frames
# ============================================================

BOSS_SIZE = 64

def draw_king_slime(draw, ox, frame):
    """Meadow boss: King Slime."""
    color = (102, 187, 106, 255)
    light = (165, 214, 167, 255)
    crown = (255, 214, 0, 255)

    squish = [0, 2, 3, 1][frame]
    bounce = [0, -1, -2, -1][frame]
    cx, cy = 32, 34 + bounce

    # Shadow
    draw.ellipse([ox + 14, 56, ox + 50, 62], fill=(0, 0, 0, 40))
    # Body
    draw.ellipse([ox + 10 - squish, cy - 8, ox + 54 + squish, cy + 14 + squish], fill=color)
    # Shine
    draw.ellipse([ox + 18, cy - 6, ox + 28, cy], fill=light)
    # Crown
    crown_y = cy - 14
    draw.polygon([
        (ox + 18, crown_y + 6), (ox + 20, crown_y), (ox + 25, crown_y + 4),
        (ox + 32, crown_y - 2), (ox + 39, crown_y + 4), (ox + 44, crown_y),
        (ox + 46, crown_y + 6)
    ], fill=crown)
    # Crown gems
    circle_pixels(draw, 25, crown_y + 2, 1, (255, 0, 0, 255), ox)
    circle_pixels(draw, 32, crown_y, 1, (0, 100, 255, 255), ox)
    circle_pixels(draw, 39, crown_y + 2, 1, (255, 0, 0, 255), ox)
    # Eyes
    draw.ellipse([ox + 22, cy - 2, ox + 30, cy + 4], fill=(255, 255, 255, 255))
    draw.ellipse([ox + 34, cy - 2, ox + 42, cy + 4], fill=(255, 255, 255, 255))
    circle_pixels(draw, 27, cy + 1, 2, (27, 94, 32, 255), ox)
    circle_pixels(draw, 39, cy + 1, 2, (27, 94, 32, 255), ox)
    # Angry brows
    draw.line([(ox + 20, cy - 4), (ox + 30, cy - 2)], fill=(46, 125, 50, 255), width=2)
    draw.line([(ox + 34, cy - 2), (ox + 44, cy - 4)], fill=(46, 125, 50, 255), width=2)
    # Mouth
    draw.arc([ox + 26, cy + 4, ox + 38, cy + 10], 0, 180, fill=(27, 94, 32, 255), width=2)

def draw_treant(draw, ox, frame):
    """Forest boss: Treant."""
    trunk = (109, 76, 65, 255)
    dark = (93, 64, 55, 255)
    leaf = (56, 142, 60, 255)
    sway = [0, 1, 2, 1][frame]

    # Roots
    for i in range(-2, 3):
        draw.line([(ox + 32 + i * 8, 50), (ox + 32 + i * 10 + sway, 62)], fill=dark, width=2)
    # Trunk
    rect(draw, 22 + sway, 20, 20, 34, trunk, ox)
    # Bark texture
    for i in range(4):
        rect(draw, 24 + sway, 24 + i * 8, 16, 1, dark, ox)
    # Branches
    draw.line([(ox + 22 + sway, 26), (ox + 10 + sway, 16)], fill=dark, width=3)
    draw.line([(ox + 42 + sway, 26), (ox + 54 + sway, 18)], fill=dark, width=3)
    # Leaf crown
    circle_pixels(draw, 32 + sway, 14, 12, leaf, ox)
    circle_pixels(draw, 22 + sway, 18, 8, leaf, ox)
    circle_pixels(draw, 42 + sway, 18, 8, leaf, ox)
    # Face
    draw.ellipse([ox + 26 + sway, 30, ox + 32 + sway, 38], fill=(255, 214, 0, 255))
    draw.ellipse([ox + 36 + sway, 30, ox + 42 + sway, 38], fill=(255, 214, 0, 255))
    circle_pixels(draw, 29 + sway, 35, 1, EYE_BLACK, ox)
    circle_pixels(draw, 39 + sway, 35, 1, EYE_BLACK, ox)
    draw.ellipse([ox + 30 + sway, 40, ox + 38 + sway, 46], fill=(62, 39, 35, 255))

def draw_sphinx(draw, ox, frame):
    """Desert boss: Sphinx."""
    body_c = (212, 165, 116, 255)
    head_c = (222, 184, 135, 255)
    gold = (255, 214, 0, 255)
    breathe = [0, 0, 1, 0][frame]

    # Body
    draw.ellipse([ox + 8, 30 + breathe, ox + 56, 50 + breathe], fill=body_c)
    # Head
    draw.ellipse([ox + 16, 10 + breathe, ox + 48, 36 + breathe], fill=head_c)
    # Headdress
    draw.polygon([
        (ox + 16, 20 + breathe), (ox + 14, 6 + breathe), (ox + 32, 2 + breathe),
        (ox + 50, 6 + breathe), (ox + 48, 20 + breathe)
    ], fill=gold)
    # Blue stripes
    draw.line([(ox + 20, 6 + breathe), (ox + 18, 20 + breathe)], fill=(21, 101, 192, 255), width=1)
    draw.line([(ox + 44, 6 + breathe), (ox + 46, 20 + breathe)], fill=(21, 101, 192, 255), width=1)
    # Eyes
    draw.ellipse([ox + 24, 18 + breathe, ox + 30, 24 + breathe], fill=(0, 188, 212, 255))
    draw.ellipse([ox + 34, 18 + breathe, ox + 40, 24 + breathe], fill=(0, 188, 212, 255))
    # Eyeliner
    draw.line([(ox + 22, 21 + breathe), (ox + 30, 21 + breathe)], fill=EYE_BLACK, width=1)
    draw.line([(ox + 34, 21 + breathe), (ox + 42, 21 + breathe)], fill=EYE_BLACK, width=1)
    # Paws
    draw.ellipse([ox + 12, 48 + breathe, ox + 24, 54 + breathe], fill=body_c)
    draw.ellipse([ox + 40, 48 + breathe, ox + 52, 54 + breathe], fill=body_c)

def draw_ice_serpent(draw, ox, frame):
    """Snowfield boss: Ice Serpent."""
    body_c = (179, 229, 252, 255)
    dark_c = (79, 195, 247, 255)
    head_c = (225, 245, 254, 255)
    horn_c = (129, 212, 250, 255)

    # Body segments (serpentine)
    import math as m
    for i in range(5):
        seg_x = 32 + int(m.sin(frame * 0.8 + i * 0.8) * 8)
        seg_y = 52 - i * 8
        seg_r = 8 - i
        c = body_c if i % 2 == 0 else dark_c
        circle_pixels(draw, seg_x, seg_y, seg_r, c, ox)

    # Head
    head_x = 32 + int(m.sin(frame * 0.8) * 8)
    draw.ellipse([ox + head_x - 10, 8, ox + head_x + 10, 24], fill=head_c)
    # Horns
    draw.polygon([(ox + head_x - 5, 8), (ox + head_x - 8, 0), (ox + head_x - 2, 6)], fill=horn_c)
    draw.polygon([(ox + head_x + 2, 6), (ox + head_x + 8, 0), (ox + head_x + 5, 8)], fill=horn_c)
    # Eyes
    circle_pixels(draw, head_x - 4, 14, 2, (2, 136, 209, 255), ox)
    circle_pixels(draw, head_x + 4, 14, 2, (2, 136, 209, 255), ox)
    px1(draw, head_x - 4, 13, (255, 255, 255, 255), ox)
    px1(draw, head_x + 4, 13, (255, 255, 255, 255), ox)
    # Ice particles
    for i in range(4):
        px = 32 + int(m.cos(frame * 0.5 + i * 1.5) * 20)
        py = 30 + int(m.sin(frame * 0.4 + i * 2) * 15)
        circle_pixels(draw, px, py, 1, (225, 245, 254, 128), ox)

def draw_dragon_boss(draw, ox, frame):
    """Volcano boss: Fire Dragon."""
    body_c = (211, 47, 47, 255)
    belly = (255, 138, 101, 255)
    wing_c = (191, 54, 12, 255)
    horn = (78, 52, 46, 255)
    hover = [0, -1, -2, -1][frame]
    wing_f = [-3, 0, 3, 1][frame]

    # Fire aura
    circle_pixels(draw, 32, 34 + hover, 24, (255, 111, 0, 25), ox)
    # Wings
    wy = 20 + hover + wing_f
    draw.polygon([(ox + 20, 26 + hover), (ox + 4, wy), (ox + 14, 36 + hover)], fill=wing_c)
    draw.polygon([(ox + 44, 26 + hover), (ox + 60, wy), (ox + 50, 36 + hover)], fill=wing_c)
    # Body
    draw.ellipse([ox + 16, 28 + hover, ox + 48, 48 + hover], fill=body_c)
    # Belly
    draw.ellipse([ox + 22, 32 + hover, ox + 42, 46 + hover], fill=belly)
    # Head
    draw.ellipse([ox + 18, 12 + hover, ox + 46, 32 + hover], fill=body_c)
    # Horns
    draw.polygon([(ox + 24, 12 + hover), (ox + 20, 2 + hover), (ox + 28, 10 + hover)], fill=horn)
    draw.polygon([(ox + 36, 10 + hover), (ox + 44, 2 + hover), (ox + 40, 12 + hover)], fill=horn)
    # Eyes
    draw.ellipse([ox + 24, 18 + hover, ox + 30, 24 + hover], fill=(255, 214, 0, 255))
    draw.ellipse([ox + 34, 18 + hover, ox + 40, 24 + hover], fill=(255, 214, 0, 255))
    rect(draw, 27, 19 + hover, 1, 4, EYE_BLACK, ox)
    rect(draw, 37, 19 + hover, 1, 4, EYE_BLACK, ox)
    # Fire breath (intermittent)
    if frame in [0, 1]:
        draw.ellipse([ox + 46, 20 + hover, ox + 58, 26 + hover], fill=(255, 152, 0, 180))
        draw.ellipse([ox + 52, 21 + hover, ox + 62, 25 + hover], fill=(255, 235, 59, 140))
    # Tail
    draw.line([(ox + 16, 44 + hover), (ox + 8, 50 + hover)], fill=body_c, width=3)
    circle_pixels(draw, 8, 50 + hover, 2, (255, 152, 0, 255), ox)

BOSS_RENDERERS = {
    'meadow': draw_king_slime,
    'forest': draw_treant,
    'desert': draw_sphinx,
    'snowfield': draw_ice_serpent,
    'volcano': draw_dragon_boss,
}

def generate_bosses():
    W, H = BOSS_SIZE, BOSS_SIZE
    frames = 4
    for name, renderer in BOSS_RENDERERS.items():
        img = create_sheet(W, H, frames)
        draw = ImageDraw.Draw(img)
        for i in range(frames):
            renderer(draw, i * W, i)
        img.save(os.path.join(OUTPUT_DIR, f'boss_{name}.png'))
        print(f'  boss_{name}.png ({frames} frames)')


# ============================================================
# COMPANIONS - 20x20, 4 frames
# ============================================================

COMP_SIZE = 20

def draw_comp_cat(draw, ox, frame):
    color = (255, 152, 0, 255)
    bounce = [0, -1, -2, -1][frame]
    draw.ellipse([ox + 4, 8 + bounce, ox + 16, 16 + bounce], fill=color)
    circle_pixels(draw, 10, 6 + bounce, 3, color, ox)
    draw.polygon([(ox + 5, 4 + bounce), (ox + 4, 0 + bounce), (ox + 8, 3 + bounce)], fill=color)
    draw.polygon([(ox + 12, 3 + bounce), (ox + 16, 0 + bounce), (ox + 15, 4 + bounce)], fill=color)
    px1(draw, 8, 5 + bounce, EYE_BLACK, ox)
    px1(draw, 12, 5 + bounce, EYE_BLACK, ox)
    draw.arc([ox + 14, 10 + bounce, ox + 18, 16 + bounce], 0, 180, fill=color, width=1)

def draw_comp_hamster(draw, ox, frame):
    color = (255, 204, 128, 255)
    cheek = (255, 224, 178, 255)
    bounce = [0, -1, 0, 1][frame]
    draw.ellipse([ox + 4, 6 + bounce, ox + 16, 16 + bounce], fill=color)
    circle_pixels(draw, 7, 10 + bounce, 2, cheek, ox)
    circle_pixels(draw, 13, 10 + bounce, 2, cheek, ox)
    circle_pixels(draw, 7, 3 + bounce, 2, color, ox)
    circle_pixels(draw, 13, 3 + bounce, 2, color, ox)
    px1(draw, 8, 8 + bounce, EYE_BLACK, ox)
    px1(draw, 12, 8 + bounce, EYE_BLACK, ox)
    px1(draw, 10, 10 + bounce, (255, 138, 101, 255), ox)

def draw_comp_rabbit(draw, ox, frame):
    color = (245, 245, 245, 255)
    ear_inner = (255, 205, 210, 255)
    bounce = [0, -1, -2, -1][frame]
    draw.ellipse([ox + 5, 8 + bounce, ox + 15, 16 + bounce], fill=color)
    circle_pixels(draw, 10, 6 + bounce, 3, color, ox)
    rect(draw, 8, -2 + bounce, 2, 8, color, ox)
    rect(draw, 12, -2 + bounce, 2, 8, color, ox)
    px1(draw, 8, 0 + bounce, ear_inner, ox)
    px1(draw, 12, 0 + bounce, ear_inner, ox)
    px1(draw, 8, 5 + bounce, (229, 57, 53, 255), ox)
    px1(draw, 12, 5 + bounce, (229, 57, 53, 255), ox)

def draw_comp_owl(draw, ox, frame):
    body = (141, 110, 99, 255)
    belly = (215, 204, 200, 255)
    blink = (frame == 3)
    draw.ellipse([ox + 4, 8, ox + 16, 18], fill=body)
    draw.ellipse([ox + 6, 10, ox + 14, 16], fill=belly)
    circle_pixels(draw, 10, 6, 4, body, ox)
    draw.polygon([(ox + 5, 4), (ox + 3, 0), (ox + 8, 3)], fill=body)
    draw.polygon([(ox + 12, 3), (ox + 17, 0), (ox + 15, 4)], fill=body)
    if blink:
        rect(draw, 7, 5, 2, 1, EYE_BLACK, ox)
        rect(draw, 12, 5, 2, 1, EYE_BLACK, ox)
    else:
        circle_pixels(draw, 8, 5, 1, (255, 214, 0, 255), ox)
        circle_pixels(draw, 12, 5, 1, (255, 214, 0, 255), ox)
    draw.polygon([(ox + 9, 7), (ox + 10, 9), (ox + 11, 7)], fill=(255, 179, 0, 255))

def draw_comp_fox(draw, ox, frame):
    color = (255, 87, 34, 255)
    white = (255, 204, 188, 255)
    bounce = [0, -1, 0, 1][frame]
    draw.ellipse([ox + 3, 8 + bounce, ox + 16, 16 + bounce], fill=color)
    draw.ellipse([ox + 6, 4 + bounce, ox + 16, 12 + bounce], fill=color)
    draw.polygon([(ox + 6, 4 + bounce), (ox + 4, 0 + bounce), (ox + 9, 3 + bounce)], fill=color)
    draw.polygon([(ox + 12, 3 + bounce), (ox + 16, 0 + bounce), (ox + 14, 4 + bounce)], fill=color)
    draw.ellipse([ox + 7, 10 + bounce, ox + 13, 15 + bounce], fill=white)
    px1(draw, 9, 6 + bounce, EYE_BLACK, ox)
    px1(draw, 13, 6 + bounce, EYE_BLACK, ox)
    circle_pixels(draw, 2, 12 + bounce, 2, color, ox)
    px1(draw, 0, 12 + bounce, (255, 255, 255, 255), ox)

def draw_comp_penguin(draw, ox, frame):
    body = (38, 50, 56, 255)
    belly = (236, 239, 241, 255)
    beak = (255, 152, 0, 255)
    waddle = [-1, 0, 1, 0][frame]
    draw.ellipse([ox + 5 + waddle, 6, ox + 15 + waddle, 18], fill=body)
    draw.ellipse([ox + 7 + waddle, 8, ox + 13 + waddle, 16], fill=belly)
    circle_pixels(draw, 10 + waddle, 4, 3, body, ox)
    px1(draw, 8 + waddle, 3, (255, 255, 255, 255), ox)
    px1(draw, 12 + waddle, 3, (255, 255, 255, 255), ox)
    draw.polygon([(ox + 9 + waddle, 5), (ox + 10 + waddle, 7), (ox + 11 + waddle, 5)], fill=beak)

def draw_comp_wolf(draw, ox, frame):
    body = (84, 110, 122, 255)
    light = (176, 190, 197, 255)
    breathe = [0, 0, 1, 0][frame]
    draw.ellipse([ox + 3, 8 + breathe, ox + 16, 16 + breathe], fill=body)
    draw.ellipse([ox + 8, 3 + breathe, ox + 18, 12 + breathe], fill=body)
    draw.ellipse([ox + 12, 6 + breathe, ox + 18, 10 + breathe], fill=light)
    draw.polygon([(ox + 9, 3 + breathe), (ox + 8, 0 + breathe), (ox + 12, 2 + breathe)], fill=body)
    draw.polygon([(ox + 14, 2 + breathe), (ox + 16, 0 + breathe), (ox + 15, 3 + breathe)], fill=body)
    px1(draw, 11, 6 + breathe, (255, 235, 59, 255), ox)
    px1(draw, 15, 6 + breathe, (255, 235, 59, 255), ox)

def draw_comp_unicorn(draw, ox, frame):
    body = (243, 229, 245, 255)
    mane = (206, 147, 216, 255)
    float_ = [0, -1, -2, -1][frame]
    import math as m
    horn_hue = frame * 90
    from colorsys import hsv_to_rgb
    r, g, b = hsv_to_rgb(horn_hue / 360, 0.6, 1.0)
    horn_color = (int(r*255), int(g*255), int(b*255), 255)
    # Sparkles
    for i in range(2):
        sx = 10 + int(m.cos(frame + i * 2) * 6)
        sy = 10 + int(m.sin(frame + i * 1.7) * 5) + float_
        px1(draw, sx, sy, (255, 255, 255, 200), ox)
    draw.ellipse([ox + 4, 8 + float_, ox + 16, 16 + float_], fill=body)
    circle_pixels(draw, 10, 5 + float_, 3, body, ox)
    draw.polygon([(ox + 9, 2 + float_), (ox + 10, -2 + float_), (ox + 11, 2 + float_)], fill=horn_color)
    for i in range(2):
        circle_pixels(draw, 8 + i * 2, 8 + i + float_, 1, mane, ox)
    px1(draw, 9, 4 + float_, (123, 31, 162, 255), ox)
    rect(draw, 7, 14 + float_, 1, 3, body, ox)
    rect(draw, 13, 14 + float_, 1, 3, body, ox)

def draw_comp_dragon(draw, ox, frame):
    body = (211, 47, 47, 255)
    wing = (239, 83, 80, 180)
    horn = (255, 205, 210, 255)
    hover = [0, -1, -2, -1][frame]
    draw.polygon([(ox + 6, 8 + hover), (ox + 2, 4 + hover), (ox + 4, 10 + hover)], fill=wing)
    draw.polygon([(ox + 14, 8 + hover), (ox + 18, 4 + hover), (ox + 16, 10 + hover)], fill=wing)
    draw.ellipse([ox + 5, 8 + hover, ox + 15, 16 + hover], fill=body)
    draw.ellipse([ox + 6, 3 + hover, ox + 14, 10 + hover], fill=body)
    draw.polygon([(ox + 7, 3 + hover), (ox + 6, 0 + hover), (ox + 9, 2 + hover)], fill=horn)
    draw.polygon([(ox + 12, 2 + hover), (ox + 14, 0 + hover), (ox + 13, 3 + hover)], fill=horn)
    px1(draw, 8, 5 + hover, (255, 214, 0, 255), ox)
    px1(draw, 12, 5 + hover, (255, 214, 0, 255), ox)
    if frame % 2 == 0:
        circle_pixels(draw, 16, 6 + hover, 1, (255, 152, 0, 160), ox)
    draw.arc([ox + 3, 12 + hover, ox + 7, 16 + hover], 90, 270, fill=body, width=1)

def draw_comp_phoenix(draw, ox, frame):
    body = (255, 111, 0, 255)
    wing = (255, 143, 0, 255)
    flame = (255, 235, 59, 255)
    hover = [0, -1, -2, -1][frame]
    import math as m
    ws = int(m.sin(frame * 1.2) * 2)
    circle_pixels(draw, 10, 10 + hover, 7, (255, 111, 0, 30), ox)
    draw.polygon([(ox + 7, 8 + hover), (ox + 2 - ws, 4 + hover), (ox + 5, 12 + hover)], fill=wing)
    draw.polygon([(ox + 13, 8 + hover), (ox + 18 + ws, 4 + hover), (ox + 15, 12 + hover)], fill=wing)
    draw.ellipse([ox + 5, 6 + hover, ox + 15, 14 + hover], fill=body)
    circle_pixels(draw, 10, 4 + hover, 2, body, ox)
    draw.polygon([(ox + 9, 2 + hover), (ox + 10, 0 + hover), (ox + 11, 2 + hover)], fill=flame)
    px1(draw, 8, 3 + hover, (255, 255, 255, 255), ox)
    px1(draw, 12, 3 + hover, (255, 255, 255, 255), ox)
    for i in range(2):
        dy = 14 + i * 2 + hover
        draw.ellipse([ox + 9 - i, dy, ox + 11 + i, dy + 2], fill=flame)

COMPANION_RENDERERS = {
    'cat': draw_comp_cat, 'hamster': draw_comp_hamster, 'rabbit': draw_comp_rabbit,
    'owl': draw_comp_owl, 'fox': draw_comp_fox, 'penguin': draw_comp_penguin,
    'wolf_c': draw_comp_wolf, 'unicorn': draw_comp_unicorn,
    'dragon_c': draw_comp_dragon, 'phoenix_c': draw_comp_phoenix,
}

def generate_companions():
    W, H = COMP_SIZE, COMP_SIZE
    frames = 4
    for name, renderer in COMPANION_RENDERERS.items():
        img = create_sheet(W, H, frames)
        draw = ImageDraw.Draw(img)
        for i in range(frames):
            renderer(draw, i * W, i)
        img.save(os.path.join(OUTPUT_DIR, f'companion_{name}.png'))
        print(f'  companion_{name}.png ({frames} frames)')


# ============================================================
# OBSTACLE - 24x24, 1 frame (static rock)
# ============================================================

def generate_obstacle():
    W, H = 24, 24
    img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    rock = (120, 120, 120, 255)
    dark = (90, 90, 90, 255)
    light = (150, 150, 150, 255)

    # Main rock body
    draw.polygon([
        (4, 22), (2, 14), (6, 6), (12, 2), (18, 4), (22, 10), (20, 22)
    ], fill=rock)
    # Dark side
    draw.polygon([
        (4, 22), (2, 14), (6, 10), (10, 22)
    ], fill=dark)
    # Highlight
    draw.polygon([
        (10, 4), (14, 2), (16, 6), (12, 8)
    ], fill=light)
    # Cracks
    draw.line([(10, 8), (14, 14), (12, 18)], fill=dark, width=1)

    img.save(os.path.join(OUTPUT_DIR, 'obstacle.png'))
    print('  obstacle.png (1 frame)')


# ============================================================
# GROUND TILES - 32x16 per region
# ============================================================

def generate_ground_tiles():
    W, H = 32, 16
    regions = {
        'meadow': ((74, 124, 63, 255), (58, 98, 48, 255), (92, 148, 78, 255)),
        'forest': ((56, 94, 44, 255), (44, 74, 36, 255), (68, 114, 56, 255)),
        'desert': ((210, 180, 120, 255), (190, 160, 100, 255), (230, 200, 140, 255)),
        'snowfield': ((230, 240, 250, 255), (200, 215, 230, 255), (245, 248, 255, 255)),
        'volcano': ((80, 50, 40, 255), (60, 35, 28, 255), (110, 65, 50, 255)),
    }

    for name, (base, dark, light) in regions.items():
        img = Image.new('RGBA', (W, H), base)
        draw = ImageDraw.Draw(img)
        # Top grass/edge line
        rect(draw, 0, 0, W, 2, light, 0)
        # Some texture
        for x in range(0, W, 4):
            rect(draw, x, 2, 1, 1, dark, 0)
        for x in range(2, W, 6):
            rect(draw, x, 4, 2, 1, dark, 0)
        # Bottom darker
        rect(draw, 0, H - 3, W, 3, dark, 0)

        img.save(os.path.join(OUTPUT_DIR, f'ground_{name}.png'))
        print(f'  ground_{name}.png')


# ============================================================
# MAIN
# ============================================================

if __name__ == '__main__':
    print('Generating pixel art sprites...')
    print()
    print('[Player]')
    generate_bichon()
    print()
    print('[Coin]')
    generate_coin()
    print()
    print('[Enemies - 20 types]')
    generate_enemies()
    print()
    print('[Bosses - 5 types]')
    generate_bosses()
    print()
    print('[Companions - 10 types]')
    generate_companions()
    print()
    print('[Obstacle]')
    generate_obstacle()
    print()
    print('[Ground Tiles]')
    generate_ground_tiles()
    print()
    print(f'Done! All sprites saved to {os.path.abspath(OUTPUT_DIR)}')
