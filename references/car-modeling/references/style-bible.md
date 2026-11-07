# Car Pack — measured style bible

Inspection: 07–08 November 2026, Studio MCP, `Car Pack.rbxl`, `Workspace.Cars`. Originals untouched. Primary evidence: `../evidence/Normal.json`, the other four variant JSON files, `construction.json`, `summary.json`, `dimensions.csv`, and the screenshot atlas. These are maintained local observations, not LihFolk library copies.

## MEASURED: inventory and assembly

- Workspace contains exactly 95 Models, all inside Cars. Five folders contain 19 each: Normal, Golden, Diamond, Ruby, Neon. Showcase is empty; ThumbnailCamera is a camera, not an extra car.
- 468 MeshParts per folder, 2,340 total; 300 distinct MeshIds. Each base contains 20–33 visible MeshParts. Normal also contains 20 invisible helper Parts: 19 Handles and Spali's additional Root.
- Hierarchy is predominantly flat: visible MeshParts directly under the Model, invisible Handle with Welds linking the display assembly. Some models have extra weld structure; see construction.json. Mesh count is not triangle count, material count or draw-call count.
- Every inspected Normal MeshPart: Anchored=true; CanCollide/CanQuery/CanTouch/CastShadow/DoubleSided=false; CollisionFidelity=Box; RenderFidelity=Performance; Transparency=0. This is a display asset arrangement, not a demonstrated driving rig. Do not inherit these flags blindly for gameplay.
- All inspected MeshPart TextureID fields are empty; no SurfaceAppearance exists in the 95 cars. This rules out those texture sources, not unseen vertex colours or unknown UV data.
- Normal has 430 Plastic and 38 Neon MeshParts. Large parts may contain disconnected islands, for example a pair of lamps in one mesh: the part's width includes the gap.

## MEASURED: proportions

World-axis bounds are computed from all eight transformed corners of every visible MeshPart box, excluding helpers. They are not a vertex-tight surface measurement. The pack faces world −Z. Local mesh Size axes can be rotated; never read local X as car width without transforming corners.

Base ranges: length **9.194–10.370**, width **4.124–4.974**, height **2.234–3.475** studs. Wheelbase/length **0.538–0.632**. These ranges describe different vehicle classes, not a tolerance for every new design.

| Reference | Class/use | L × W × H | Wheelbase/L | Tire diameter/L, front–rear |
|---|---|---|---|---|
| BimmerN2 | upright compact coupe | 9.194 × 4.393 × 2.991 | .597 | .157–.165 |
| Gulf | tall hatchback | 9.657 × 4.681 × 3.475 | .612 | .160–.169 |
| Supre | front-engine sports coupe | 10.016 × 4.568 × 2.657 | .559 | .143–.143 |
| Agro | low wide hypercar | 9.732 × 4.974 × 2.478 | .620 | .150–.157 |
| Spali | open-wheel single-seater | 9.844 × 4.224 × 2.287 | .589 | .145–.145 |

Tire diameter is max(local Size), an approximation. The source tire is not perfectly equal in its two radial box dimensions. Identify the four tire meshes by inspected name, colour, position and geometry role; colour alone also selects dark trim. Exact tread section and vertex counts remain unmeasured.

## MEASURED: reusable palette and material roles

| Role | sRGB | Studio settings and caveats |
|---|---|---|
| glazing | #6E99CA | Plastic, Transparency=0, Reflectance=.5; 33 parts in 18 bases. Spali has no blue glazing. Bimmer's paint can share this colour with Reflectance=0. |
| tire | #2A2A30 | Plastic, Reflectance=0; also used by aero/trim parts |
| common rim | #61616F | Plastic; RS3GT uses red rims instead |
| deepest recess | #111111 | flat dark fields; do not replace with a detailed grille texture |
| aero/trim | #37383E | softer separation from the darkest recesses |
| front lamps | #B3B4BA | Neon in Supre; exceptions and actual part values are in inventory |
| rear lamps | #FF5959 | Neon in Supre; broad readable graphic |
| secondary dark | #4A4B53 | exhaust shell / detail in Supre |

All 18 non-Gulf bases use tire MeshId `76544074630082`; Gulf uses a separate tire asset `107896043752011`. Common spoke rim MeshId appears 72 times, Gulf's simple disc rim four times. New designs should build their own editable geometry; reuse the design principle, not extract restricted source geometry.

## OBSERVED: shape and construction language

- Surface density is selective: broad bonnet/door/roof fields, smaller wedges at fenders, bumper corners and arch contours. The facet changes follow the design, rather than random triangles.
- Body silhouette includes genuine front/rear overhangs, cabin placement and roof falloff. Gulf's upright rear and Bimmer's trunk cannot be obtained by merely increasing a supercar's roof height.
- Painted shoulders fold around polygonal wheel openings. Arches, tire clearances and bumper returns read from the side; a front-only graphic is insufficient.
- Opaque blue glazing acts as a large graphic region, with a dark roof/painted pillars framing it. No interior construction can be inferred through opaque windows.
- Lamp shapes, intake holes, spoiler and exhaust grouping provide identity at small scale. Spali is an explicit exception to the standard closed-body construction.
- Close-ups show thick tire sidewalls, a broad flat tread band and chamfered shoulders, without visible sculpted tread. Supre has broad alternating spoke sectors and a simple hub; Gulf uses a much simpler inset disc. Exact source sector counts are unknown.
- Some source parts combine left/right details into one mesh. Split new work by colour role and mobility needs, not by arbitrary universal counts.

## MEASURED: appearance variants

All 76 non-Normal cars match the corresponding Normal mesh-ID/Size multiset. This confirms asset/size reuse, not an independent vertex comparison. Golden/Diamond/Ruby/Neon mainly change paint/material and effects; they are not extra body shapes.

Supre example: base paint #660000; Golden #FFB000 +1 emitter; Diamond #04AFEC +3; Ruby #FF4646 +4; Neon retains #660000 and makes the paint Neon (+0 emitters). Do not apply Supre's single paint part rule to every base: inspect each recolour role. Preserve tire, window and lamp contrast.

## PROPOSED: starting values for new work

Use 10–12 tire sectors as an initial visual experiment, not a source measurement. A prototype triangle budget must be chosen and reported for the target game; none has been established for Car Pack's originals. Keep each material role deliberate, choose an appropriate body class and compare at the same screen size. One sample remains NOT FINAL until the user accepts its appearance.
