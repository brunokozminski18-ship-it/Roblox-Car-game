// HUD sample for "New Game" (Steal An Egg style), LihFolk UI "Ink and Candy".
// One spec feeds both preview.html and the Figma plugin (code.js), so the
// preview cannot drift from what lands in Figma.
// Sizes are LihFolk design units; on a phone the base scale is 1.0, so this
// 667 x 375 frame is the phone at 1 unit = 1 px (LihFolk UI Spec, section 6).
// Tokens copied from skills/lihfolk-ui/src/LihFolkUITheme.luau (LihFolk V2.5.0).

const T = {
  ink: "#160F2B", dusk: "#2D2852", duskRaised: "#3B3566", duskRaisedHi: "#4A437A",
  duskSunken: "#1F1B3D", textHi: "#FFFFFF", textMid: "#D6D0F5", textLow: "#B0A9DD",
  positive: "#7BF5A6", gold: "#FFD24A",
};
const MENU = {
  shop: ["#FFB54D", "#FF7B22", "#B9480A"], codes: ["#5DEBDB", "#18B5C6", "#0C6F80"],
  rebirth: ["#CF9BFF", "#9257F2", "#5A2AAE"], settings: ["#86AEFF", "#4F7BEA", "#2B4CA3"],
  daily: ["#FF9ACD", "#F25AA2", "#A82568"], neutral: ["#9C94DB", "#6E66B3", "#40397A"],
};
const ROLE = {
  go: ["#7BF5A6", "#25C773", "#12804A"], danger: ["#FF7A98", "#EE3D66", "#9A1838"],
  info: ["#7CC8FF", "#3D93F0", "#1D58A8"], premium: ["#FFE27A", "#FFB224", "#B06B00"],
};
// Icon fallbacks from LihFolkUIIcons.luau (shape + glyph until art exists).
const ICON = {
  shop: ["$", "square", MENU.shop[1]], codes: ["#", "square", MENU.codes[1]],
  rebirth: ["R", "square", MENU.rebirth[1]], settings: ["=", "square", MENU.settings[1]],
  daily: ["7", "square", MENU.daily[1]], pet: ["P", "circle", MENU.rebirth[1]],
  coin: ["C", "circle", "#FFC21F"], boost: [">>", "circle", ROLE.info[1]],
};

const hexRgb = (h) => [1, 3, 5].map((i) => parseInt(h.slice(i, i + 2), 16));
const rgbHex = (c) => "#" + c.map((v) => Math.round(v).toString(16).padStart(2, "0")).join("").toUpperCase();
const lerp = (a, b, t) => { const x = hexRgb(a), y = hexRgb(b); return rgbHex(x.map((v, i) => v + (y[i] - v) * t)); };
// Face gradient: top, 55% mix at 45% height, bottom (Theme.faceSequence).
const face = (sw) => [[0, sw[0]], [0.45, lerp(sw[0], sw[1], 0.55)], [1, sw[1]]];

const box = (name, x, y, w, h, o = {}, children = []) => ({ type: "box", name, x, y, w, h, ...o, children });
const text = (name, x, y, w, h, str, o = {}) => ({ type: "text", name, x, y, w, h, str, ...o });
const svg = (name, x, y, s, markup) => ({ type: "svg", name, x, y, w: s, h: s, markup });
// Fredoka One for display styles, Builder Sans for body and captions (Spec, section 4).
const display = (size, color = T.textHi, o = {}) => ({ font: "display", size, color, stroke: Math.round(size * 0.1 * 2) / 2, ...o });
const caption = (color = T.textMid, o = {}) => ({ font: "caption", size: 15, color, ...o });

function icon(name, x, y, s) {
  const [glyph, shape, color] = ICON[name];
  const inner = shape === "square" ? Math.round(s * 0.9) : s;
  const off = (s - inner) / 2;
  return box("Icon_" + name, x, y, s, s, {}, [
    box("Shape", off, off, inner, inner, {
      grad: [[0, lerp(color, "#FFFFFF", 0.35)], [1, color]],
      radius: shape === "square" ? inner * 0.28 : inner / 2, stroke: [T.ink, 2.5],
    }),
    text("Glyph", 0, 0, s, s, glyph, display(Math.round(s * (glyph.length > 1 ? 0.42 : 0.56)), "#FFFFFF", { stroke: 2, align: "center" })),
  ]);
}

// HudButton: 64 slab in the menu colour, lip 5 (depthSmall + 1), caption below.
function hudButton(theme, label, iconName, x, y) {
  const sw = MENU[theme];
  return box("Hud_" + label, x, y, 64, 86, { inst: "HudButton" }, [
    box("Base", 0, 0, 64, 64, { fill: sw[2], radius: 12, stroke: [T.ink, 3] }),
    box("Face", 0, 0, 64, 59, { grad: face(sw), radius: 12, stroke: [T.ink, 3] }, [icon(iconName, 13, 10, 38)]),
    text("Caption", -8, 64, 80, 22, label, display(18, T.textHi, { align: "center" })),
  ]);
}

// Glossy icon (Glossy Icon Style - Owner Reference): navy ink, crisp two-tone split,
// specular streak that fades halfway, tip glint, bounce rim, light from top left.
const EGG_SVG = `<svg width="64" height="64" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">
<path d="M32 5 C45 5 54 25 54 39 C54 52 44 59 32 59 C20 59 10 52 10 39 C10 25 19 5 32 5 Z" fill="#A6EBFF"/>
<path d="M36 5.6 C47 9 54 27 54 39 C54 52 44 59 32 59 C30 59 28 58.8 26 58.4 C40 54 45 36 36 5.6 Z" fill="#55B6EA"/>
<circle cx="22" cy="30" r="4.5" fill="#F2FDFF"/><circle cx="29" cy="45" r="3.5" fill="#F2FDFF"/><circle cx="44" cy="36" r="4" fill="#A9E4FF"/>
<path d="M49 29 C52 37 52 46 47 52" fill="none" stroke="#D2F3FF" stroke-width="1.6" stroke-linecap="round"/>
<path d="M25 11 C20 17 16 25 15 33" fill="none" stroke="#FFFFFF" stroke-width="3.4" stroke-linecap="round" opacity="0.95"/>
<circle cx="29" cy="8.6" r="2" fill="#FFFFFF"/>
<path d="M32 5 C45 5 54 25 54 39 C54 52 44 59 32 59 C20 59 10 52 10 39 C10 25 19 5 32 5 Z" fill="none" stroke="#1C2440" stroke-width="4"/>
</svg>`;

function buildSpec() {
  const W = 667, H = 375;
  // Safe area for a notched phone in landscape (Designing Roblox UI in Figma, section 2).
  const S = { l: 59, r: W - 59, t: 48, b: H - 20 };
  const m = 16; // HUD launcher margin (Spec, section 6)

  const world = box("skip_world_preview", 0, 0, W, H, { grad: [[0, "#8ED2FF"], [1, "#D4F0FF"]] }, [
    box("Ground", 0, 228, W, H - 228, { grad: [[0, "#7AD66A"], [1, "#4FAB48"]] }),
    box("Ice biome", 250, 214, 170, 18, { fill: "#E3F6FF", radius: 6 }),
    box("Gate pillar L", 288, 196, 12, 56, { fill: "#8E97A6", stroke: [T.ink, 2] }),
    box("Gate pillar R", 368, 196, 12, 56, { fill: "#8E97A6", stroke: [T.ink, 2] }),
    box("Gate barrier", 300, 202, 68, 50, { fill: "#7CC8FF", opacity: 0.5 }),
    box("BillboardGui gate sign", 262, 172, 144, 24, { fill: T.dusk, radius: 12, stroke: [T.ink, 2.5] }, [
      icon("boost", 3, 3, 18),
      text("Need", 26, 0, 114, 24, "Needs 60 Speed", caption(T.gold, { font: "bodyBold", align: "left" })),
    ]),
    box("Player body", 324, 282, 18, 22, { fill: "#C9CED6", radius: 3, stroke: [T.ink, 2] }),
    box("Player head", 327, 268, 12, 13, { fill: "#F2D3A6", radius: 3, stroke: [T.ink, 2] }),
    box("Player legs", 326, 304, 14, 16, { fill: "#596273", radius: 2, stroke: [T.ink, 2] }),
    svg("Held egg", 322, 244, 22, EGG_SVG),
    svg("Ground egg", 120, 246, 20, EGG_SVG),
    svg("Ground egg", 150, 254, 16, EGG_SVG),
    svg("Ground egg", 470, 250, 20, EGG_SVG),
  ]);

  const hud = box("HUD", 0, 0, W, H, {}, []);
  const k = hud.children;

  // Left rail: 2 x 2 HudButtons, kept above the thumbstick on phones (HUD Design, section 5).
  const lx = S.l + m, ty = S.t + 12;
  k.push(hudButton("shop", "Shop", "shop", lx, ty));
  k.push(hudButton("neutral", "Pets", "pet", lx + 72, ty));
  k.push(hudButton("daily", "Daily", "daily", lx, ty + 94));
  k.push(hudButton("rebirth", "Rebirth", "rebirth", lx + 72, ty + 94));
  // "!" badge: colour plus glyph so it reads without colour vision.
  k.push(box("Badge Daily", lx + 48, ty + 94 - 12, 24, 24, { fill: ROLE.danger[1], radius: 12, stroke: [T.ink, 2.5] }, [
    text("Glyph", 0, 0, 24, 24, "!", display(16, "#FFFFFF", { stroke: 2, align: "center" })),
  ]));

  // Right column: secondary menus fold to the top right on phones.
  const rx = S.r - m - 64;
  k.push(hudButton("codes", "Codes", "codes", rx, ty));
  k.push(hudButton("settings", "Settings", "settings", rx, ty + 94));

  // Top centre: status (money with rate, speed). Speed gates biomes, so it stays visible.
  const pillY = S.t + 8, moneyW = 128, speedW = 96, gap = 8;
  const px0 = Math.round(W / 2 - (moneyW + gap + speedW) / 2);
  k.push(box("Money", px0, pillY, moneyW, 48, { fill: T.dusk, radius: 24, stroke: [T.ink, 3] }, [
    icon("coin", 6, 9, 30),
    text("Amount", 42, 4, 76, 24, "$12.5K", display(20, T.textHi, { align: "left" })),
    text("Rate", 42, 26, 76, 18, "+45/s", caption(T.positive, { font: "bodyBold", align: "left" })),
  ]));
  k.push(box("Speed", px0 + moneyW + gap, pillY, speedW, 48, { fill: T.dusk, radius: 24, stroke: [T.ink, 3] }, [
    icon("boost", 6, 9, 30),
    text("Amount", 42, 4, 48, 24, "48", display(20, T.textHi, { align: "left" })),
    text("Label", 42, 26, 50, 18, "Speed", caption(T.textLow, { align: "left" })),
  ]));

  // Carry card: short-lived state while holding an egg (Card: duskRaisedHi -> duskRaised, ink 3, r14).
  k.push(box("Carry card (state: carrying)", px0, pillY + 56, moneyW + gap + speedW, 56,
    { grad: [[0, T.duskRaisedHi], [1, T.duskRaised]], radius: 14, stroke: [T.ink, 3] }, [
      svg("Egg", 8, 8, 40, EGG_SVG),
      text("Title", 54, 7, 104, 24, "Frost Egg", display(20, T.textHi, { align: "left" })),
      text("Hint", 54, 31, 100, 18, "Run home!", caption(T.textMid, { align: "left" })),
      text("Distance", 172, 7, 52, 24, "48m", display(22, T.gold, { align: "center" })),
      text("To", 168, 31, 60, 18, "to pen", caption(T.textLow, { align: "center" })),
    ]));

  // Bottom centre: the one green action with a verb (Design System, section 5: U1 clarity).
  const penW = 256, penH = 64, penX = Math.round(W / 2 - penW / 2), penY = S.b - 4 - penH;
  k.push(box("Toast steal alert", Math.round(W / 2 - 110), penY - 44, 220, 36,
    { grad: face(ROLE.danger), radius: 18, stroke: [T.ink, 3] }, [
      box("Bang", 6, 5, 26, 26, { fill: "#FFFFFF", radius: 13, stroke: [T.ink, 2.5] }, [
        text("Glyph", 0, 0, 26, 26, "!", display(18, ROLE.danger[1], { stroke: 0, align: "center" })),
      ]),
      text("Message", 38, 0, 176, 36, "Thief in your pen!", display(18, T.textHi, { align: "left" })),
    ]));
  k.push(box("Pen bar", penX, penY, penW, penH, { grad: [[0, T.duskRaisedHi], [1, T.duskRaised]], radius: 14, stroke: [T.ink, 3] }, [
    text("Caption", 14, 10, 110, 18, "Your Pen", caption(T.textLow, { align: "left" })),
    text("Count", 14, 28, 112, 26, "5 / 8 eggs", display(20, T.textHi, { align: "left" })),
    box("Btn LOCK (go)", penW - 8 - 120, 6, 120, 52, {}, [
      box("Base", 0, 0, 120, 52, { fill: ROLE.go[2], radius: 12, stroke: [T.ink, 3] }),
      box("Face", 0, 0, 120, 46, { grad: face(ROLE.go), radius: 12, stroke: [T.ink, 3] }, [
        text("Label", 0, 0, 120, 46, "LOCK", display(24, T.textHi, { align: "center" })),
      ]),
    ]),
  ]));

  const guide = (name, x, y, w, h, c, r = 0) => box(name, x, y, w, h, { fill: c, fillOpacity: 0.16, stroke: [c, 1.5], dash: true, radius: r });
  const guides = box("skip_safe_area", 0, 0, W, H, { opacity: 0.7 }, [
    guide("Roblox top bar (GuiService.TopbarInset)", 0, 0, W, S.t, "#FF3B6B"),
    guide("Notch inset L", 0, S.t, S.l, H - S.t, "#FFB020"),
    guide("Notch inset R", S.r, S.t, W - S.r, H - S.t, "#FFB020"),
    guide("Home indicator", 0, S.b, W, H - S.b, "#FFB020"),
    guide("Thumbstick", S.l + 20, 265, 90, 90, "#7A5CFF", 45),
    guide("Jump button", S.r - 95, 285, 70, 70, "#7A5CFF", 35),
  ]);

  return box("HUD – Phone 667×375 (LihFolk UI)", 0, 0, W, H, { fill: "#8ED2FF", clip: true }, [world, hud, guides]);
}

if (typeof module !== "undefined") module.exports = { buildSpec };
