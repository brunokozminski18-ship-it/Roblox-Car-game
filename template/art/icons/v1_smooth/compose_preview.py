"""Preview of menu icon tiles (playbook/UI_STYLE.md, "Ikony menu").

The tile, glow and caption are drawn in Roblox UI in the game; this script only
mocks them up around the rendered PNGs so the look can be judged before upload.

  python compose_preview.py <icons_dir> <font.ttf> <out.png>
"""

import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ICONS = [
    ("shop", "SHOP", "#FF8A1F"),
    ("daily", "DAILY", "#E8409B"),
]

TILE = 200
RADIUS = 22
CELL_W, CELL_H = 260, 280
BACKGROUND = "#4E555E"


def hex_rgb(value):
    v = value.lstrip("#")
    return tuple(int(v[i : i + 2], 16) for i in (0, 2, 4))


def darker(rgb, k):
    return tuple(int(c * k) for c in rgb)


def tile(icon_path, label, color, font):
    rgb = hex_rgb(color)
    cell = Image.new("RGBA", (CELL_W, CELL_H), (0, 0, 0, 0))
    x0 = (CELL_W - TILE) // 2
    y0 = 30

    # Dark rounded tile with a vertical gradient and a thin frame.
    grad = Image.new("RGBA", (TILE, TILE))
    top, bottom = hex_rgb("#222C37"), hex_rgb("#11161C")
    for y in range(TILE):
        t = y / (TILE - 1)
        c = tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3))
        ImageDraw.Draw(grad).line([(0, y), (TILE, y)], fill=(*c, 255))
    mask = Image.new("L", (TILE, TILE), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, TILE - 1, TILE - 1], RADIUS, fill=255)
    cell.paste(grad, (x0, y0), mask)

    # Glow in the icon colour rising from the bottom of the tile.
    glow = Image.new("RGBA", (TILE, TILE), (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse([TILE * 0.1, TILE * 0.55, TILE * 0.9, TILE * 1.25], fill=(*rgb, 170))
    glow = glow.filter(ImageFilter.GaussianBlur(26))
    glow_masked = Image.new("RGBA", (TILE, TILE), (0, 0, 0, 0))
    glow_masked.paste(glow, (0, 0), mask)
    cell.alpha_composite(glow_masked, (x0, y0))
    ImageDraw.Draw(cell).rounded_rectangle([x0, y0, x0 + TILE - 1, y0 + TILE - 1], RADIUS, outline=(*hex_rgb("#3C4652"), 255), width=3)

    # Icon, slightly larger than the tile so it can break the top edge.
    icon = Image.open(icon_path).convert("RGBA").resize((230, 230), Image.LANCZOS)
    cell.alpha_composite(icon, ((CELL_W - 230) // 2, y0 - 32))

    # Caption: white caps with a thick outline in the icon colour.
    draw = ImageDraw.Draw(cell)
    stroke = darker(rgb, 0.75)
    draw.text((CELL_W // 2, y0 + TILE - 4), label, font=font, fill="white", anchor="mm", stroke_width=6, stroke_fill=(*stroke, 255))
    return cell


def main():
    icons_dir, font_path, out_path = sys.argv[1:4]
    font = ImageFont.truetype(font_path, 38)
    cells = [tile(f"{icons_dir}/{name}.png", label, color, font) for name, label, color in ICONS]

    big_w = CELL_W * len(cells)
    small = [c.resize((CELL_W * 64 // TILE, CELL_H * 64 // TILE), Image.LANCZOS) for c in cells]
    sheet = Image.new("RGBA", (big_w + 40 + small[0].width + 40, CELL_H + 20), BACKGROUND)
    for i, c in enumerate(cells):
        sheet.alpha_composite(c, (i * CELL_W, 10))
    # In-game size column (tile about 64 px), stacked like the launcher.
    x = big_w + 40
    for i, c in enumerate(small):
        sheet.alpha_composite(c, (x, 20 + i * (c.height + 6)))
    sheet.convert("RGB").save(out_path)
    print("wrote", out_path)


main()
