"""Embed the independently authored mesh payload in a separate full Studio place."""
from pathlib import Path
import re
import xml.etree.ElementTree as ET

assets=Path(__file__).resolve().parents[1]/"assets"
dest=assets/"D1 delivery"
dest.mkdir(exist_ok=True)
tree=ET.parse(assets/"D1 Studio master.rbxlx")
def name(x):return x.findtext("Properties/string[@name='Name']")
model=next(x for x in tree.getroot().iter("Item") if name(x)=="D1_Rebuilt_From_Analysis")
module=next(x for x in model.findall("Item") if name(x)=="RestoreOwnGeometry")
payload=re.search(r'local payload = "([A-Za-z0-9+/=]+)"',(assets/"contact.luau").read_text())[1]
blocks=sorted(module.findall("Item"),key=name)
assert len(blocks)*40000>=len(payload)
for i,block in enumerate(blocks):
    block.find("Properties/string[@name='Value']").text=payload[i*40000:(i+1)*40000]
tree.write(dest/"D1 - Car Pack.rbxlx",encoding="utf-8",xml_declaration=True)
