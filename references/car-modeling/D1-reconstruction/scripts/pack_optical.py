"""Package only the authored Blender sidecar, using Studio's Zstd codec."""
import base64
import json
import sys
from pathlib import Path
import zstandard

folder=Path(__file__).resolve().parent
assets=folder.parent/"assets"
key=sys.argv[1]
parts=json.loads((assets/(key+"-mesh.json")).read_text())
for p in parts:
    p["normals"]=[[round(x,4) for x in n] for n in p["normals"]]
raw=json.dumps(parts,separators=(",",":")).encode()
packed=base64.b64encode(zstandard.ZstdCompressor(level=10).compress(raw)).decode()
module=(folder/"restore_optical.template.luau").read_text().replace("__PAYLOAD__",packed)
(assets/(key+".luau")).write_text(module,encoding="ascii")
print(len(module),"bytes",len(parts),"meshes")
