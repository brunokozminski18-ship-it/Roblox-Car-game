"""Decode persisted Studio MCP captures and create labelled analysis sheets."""
from pathlib import Path
import base64
from PIL import Image, ImageOps, ImageDraw


def main(root):
    root = Path(root)
    for encoded in root.glob('*.png.b64'):
        encoded.with_suffix('').write_bytes(base64.b64decode(encoded.read_text()))
        encoded.unlink()
    names = sorted(p.stem.removesuffix('_front34') for p in root.glob('*_front34.png'))
    for page, start in enumerate(range(0, len(names), 7), 1):
        subset = names[start:start+7]
        sheet = Image.new('RGB', (1500, len(subset)*246), '#151922')
        draw = ImageDraw.Draw(sheet)
        for row, name in enumerate(subset):
            for col, view in enumerate(('front34', 'side', 'rear34')):
                src = root / f'{name}_{view}.png'
                if not src.exists():
                    continue
                im = Image.open(src).convert('RGB')
                # All source captures remain intact; these are only review thumbnails.
                thumb = ImageOps.contain(im, (500, 218))
                x, y = col*500+(500-thumb.width)//2, row*246+28
                sheet.paste(thumb, (x, y))
                draw.text((col*500+10, row*246+7), f'{name} / {view}', fill='white')
        sheet.save(root / f'contact_sheet_{page}.jpg', quality=92)


if __name__ == '__main__':
    import sys
    main(sys.argv[1])
