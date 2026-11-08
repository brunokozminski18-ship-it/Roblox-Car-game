"""Template: inspect glossy renders at actual 256/64px on light/dark backgrounds."""
from pathlib import Path
from PIL import Image, ImageDraw

folder = Path(__file__).resolve().parent / 'glossy'
files = sorted(f for f in folder.glob('*.png') if not f.name.startswith('_'))
sheet = Image.new('RGB', (1024, len(files)*290), '#353141')
draw = ImageDraw.Draw(sheet)
for i, path in enumerate(files):
    image = Image.open(path).convert('RGBA')
    y = i*290
    draw.text((8,y+6), path.stem, fill='white')
    for x, size, bg in [(145,256,'#222031'),(415,256,'#f2f0e8'),(700,64,'#222031'),(790,64,'#f2f0e8')]:
        tile = Image.new('RGBA', (size,size), bg)
        tile.alpha_composite(image.resize((size,size),Image.Resampling.LANCZOS))
        sheet.paste(tile.convert('RGB'),(x,y+25))
sheet.save(folder/'_sheet.png')
small = Image.new('RGB',(800,((len(files)+7)//8)*110),'#222031')
draw = ImageDraw.Draw(small)
for i,path in enumerate(files):
    image = Image.open(path).convert('RGBA').resize((64,64),Image.Resampling.LANCZOS)
    x=(i%8)*100;y=(i//8)*110
    small.paste(image,(x+16,y),image)
    draw.text((x+8,y+70),path.stem,fill='white')
small.save(folder/'_64.png')
