#!/usr/bin/env python3
"""
OGP画像生成スクリプト
Cairo + Pango (ctypes) を使用して1200x630のOGP画像を生成する

使い方:
  python3 scripts/generate_ogp.py

ロゴ画像:
  app/assets/images/logo_transparent.png (優先) または
  app/assets/images/logo.png
  が存在すればロゴとして使用。なければテキストフォールバック。
"""

import ctypes
import ctypes.util
import math
import os

# ===== Library Loading =====
cairo = ctypes.CDLL(ctypes.util.find_library('cairo'))
pango = ctypes.CDLL(ctypes.util.find_library('pango-1.0'))
pangocairo = ctypes.CDLL(ctypes.util.find_library('pangocairo-1.0'))
gobject = ctypes.CDLL(ctypes.util.find_library('gobject-2.0'))

# ===== Constants =====
CAIRO_FORMAT_ARGB32 = 0
PANGO_SCALE = 1024
PANGO_WEIGHT_NORMAL = 400
PANGO_WEIGHT_BOLD = 700
PANGO_ALIGN_CENTER = 1

WIDTH = 1200
HEIGHT = 630

# ===== Colors =====
COL = {
    'primary':   (0xc0/255, 0x6c/255, 0x5e/255),
    'main_text': (0x4a/255, 0x37/255, 0x28/255),
    'sub_text':  (0x6b/255, 0x5a/255, 0x4d/255),
    'bg_light':  (0xfd/255, 0xfa/255, 0xf1/255),
    'bg_dark':   (0xf5/255, 0xf0/255, 0xe1/255),
}

# ===== Cairo function signatures =====
cairo.cairo_image_surface_create.restype = ctypes.c_void_p
cairo.cairo_create.restype = ctypes.c_void_p
cairo.cairo_image_surface_create_from_png.restype = ctypes.c_void_p
cairo.cairo_image_surface_get_width.restype = ctypes.c_int
cairo.cairo_image_surface_get_height.restype = ctypes.c_int
cairo.cairo_status.restype = ctypes.c_int
cairo.cairo_surface_status.restype = ctypes.c_int
pango.pango_font_description_new.restype = ctypes.c_void_p
pango.pango_font_description_from_string.restype = ctypes.c_void_p
pangocairo.pango_cairo_create_layout.restype = ctypes.c_void_p


def cd(v):
    """Shorthand for ctypes.c_double."""
    return ctypes.c_double(v)


class Ctx:
    """Cairo drawing context wrapper."""

    def __init__(self, w, h):
        self.w, self.h = w, h
        self.surface = cairo.cairo_image_surface_create(CAIRO_FORMAT_ARGB32, w, h)
        self.cr = cairo.cairo_create(self.surface)

    def save(self):
        cairo.cairo_save(self.cr)

    def restore(self):
        cairo.cairo_restore(self.cr)

    def rgb(self, color, a=1.0):
        cairo.cairo_set_source_rgba(self.cr, cd(color[0]), cd(color[1]), cd(color[2]), cd(a))

    def rect(self, x, y, w, h):
        cairo.cairo_rectangle(self.cr, cd(x), cd(y), cd(w), cd(h))
        cairo.cairo_fill(self.cr)

    def circle(self, cx, cy, r):
        cairo.cairo_arc(self.cr, cd(cx), cd(cy), cd(r), cd(0), cd(2 * math.pi))
        cairo.cairo_fill(self.cr)

    def _rounded_path(self, x, y, w, h, r):
        cairo.cairo_new_sub_path(self.cr)
        cairo.cairo_arc(self.cr, cd(x+w-r), cd(y+r),   cd(r), cd(-math.pi/2), cd(0))
        cairo.cairo_arc(self.cr, cd(x+w-r), cd(y+h-r), cd(r), cd(0),           cd(math.pi/2))
        cairo.cairo_arc(self.cr, cd(x+r),   cd(y+h-r), cd(r), cd(math.pi/2),   cd(math.pi))
        cairo.cairo_arc(self.cr, cd(x+r),   cd(y+r),   cd(r), cd(math.pi),     cd(3*math.pi/2))
        cairo.cairo_close_path(self.cr)

    def rounded_rect(self, x, y, w, h, r):
        self._rounded_path(x, y, w, h, r)
        cairo.cairo_fill(self.cr)

    def rounded_rect_stroke(self, x, y, w, h, r, lw=1.0):
        cairo.cairo_set_line_width(self.cr, cd(lw))
        self._rounded_path(x, y, w, h, r)
        cairo.cairo_stroke(self.cr)

    def line(self, x1, y1, x2, y2, lw=1.0):
        cairo.cairo_set_line_width(self.cr, cd(lw))
        cairo.cairo_move_to(self.cr, cd(x1), cd(y1))
        cairo.cairo_line_to(self.cr, cd(x2), cd(y2))
        cairo.cairo_stroke(self.cr)

    def text(self, txt, x, y, family="IPAPGothic", size=24, bold=False, max_w=None):
        """Draw text at (x, y). Returns (width, height)."""
        layout = pangocairo.pango_cairo_create_layout(self.cr)
        fd = pango.pango_font_description_new()
        pango.pango_font_description_set_family(fd, family.encode('utf-8'))
        pango.pango_font_description_set_size(fd, int(size * PANGO_SCALE))
        pango.pango_font_description_set_weight(fd, PANGO_WEIGHT_BOLD if bold else PANGO_WEIGHT_NORMAL)
        pango.pango_layout_set_font_description(layout, fd)
        pango.pango_layout_set_text(layout, txt.encode('utf-8'), -1)
        if max_w:
            pango.pango_layout_set_width(layout, int(max_w * PANGO_SCALE))
            pango.pango_layout_set_alignment(layout, PANGO_ALIGN_CENTER)
        pw, ph = ctypes.c_int(), ctypes.c_int()
        pango.pango_layout_get_pixel_size(layout, ctypes.byref(pw), ctypes.byref(ph))
        cairo.cairo_move_to(self.cr, cd(x), cd(y))
        pangocairo.pango_cairo_show_layout(self.cr, layout)
        pango.pango_font_description_free(fd)
        gobject.g_object_unref(layout)
        return pw.value, ph.value

    def text_centered(self, txt, cx, cy, **kw):
        """Draw text centered at (cx, cy). Returns (width, height)."""
        layout = pangocairo.pango_cairo_create_layout(self.cr)
        fd = pango.pango_font_description_new()
        fam = kw.get('family', 'IPAPGothic')
        sz = kw.get('size', 24)
        bold = kw.get('bold', False)
        pango.pango_font_description_set_family(fd, fam.encode('utf-8'))
        pango.pango_font_description_set_size(fd, int(sz * PANGO_SCALE))
        pango.pango_font_description_set_weight(fd, PANGO_WEIGHT_BOLD if bold else PANGO_WEIGHT_NORMAL)
        pango.pango_layout_set_font_description(layout, fd)
        pango.pango_layout_set_text(layout, txt.encode('utf-8'), -1)
        mw = kw.get('max_w')
        if mw:
            pango.pango_layout_set_width(layout, int(mw * PANGO_SCALE))
            pango.pango_layout_set_alignment(layout, PANGO_ALIGN_CENTER)
        pw, ph = ctypes.c_int(), ctypes.c_int()
        pango.pango_layout_get_pixel_size(layout, ctypes.byref(pw), ctypes.byref(ph))
        x = cx - pw.value / 2
        y = cy - ph.value / 2
        cairo.cairo_move_to(self.cr, cd(x), cd(y))
        pangocairo.pango_cairo_show_layout(self.cr, layout)
        pango.pango_font_description_free(fd)
        gobject.g_object_unref(layout)
        return pw.value, ph.value

    def image(self, path, x, y, target_h=None, target_w=None):
        """Draw PNG image. Returns (drawn_w, drawn_h)."""
        surf = cairo.cairo_image_surface_create_from_png(path.encode('utf-8'))
        if cairo.cairo_surface_status(surf) != 0:
            cairo.cairo_surface_destroy(surf)
            return 0, 0
        iw = cairo.cairo_image_surface_get_width(surf)
        ih = cairo.cairo_image_surface_get_height(surf)
        if iw <= 0 or ih <= 0:
            cairo.cairo_surface_destroy(surf)
            return 0, 0
        sx, sy = 1.0, 1.0
        if target_w and target_h:
            sx, sy = target_w / iw, target_h / ih
        elif target_h:
            sy = target_h / ih; sx = sy
        elif target_w:
            sx = target_w / iw; sy = sx
        self.save()
        cairo.cairo_translate(self.cr, cd(x), cd(y))
        cairo.cairo_scale(self.cr, cd(sx), cd(sy))
        cairo.cairo_set_source_surface(self.cr, surf, cd(0), cd(0))
        cairo.cairo_paint(self.cr)
        self.restore()
        cairo.cairo_surface_destroy(surf)
        return int(iw * sx), int(ih * sy)

    def write(self, path):
        cairo.cairo_surface_write_to_png(self.surface, path.encode('utf-8'))

    def destroy(self):
        cairo.cairo_destroy(self.cr)
        cairo.cairo_surface_destroy(self.surface)


# ===== Helper drawing functions =====

def bg_cream(c):
    c.rgb(COL['bg_light'])
    c.rect(0, 0, WIDTH, HEIGHT)


def soft_circles(c, items):
    for cx, cy, r, a in items:
        c.rgb(COL['primary'], a)
        c.circle(cx, cy, r)


def ruled_lines(c, x, y, w, h, sp=32, a=0.06):
    c.rgb(COL['primary'], a)
    cur = y + sp
    while cur < y + h:
        c.line(x, cur, x + w, cur, 0.8)
        cur += sp


def deco_line(c, cx, y, length, lw=2.0, a=0.5):
    c.rgb(COL['primary'], a)
    c.line(cx - length/2, y, cx + length/2, y, lw)


def text_logo_fallback(c, cx, cy):
    """Fallback: draw 'Epistory' as styled text."""
    c.rgb(COL['main_text'])
    _, h = c.text_centered("Epistory", cx, cy, family="DejaVu Serif", size=52, bold=True)
    return h + 20


def draw_logo_or_fallback(c, logo_path, cx, top_y, target_h):
    """Draw logo centered, return bottom y position."""
    if logo_path:
        # Measure first
        dw, dh = c.image(logo_path, 0, -9999, target_h=target_h)
        if dw > 0:
            lx = cx - dw / 2
            c.image(logo_path, lx, top_y, target_h=target_h)
            return top_y + dh, dw
    # Fallback
    h = text_logo_fallback(c, cx, top_y + target_h / 2)
    return top_y + target_h, 0


# ===== Design Variation 1: Stationery Glass =====
def gen_v1(logo_path, out):
    c = Ctx(WIDTH, HEIGHT)
    bg_cream(c)

    # Decorative soft circles
    soft_circles(c, [
        (-60, -40, 180, 0.06),
        (WIDTH + 80, HEIGHT + 60, 200, 0.05),
        (WIDTH - 200, -80, 120, 0.03),
    ])

    # Glass panel card
    cw, ch = 720, 460
    cx, cy = (WIDTH - cw) / 2, (HEIGHT - ch) / 2

    # Shadow
    c.rgb((0, 0, 0), 0.04)
    c.rounded_rect(cx + 4, cy + 4, cw, ch, 24)

    # Card fill (semi-transparent white)
    c.rgb((1, 1, 1), 0.55)
    c.rounded_rect(cx, cy, cw, ch, 24)

    # Card border
    c.rgb(COL['primary'], 0.12)
    c.rounded_rect_stroke(cx, cy, cw, ch, 24, 1.5)

    # Ruled lines inside card
    ruled_lines(c, cx + 40, cy + 20, cw - 80, ch - 40, sp=34, a=0.04)

    # Logo
    logo_top = cy + 40
    logo_bottom, _ = draw_logo_or_fallback(c, logo_path, WIDTH/2, logo_top, 200)

    # Decorative line
    ly = logo_bottom + 24
    deco_line(c, WIDTH/2, ly, 80, 2.0, 0.4)

    # Tagline
    ty = ly + 20
    c.rgb(COL['main_text'])
    c.text_centered("言葉にできなかった想いを、かたちに", WIDTH/2, ty, size=20)

    # Sub text
    c.rgb(COL['sub_text'], 0.7)
    c.text_centered("質問に答えるだけで、大切な人への感謝のメッセージが完成", WIDTH/2, ty + 48, size=12)

    c.write(out)
    c.destroy()
    print(f"  V1 (Stationery Glass) -> {out}")


# ===== Design Variation 2: Warm Letter =====
def gen_v2(logo_path, out):
    c = Ctx(WIDTH, HEIGHT)
    bg_cream(c)

    # Warm overlay bands (top/bottom)
    c.rgb(COL['bg_dark'], 0.3)
    c.rect(0, 0, WIDTH, 80)
    c.rgb(COL['bg_dark'], 0.2)
    c.rect(0, HEIGHT - 80, WIDTH, 80)

    # Left margin line (letter feel)
    c.rgb(COL['primary'], 0.15)
    c.line(80, 40, 80, HEIGHT - 40, 2.0)

    # Corner decorations
    cn, cw_l, mg = 40, 2.0, 30
    c.rgb(COL['primary'], 0.2)
    for (ax, ay, dx, dy) in [
        (mg, mg, 1, 1), (WIDTH-mg, mg, -1, 1),
        (mg, HEIGHT-mg, 1, -1), (WIDTH-mg, HEIGHT-mg, -1, -1),
    ]:
        c.line(ax, ay, ax + dx*cn, ay, cw_l)
        c.line(ax, ay, ax, ay + dy*cn, cw_l)

    # Faint ruled lines
    ruled_lines(c, 100, 60, WIDTH - 200, HEIGHT - 120, sp=36, a=0.03)

    # Logo
    logo_bottom, _ = draw_logo_or_fallback(c, logo_path, WIDTH/2, 100, 240)

    # Decorative line with dots
    ly = logo_bottom + 30
    deco_line(c, WIDTH/2, ly, 100, 2.0, 0.3)
    c.rgb(COL['primary'], 0.3)
    c.circle(WIDTH/2 - 58, ly, 3)
    c.circle(WIDTH/2 + 58, ly, 3)

    # Tagline
    ty = ly + 28
    c.rgb(COL['main_text'])
    c.text_centered("言葉にできなかった想いを、かたちに", WIDTH/2, ty, size=22, bold=True)

    # Sub text
    c.rgb(COL['sub_text'], 0.6)
    c.text_centered("質問に答えるだけで、大切な人への感謝のメッセージが完成", WIDTH/2, ty + 52, size=13)

    c.write(out)
    c.destroy()
    print(f"  V2 (Warm Letter) -> {out}")


# ===== Design Variation 3: Minimal Craft =====
def gen_v3(logo_path, out):
    c = Ctx(WIDTH, HEIGHT)
    bg_cream(c)

    # Large accent circle (right side, clipped)
    c.rgb(COL['primary'], 0.06)
    c.circle(WIDTH + 40, HEIGHT/2 + 40, 340)

    # Small accent circle
    c.rgb(COL['primary'], 0.04)
    c.circle(WIDTH - 200, 80, 80)

    # Tiny dot
    c.rgb(COL['primary'], 0.15)
    c.circle(120, HEIGHT - 100, 8)

    # Logo (slightly left of center)
    off = 60
    logo_bottom, lw = draw_logo_or_fallback(c, logo_path, WIDTH/2 - off, 100, 260)
    content_cx = WIDTH/2 - off

    # Decorative line
    ly = logo_bottom + 24
    deco_line(c, content_cx, ly, 60, 2.5, 0.35)

    # Tagline
    ty = ly + 22
    c.rgb(COL['main_text'])
    c.text_centered("言葉にできなかった想いを、かたちに", content_cx, ty, size=20)

    # Sub text
    c.rgb(COL['sub_text'], 0.6)
    c.text_centered("質問に答えるだけで、大切な人への感謝のメッセージが完成", content_cx, ty + 44, size=12)

    c.write(out)
    c.destroy()
    print(f"  V3 (Minimal Craft) -> {out}")


def find_logo():
    base = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    for name in ["logo_transparent.png", "logo.png"]:
        p = os.path.join(base, "app", "assets", "images", name)
        if os.path.exists(p):
            return p
    return None


def main():
    base = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    img_dir = os.path.join(base, "app", "assets", "images")

    logo = find_logo()
    print(f"Logo: {logo or '(not found - using text fallback)'}")
    print("Generating OGP variations...")

    gen_v1(logo, os.path.join(img_dir, "ogp_v1.png"))
    gen_v2(logo, os.path.join(img_dir, "ogp_v2.png"))
    gen_v3(logo, os.path.join(img_dir, "ogp_v3.png"))

    print("\nDone! Open the images to compare:")
    for i in range(1, 4):
        print(f"  app/assets/images/ogp_v{i}.png")


if __name__ == "__main__":
    main()
