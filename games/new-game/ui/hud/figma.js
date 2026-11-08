// Figma renderer for spec.js. build.sh joins spec.js + this file into
// figma-plugin/code.js. Run it in Figma desktop: Plugins > Development >
// Import plugin from manifest, then run "New Game HUD (LihFolk)".

const FRAME_NAME = "HUD – Phone 667×375 (LihFolk UI)";
const COMP_FRAME = "LihFolk Components";
const OLD_NAMES = ["HUD – Phone landscape (667×375 @2x)", "Components", "daily"];
const errors = [];
let F = {};

const rgb = (h) => { const c = hexRgb(h); return { r: c[0] / 255, g: c[1] / 255, b: c[2] / 255 }; };
function paints(n) {
  if (n.grad) return [{ type: "GRADIENT_LINEAR", gradientTransform: [[0, 1, 0], [-1, 0, 1]],
    gradientStops: n.grad.map(([p, c]) => ({ position: p, color: Object.assign(rgb(c), { a: 1 }) })) }];
  if (n.fill) return [{ type: "SOLID", color: rgb(n.fill), opacity: n.fillOpacity == null ? 1 : n.fillOpacity }];
  return [];
}

async function pickFonts() {
  const av = await figma.listAvailableFontsAsync();
  const has = (f, s) => av.some((a) => a.fontName.family === f && a.fontName.style === s);
  const first = (list, fallback) => { const hit = list.find(([f, s]) => has(f, s)) || fallback; return { family: hit[0], style: hit[1] }; };
  // Builder Sans ships with Roblox only; Nunito Sans is the closest common stand-in.
  F = {
    display: first([["Fredoka One", "Regular"], ["Fredoka", "Bold"], ["Fredoka", "SemiBold"]], ["Inter", "Bold"]),
    bodyBold: first([["Builder Sans", "Bold"], ["Nunito Sans", "Bold"]], ["Inter", "Bold"]),
    caption: first([["Builder Sans", "SemiBold"], ["Builder Sans", "Semi Bold"], ["Nunito Sans", "SemiBold"], ["Nunito Sans", "Semi Bold"]], ["Inter", "Semi Bold"]),
  };
  for (const k of Object.keys(F)) await figma.loadFontAsync(F[k]);
}

function place(node, n, parent) {
  parent.appendChild(node);
  node.name = n.name;
  node.x = n.x;
  node.y = n.y;
}

function styleText(t, n) {
  t.fontName = F[n.font];
  t.characters = n.str;
  t.fontSize = n.size;
  t.fills = [{ type: "SOLID", color: rgb(n.color) }];
  t.textAutoResize = "NONE";
  t.resize(n.w, n.h);
  t.textAlignHorizontal = n.align === "center" ? "CENTER" : "LEFT";
  t.textAlignVertical = "CENTER";
  try { t.textTruncation = "ENDING"; t.maxLines = 1; } catch (e) { /* older API */ }
  if (n.stroke) {
    t.strokes = [{ type: "SOLID", color: rgb(T.ink) }];
    t.strokeWeight = n.stroke;
    try { t.strokeAlign = "OUTSIDE"; } catch (e) { errors.push("text stroke align: " + e.message); }
  }
}

const masters = {};
let compFrame = null;

function build(n, parent) {
  if (n.inst) return buildInstance(n, parent);
  let node;
  if (n.type === "box") {
    node = figma.createFrame();
    place(node, n, parent);
    node.resize(Math.max(n.w, 0.01), Math.max(n.h, 0.01));
    node.fills = paints(n);
    node.clipsContent = !!n.clip;
    if (n.radius) node.cornerRadius = n.radius;
    if (n.stroke) {
      node.strokes = [{ type: "SOLID", color: rgb(n.stroke[0]) }];
      node.strokeWeight = n.stroke[1];
      node.strokeAlign = "INSIDE";
      if (n.dash) node.dashPattern = [6, 4];
    }
    if (n.opacity != null) node.opacity = n.opacity;
    for (const c of n.children || []) build(c, node);
  } else if (n.type === "text") {
    node = figma.createText();
    place(node, n, parent);
    styleText(node, n);
  } else if (n.type === "svg") {
    node = figma.createNodeFromSvg(n.markup.replace('width="64" height="64"', `width="${n.w}" height="${n.h}"`));
    place(node, n, parent);
    node.resize(n.w, n.h);
  }
  return node;
}

// Reusable pieces become one main component plus instances with overrides.
function buildInstance(n, parent) {
  let comp = masters[n.inst];
  if (!comp) {
    const frame = build(Object.assign({}, n, { inst: null, x: 24 + Object.keys(masters).length * 100, y: 24 }), compFrame);
    comp = figma.createComponentFromNode(frame);
    comp.name = "LihFolk/" + n.inst;
    comp.description = "LihFolk UI HudButton: 64 slab in the menu theme colour, lip 5, fallback icon (shape + glyph), Fredoka small caption. Override Face/Base fills, icon and caption per menu.";
    masters[n.inst] = comp;
  }
  const inst = comp.createInstance();
  place(inst, n, parent);
  override(n, inst);
  return inst;
}

function override(s, node) {
  try {
    if (s.type === "box") {
      node.fills = paints(s);
      if (s.radius != null && node.cornerRadius !== s.radius) node.cornerRadius = s.radius;
      if (Math.abs(node.width - s.w) > 0.5 || Math.abs(node.height - s.h) > 0.5) node.resize(s.w, s.h);
    } else if (s.type === "text") {
      if (node.characters !== s.str) node.characters = s.str;
      node.fills = [{ type: "SOLID", color: rgb(s.color) }];
      if (node.fontSize !== s.size) node.fontSize = s.size;
    }
  } catch (e) {
    errors.push(s.name + ": " + e.message);
  }
  const kids = s.children || [];
  if ("children" in node) kids.forEach((c, i) => { if (node.children[i]) override(c, node.children[i]); });
}

async function main() {
  await pickFonts();
  const page = figma.currentPage;

  // Keep the earlier C3-style sample on an Archive page instead of deleting it.
  const old = page.children.filter((c) => OLD_NAMES.includes(c.name));
  if (old.length) {
    let archive = figma.root.children.find((p) => p.name === "Archive");
    if (!archive) { archive = figma.createPage(); archive.name = "Archive"; }
    for (const c of old) archive.appendChild(c);
  }
  // Re-running replaces only what this plugin made.
  for (const c of page.children.filter((c) => c.name === FRAME_NAME || c.name === COMP_FRAME)) c.remove();

  compFrame = figma.createFrame();
  page.appendChild(compFrame);
  compFrame.name = COMP_FRAME;
  compFrame.resize(260, 140);
  compFrame.x = 100;
  compFrame.y = 520;
  compFrame.fills = [{ type: "SOLID", color: rgb(T.dusk) }];

  const spec = buildSpec();
  const frame = build(Object.assign({}, spec, { x: 100, y: 100 }), page);
  for (const name of ["skip_world_preview", "skip_safe_area"]) {
    const g = frame.findOne((c) => c.name === name);
    if (g) g.locked = true;
  }

  figma.viewport.scrollAndZoomIntoView([frame, compFrame]);
  const fonts = Object.values(F).map((f) => f.family + " " + f.style).join(", ");
  const msg = errors.length ? `HUD built with ${errors.length} warning(s): ${errors.slice(0, 3).join(" | ")}` : `HUD built. Fonts: ${fonts}`;
  figma.closePlugin(msg);
}

main().catch((e) => figma.closePlugin("Error: " + e.message));
