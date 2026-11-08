# Validation procedure

1. Check the reference car, part identities, transforms and material groups. Keep the original read-only. Save a separate candidate and the accepted baseline.
2. Capture original and candidate with the same five relative cameras, vertical FOV, viewport dimensions and world-space lighting orientation. Include registered close-ups of the bonnet, lamp, door intake and rear bumper. Exclude unrelated cars from segmentation.
3. For each visible material class, compute intersection over union within the projected part bounds. Inspect the image, front and oblique lamp contours and the gaps between adjoining parts. Record each view separately.
4. Evaluate matched optical rays per part. Record all rays, hits, median and p90 error in studs. Rays used in fitting measure fit to the survey. Separately inspect fresh views and note which views participated in fitting.
5. If the lens moves behind the body, restore its previous contour and evaluate seating against the updated support. Roll back a change that creates a material regression in another view. Keep the metrics of rejected candidates.
6. Reopen the Blender master, export and reimport GLB. Compare mesh count, triangle count and world dimensions. Reopen the local Studio place and repeat the five photos on its persistent display. Check the embedded restore payload and weld targets. A round trip alone cannot verify artistic fidelity.

Runnable D1 scripts include `refine_planes.py`, `fit_boundaries.py`, `seat_details.py`, `ray_audit.py`, and `compare_studio.py` in `D1-reconstruction/scripts`. Optical images and depth calibrations are project-specific inputs.

Use `closeup_review.py` on separate registered cameras to test front and oblique lens silhouettes, side glazing, a rear lens and the bonnet. Use `review_trim.py` for dark door intakes and vents; these are colour-class measurements within projected bounds. Use `check_saved_car.luau` before and after restoring on a disposable copy of the authored model. Keep the reopened project's durable display intact.
