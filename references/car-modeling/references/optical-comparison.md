# Matching a reference car from measured views

Use measurements of a visible reference to develop new geometry. For a new
vehicle, fit its own roofline, track, openings and lamp outlines. Keep the
reference car intact. An optical measurement describes visible surfaces only.

## Capture

1. Record the original parts, transforms, palette, pivots and camera. Capture
   front, front three-quarter, side, rear three-quarter and top. Register the
   two cars to the same physical scale, orientation, FOV and look-at height.
2. Measure isolated presentations of each part in a disposable optical rig.
   Normalize the three part-box axes separately for observation, then undo that
   scaling before judging physical shape. Keep the original asset references
   exclusively in the temporary display. Remove the rig after measurement.
3. Hold out five camera directions from silhouette fitting. Compare each
   material region in the assembled car as well. A visible lamp can have an
   accurate isolated outline and still disappear beneath an adjoining panel.
4. A silhouette intersection fills concavities and can eliminate thin surfaces
   visible from only one side. Use a series of opaque cutting planes to measure
   a depth interval at each visible pixel. On D1, thirty cuts in one image made
   the window openings and rear deck structure measurable.
5. For higher resolution, use two calibrated fog exposures. Photograph a white
   part against black fog and a black part against white fog. Include known
   depth swatches, disable ambient effects for the measurement and restore the
   original lighting afterwards. Correct for perspective and ray length.
   Reject saturated pixels and hold out calibration targets to test the fit.

## Construct and compare

- Treat each recolourable panel as an independent surface in its measured
  box. Build the nose, cabin and adjacent trim in a common car coordinate
  system. View the assembled top and front-three-quarter photos after each
  fit to catch angular gaps, wrong panel depth and trim hidden by paint.
- For D1, isolated axial views show ten straight tyre sides, an outer ring
  on the visible face and a solid inner-facing decagon. The measured opening
  spans about 75% of the outside diameter. The rim has ten repeating sectors,
  a central cap and two different depth profiles per sector. Fit the two
  sector halves independently and repeat that authored profile about the axle.
- Rotate the fitted wheel to the opposite side using the measured relative
  axle frame. Front and rear diameters are measured independently.
- Compute intersection-over-union on reserved projection masks, then inspect
  native Studio renders for panel order, gaps, shading and material boundaries.
  Keep a change only when it improves the intended region. Equal extents or
  a good aggregate score cannot establish geometric identity.
- Verify saved appearance separately. In Studio on 08.11.2026, serialization
  followed by deserialization changed both an object-backed MeshPart and a
  MeshPart built from generated DataModel content to empty MeshContent.
  Store the authored geometry in the deliverable and verify after reopening.

## D1 field evidence

The workspace case is under `references/car-modeling/D1-reconstruction`.
Its calibrated atlas, depth surveys, Blender construction, independent
triangulation, native view comparisons and report define the tested scope.
The original asset vertex order, hidden topology and UVs remain unmeasured.

For cross-car trim, fit a sequence of transverse sections to the survey. On
D1 this reduced the rear crossbar's 90th-percentile depth residual from
0.253 to 0.034 studs. Limit aperture cuts to an observed closed hole.
Carving the entire shell from a single-sided front silhouette removed a
visible portion of the nose. Keep the pre-carve mesh for comparison.

For coplanar hood inserts and lamps, test whether the original photograph
shows the detail at that pixel and whether the new shell blocks it. Adjust
only vertices satisfying both tests. In this D1 fit the displacement limit
was 0.065 studs. Check from opposing views before applying that limit elsewhere.

Run `scripts/blender_surface_error.py` to measure camera-ray coverage and
residual percentiles on a new master. `scripts/studio_persistence_probe.luau`
tests local serialization on an authored part. For a local-only Studio
delivery, a native display can be baked in batches from the authored faces.
Keep the compressed mesh recipe with the model so it can be restored in Edit.
The runnable D1 case and colour-mask comparison scripts are under
`D1-reconstruction/scripts` in the installed skill.
