# Atlas of all 19 base constructions

Read alongside contact_sheet_1–3.jpg in `../evidence/screenshots/`. Each row has front three-quarter, full side and rear three-quarter source captures. The measured dimensions below are world-axis MeshPart-box bounds, excluding invisible helpers; not vertex-tight geometry. Wheel diameters are approximate local-box maxima.

| Model | MeshParts | L × W × H, studs | Wheelbase/L | OBSERVED construction / transferable lesson |
|---|---:|---|---:|---|
| Agro | 20 | 9.732 × 4.974 × 2.478 | .620 | Wide low cabin, long dark side wedge, split lower intake, rear wing. Side contrast is a major shape feature; keep roof far lower than the compact references. |
| Avetedor | 26 | 10.016 × 4.725 × 2.375 | .546 | Wedge bonnet, triangular front lamps, high diagonal side opening, rear slatted deck and wing. Large angled fields matter more than a fine grille. |
| BimmerN2 | 22 | 9.194 × 4.393 × 2.991 | .597 | Upright compact coupe, obvious bonnet/cabin/trunk volumes, two central dark grille holes, broad rear lamps and grouped exhausts. Good reference for a taller cabin, but not a four-door sedan blueprint. |
| Curvett | 22 | 9.500 × 4.257 × 2.574 | .604 | Long bonnet with dark insert, cabin aft, modest rear spoiler and clustered centre exhausts. Front fender has a deliberate peaked shoulder. |
| D1 | 29 | 10.017 × 4.404 × 2.375 | .579 | Rounded low cabin translated into large facets, strong dark side scoop, contrast nose corners and pronounced rear aero. Dark panels reinforce the painted silhouette. |
| Divviti | 20 | 9.328 × 4.124 × 2.318 | .600 | Dark streamlined body, small central horseshoe-like opening, sweeping flank outline, narrow stacked rear elements and many exhaust ends. Closely related dark colours still separate by plane angle. |
| GTI40 | 20 | 9.753 × 4.298 × 2.234 | .579 | Very low roof, long flat upper rear deck, short steep front, paired round rear lights and central exhausts. A compact cabin and broad deck preserve its old racing-car silhouette. |
| Gulf | 21 | 9.657 × 4.681 × 3.475 | .612 | Tall hatchback, near-upright tailgate, chunky pillars, long side glazing, simple inset disc rims and pair of exhausts. Do not inherit a supercar roof taper. |
| Hurik | 26 | 10.370 × 4.974 × 2.591 | .591 | Distinctive paired tall lamps, curved cabin interpreted with facets, dark lower flank, sculpted rear diffuser and compact rear light clusters. |
| HurikZ | 33 | 10.277 × 4.930 × 2.771 | .594 | More aero-heavy Hurik-related profile, roof scoop, strong contrasting stripe and larger rear wing. Added parts serve visible aero/colour breaks, not uniform subdivision. |
| Jergo | 27 | 9.522 × 4.406 × 2.580 | .591 | Low light-coloured body, contrasting bonnet insert, long angular lower side boundary and tall wing with dark ends. Side and rear need their own contour language. |
| RS3GT | 29 | 10.017 × 4.381 × 2.987 | .539 | High rounded coupe cabin, red rims, round front lamps, bonnet vents and very tall rear wing. Overall height includes aero; do not equate it to cabin height. |
| Spali | 23 | 9.844 × 4.224 × 2.287 | .589 | Open-wheel single-seater: narrow centre body, separate nose/front wing, exposed tires, side pods and tall rear wing. Extra Root and weld structure; lacks the shared blue-window palette. It is not a closed-body recipe. |
| Supre | 23 | 10.016 × 4.568 × 2.657 | .559 | Long bonnet, short arched cabin, pointed centre nose, slim swept lamps, three strong intake regions, simple broad door surface and paired exhausts. Best detailed example for panel/material separation. |
| Tribitti | 23 | 9.506 × 4.216 × 2.240 | .596 | Extreme low track silhouette, blue glazing/accents, cross-like white lamp graphic, angular fenders, high rear aero and large rear negative space. Recognizable light graphic survives reduction. |
| TuboS | 23 | 10.195 × 4.566 × 2.957 | .538 | Round-lamp coupe with continuous rounded roof falloff, long rear-quarter glazing, horizontal rear light band and simple dual exhaust arrangement. Avoid a flat-box roof. |
| W2 | 20 | 10.016 × 4.329 × 2.451 | .583 | Low teardrop cabin, hooked/swept thin front lamps, large side scoop and very dark rear diffuser. Use large controlled curves translated to a few planes. |
| Zondik | 28 | 9.489 × 4.745 × 2.451 | .632 | Short rounded cabin, paired circular lamp elements, side strip, wing, stacked red circular rear lamps and central exhaust cluster. Wheelbase occupies much more of length than TuboS. |
| ZondikR | 33 | 9.753 × 4.901 × 2.655 | .615 | Track-oriented Zondik relation, larger wing with supports, broad front splitter, longer dark aero surfaces and accent stripe. Preserve common family shape while changing visible aero. |

## Detailed separation example: Supre

23 MeshParts = four tires + four rims + two exhaust shells + two dark exhaust ends + eleven body/trim/glazing/light groups. A single group can contain multiple disconnected visible islands.

- `ToyotaSupraMK5_Cube (1)` is the main #660000 paint MeshPart, local box 9.866 × 2.526 × 3.927. Its local axes differ from world car-width/length axes.
- `.001 (1)` and `.010 (1)` use blue glazing with Reflectance .5. `.001` spans a broad set of glazing regions; do not call its full Size a single windshield dimension.
- `.004 (1)` is the front lamp group: Neon #B3B4BA, local box 1.096 × .361 × 3.657. `.002` is the rear Neon #FF5959 group. A lamp-pair group width includes its central gap.
- `.003`, `.007`, `.008` are darkest recess groups; `.005`, `.006`, `.009` are #37383E trim/aero groups.
- Tire local box approximately 1.359 × .663 × 1.429, rim 1.016 × .206 × 1.069. Four repeats share source assets, with distinct placements. The source tire cross-section and authored rim topology remain UNMEASURED.

## Comparison selection

For a new compact road car: begin with BimmerN2 + Gulf for cabin/volume contrast; use Supre only for the lamp/intake finish. For a front-engine coupe: Supre + Curvett. For a low exotic: Agro/D1/W2 with the appropriate roof placement. For an open-wheel car: Spali. A new family SUV has no direct equivalent in this pack; use the grammar and explicitly design its missing class proportions.

Do not use brand recognition as a substitute for construction analysis. The atlas names are the actual local Model names. A new design should use its own identity and the user's chosen feature requirements.
