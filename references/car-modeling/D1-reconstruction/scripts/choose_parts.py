"""Assemble tested parts while retaining the better earlier geometry per role."""
import json
from pathlib import Path
assets=Path(__file__).resolve().parents[1]/"assets"
versions={n:{p["index"]:p for p in json.loads((assets/(n+"-mesh.json")).read_text())}
          for n in ["wheel-profile","traced","panel","wrap"]}
choices={i:"wheel-profile" for i in versions["wheel-profile"]}
choices.update({10:"wrap",12:"wrap",15:"traced",18:"panel",22:"panel",23:"panel",26:"wrap",30:"panel"})
rows=[versions[n][i] for i,n in choices.items()]
(assets/"selected-mesh.json").write_text(json.dumps(rows,separators=(",",":")))
(assets/"selected-roles.json").write_text(json.dumps(choices,indent=2))
