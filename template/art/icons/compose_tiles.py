"""Mock-ups of menu icon tiles (playbook/UI_STYLE.md, "Ikony menu").

In the game the tile, glow and caption are Roblox UI; only the object PNG is an
image. This script draws the same tile around the PNGs so the look can be
judged and compared with references/ui/C1_menu_icons.png at the same scale.

  python compose_tiles.py compare <variants_dir> <c1.png> <font.ttf> <out.png>
  python compose_tiles.py sheet   <icons_dir>    <font.ttf> <out.png>
"""

import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

# name, caption, colour (icon colour = glow = caption outline)
MENU = [
    ("shop", "SHOP", "#FF8A1F"),
    ("inventory", "INVENTORY", "#2EC4B6"),
    ("index", "INDEX", "#3D8BFF"),
    ("tasks", "TASKS", "#7BD33A"),
    ("daily", "DAILY", "#FF4F9A"),
    ("rebirth", "REBIRTH", "#9B5CFF"),
    ("settings", "SETTINGS", "#9AA7B8"),
]

BACKGROUND = "#4E555E"


def hex_rgb(value):
    v = value.lstrip("#")
    return tuple(int(v[i : i + 2], 16) for i in (0, 2, 4))


def tile(icon_path, label, color, size, font_path):
    """One launcher cell: dark tile, faint glow, object, outlined caption."""
    rgb = hex_rgb(color)
    radius = max(4, size // 9)
    caption = ImageFont.truetype(font_path, max(10, int(size * 0.19)))
    w, h = int(size * 1.3), int(size * 1.32)
    cell = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    x0, y0 = (w - size) // 2, int(size * 0.08)

    grad = Image.new("RGBA", (size, size))
    top, bottom = hex_rgb("#222C37"), hex_rgb("#11161C")
    d = ImageDraw.Draw(grad)
    for y in range(size):
        t = y / max(1, size - 1)
        d.line([(0, y), (size, y)], fill=(*[int(top[i] + (bottom[i] - top[i]) * t) for i in range(3)], 255))
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, size - 1, size - 1], radius, fill=255)
    cell.paste(grad, (x0, y0), mask)

    glow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse([size * 0.15, size * 0.7, size * 0.85, size * 1.2], fill=(*rgb, 95))
    glow = glow.filter(ImageFilter.GaussianBlur(size * 0.1))
    clipped = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    clipped.paste(glow, (0, 0), mask)
    cell.alpha_composite(clipped, (x0, y0))
    ImageDraw.Draw(cell).rounded_rectangle(
        [x0, y0, x0 + size - 1, y0 + size - 1], radius, outline=(*hex_rgb("#3C4652"), 255), width=max(1, size // 70)
    )

    # Trim the render to the object, then fit it so every icon fills the tile
    # the same way (C1 objects fill most of the tile and break its top edge).
    icon = Image.open(icon_path).convert("RGBA")
    icon = icon.crop(icon.getchannel("A").getbbox())
    scale = min(size * 0.98 / icon.width, size * 0.9 / icon.height)
    icon = icon.resize((max(1, int(icon.width * scale)), max(1, int(icon.height * scale))), Image.LANCZOS)
    top = y0 + int(size * 0.42) - icon.height // 2
    cell.alpha_composite(icon, ((w - icon.width) // 2, max(0, top)))

    stroke = tuple(int(c * 0.72) for c in rgb)
    ImageDraw.Draw(cell).text(
        (w // 2, y0 + size - int(size * 0.02)), label, font=caption, fill="white", anchor="mm",
        stroke_width=max(2, size // 32), stroke_fill=(*stroke, 255),
    )
    return cell


def compare(variants_dir, c1_path, font_path, out_path):
    """C1 next to SHOP variants A, B, C at C1's tile size, plus a 2x zoom row."""
    c1 = Image.open(c1_path).convert("RGBA")
    size = 96  # C1 tiles are about 96 px wide
    label_font = ImageFont.truetype(font_path, 16)
    cells = [tile(f"{variants_dir}/{v}/shop.png", "SHOP", "#FF8A1F", size, font_path) for v in "ABC"]
    zoom = [tile(f"{variants_dir}/{v}/shop.png", "SHOP", "#FF8A1F", size * 2, font_path) for v in "ABC"]
    width = c1.width + 40 + sum(c.width + 20 for c in cells) + 40 + sum(z.width + 20 for z in zoom)
    height = max(c1.height, zoom[0].height + 40) + 30
    sheet = Image.new("RGBA", (width, height), BACKGROUND)
    draw = ImageDraw.Draw(sheet)
    draw.text((10, 6), "C1 (reference)", font=label_font, fill="white")
    sheet.alpha_composite(c1, (10, 28))
    x = c1.width + 40
    for v, c in zip("ABC", cells):
        draw.text((x, 6), v, font=label_font, fill="white")
        sheet.alpha_composite(c, (x, 28))
        x += c.width + 20
    x += 20
    draw.text((x, 6), "same tiles at 2x", font=label_font, fill="white")
    for v, z in zip("ABC", zoom):
        sheet.alpha_composite(z, (x, 28))
        draw.text((x + 6, 30), v, font=label_font, fill="white")
        x += z.width + 20
    sheet.convert("RGB").save(out_path)


def sheet(icons_dir, font_path, out_path):
    """Whole menu set: a launcher column at phone size and a row at PC size."""
    small = [tile(f"{icons_dir}/{n}.png", l, c, 64, font_path) for n, l, c in MENU]
    big = [tile(f"{icons_dir}/{n}.png", l, c, 150, font_path) for n, l, c in MENU]
    width = max(sum(b.width + 10 for b in big), 400) + 20
    height = big[0].height + 40 + small[0].height * 2 + 40
    out = Image.new("RGBA", (width, height), BACKGROUND)
    x = 10
    for b in big:
        out.alpha_composite(b, (x, 10))
        x += b.width + 10
    x, y = 10, big[0].height + 40
    for i, s in enumerate(small):
        out.alpha_composite(s, (x + (i % 4) * (s.width + 6), y + (i // 4) * (s.height + 4)))
    out.convert("RGB").save(out_path)


if __name__ == "__main__":
    mode = sys.argv[1]
    if mode == "compare":
        compare(*sys.argv[2:6])
    else:
        sheet(*sys.argv[2:5])
