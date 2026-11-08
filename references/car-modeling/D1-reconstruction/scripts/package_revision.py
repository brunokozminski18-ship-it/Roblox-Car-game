"""Preserve a saved native display and embed the matching authored mesh recipe."""
import base64
import json
import sys
from pathlib import Path
import xml.etree.ElementTree as ET
import zstandard


def name(item):
    return item.findtext("Properties/string[@name='Name']")


def package(saved, mesh, output):
    tree=ET.parse(saved)
    car=next(item for item in tree.iter("Item") if name(item)=="D1_Rebuilt_From_Analysis")
    attrs=car.findtext("Properties/BinaryString[@name='AttributesSerialize']")
    expected=mesh.name.removesuffix("-mesh.json").encode()
    assert expected in base64.b64decode(attrs or ""), "Saved display revision differs from mesh recipe"
    display=next(item for item in car.findall("Item") if name(item)=="PortableDisplay")
    parts=json.loads(mesh.read_text())
    assert len(display.findall("Item"))==len(parts)==29
    module=next(item for item in car.findall("Item") if name(item)=="RestoreOwnGeometry")
    data=json.dumps(parts,separators=(",",":")).encode()
    packed=base64.b64encode(zstandard.ZstdCompressor(level=10).compress(data)).decode()
    blocks=sorted(module.findall("Item"),key=name)
    while len(blocks)*40000<len(packed):
        block=ET.SubElement(module,"Item",{"class":"StringValue"})
        props=ET.SubElement(block,"Properties")
        ET.SubElement(props,"string",{"name":"Name"}).text=f"Block{len(blocks):04d}"
        ET.SubElement(props,"string",{"name":"Value"})
        blocks.append(block)
    for i,block in enumerate(blocks):
        block.find("Properties/string[@name='Value']").text=packed[i*40000:(i+1)*40000]
    output.parent.mkdir(parents=True,exist_ok=True)
    tmp=output.with_suffix(".pending")
    tree.write(tmp,encoding="utf-8",xml_declaration=True)
    # Verify the actual bytes in the file to be delivered, including all vertices.
    restored=ET.parse(tmp)
    mod=next(item for item in restored.iter("Item") if name(item)=="RestoreOwnGeometry")
    joined="".join(block.findtext("Properties/string[@name='Value']") or "" for block in sorted(mod.findall("Item"),key=name))
    assert zstandard.ZstdDecompressor().decompress(base64.b64decode(joined))==data
    tmp.replace(output)
    print("Verified embedded payload for",len(parts),"meshes and",len(list(display.iter("Item")))-1,"native display objects/groups.")


if __name__=="__main__":
    package(*map(Path,sys.argv[1:]))
