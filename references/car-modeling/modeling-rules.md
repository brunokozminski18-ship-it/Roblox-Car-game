# Modeling rules for Car Pack vehicles

- Set body, glazing and wheel centres from the closest measured vehicle class in the atlas. Preserve the original low-poly crease pattern wherever it can be observed.
- Keep the lamp lens, its dark recess, the orange shell, hood inserts and bumper lip independently editable. D1's separate material boundaries make their mutual occlusion measurable.
- For local surface corrections, fit a plane only where 32 neighbouring depth samples support one dominant plane. Lock part bounds. Test half and full movement separately. In D1, the door intake benefited from half movement, and the rear crossbar benefited from full movement.
- For visible door, shell and window boundaries, register material masks in several calibrated views. Constrain vertex motion in each camera's image plane and bound the total displacement. In D1 the tested bound was 0.045 studs. Use per-part ray and assembled-render checks before reusing this value.
- Keep the last verified wheel profile and rim geometry when a body pass provides no new wheel evidence. Check axle positions, outer diameter and side silhouette in the body frame. See the measured wheel script in the D1 case.
- When a lens disappears at a body crease, cast rays through the verified bright reference pixels into the independent reconstruction. Test moving only nearby support triangles when they lie directly ahead of the lens. D1 front and rear supports reacted differently to the same change. Restore both the insert and its adjoining support when rolling back.

See [the D1 lessons](lessons-learned.md) for measured outcomes and scope.
