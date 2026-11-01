"""Build with Rojo, then expose only its managed script trees as a local JSON snapshot.
Fallback for Studio MCP when the interactive Rojo plugin is not connected.
Run: python tools/rojo_snapshot.py; Studio: run tools/SyncStudio.luau in Edit.
"""
import json
import pathlib
import subprocess
import xml.etree.ElementTree as ET
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
import os
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
os.chdir(ROOT)
(ROOT / 'assets').mkdir(exist_ok=True)
subprocess.run(['rojo', 'build', 'default.project.json', '--output', 'assets/Prototype.rbxlx'], check=True)
tree = ET.parse(ROOT / 'assets/Prototype.rbxlx')

def convert(item):
    props = item.find('Properties')
    name = props.find("*[@name='Name']").text
    source = props.find("*[@name='Source']")
    result = {'className': item.attrib['class'], 'name': name, 'children': [convert(i) for i in item.findall('Item')]}
    if source is not None:
        result['source'] = source.text or ''
    result['properties'] = {p.attrib['name']: p.text == 'true' for p in props if p.attrib.get('name') == 'LoadCharacterAppearance'}
    return result

snapshot = {'placeId': 74773184167716, 'roots': [convert(i) for i in tree.getroot().findall('Item')]}
(ROOT / 'assets/snapshot.json').write_text(json.dumps(snapshot), encoding='utf-8')
print('Rojo snapshot ready at http://127.0.0.1:34874/assets/snapshot.json', flush=True)
if '--build-only' not in sys.argv:
    ThreadingHTTPServer(('127.0.0.1', 34874), SimpleHTTPRequestHandler).serve_forever()
