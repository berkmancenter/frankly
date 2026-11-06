/**
 * Deterministic placeholder artwork so the fake backend never needs the network.
 * Returns a `data:` URI SVG: a two-stop gradient keyed by `seed`, with an optional glyph.
 */
const PALETTES: [string, string][] = [
  ['#203EA0', '#6FA8FF'],
  ['#006442', '#76F1A4'],
  ['#660D6B', '#F4A6F7'],
  ['#900E2D', '#FF9A8B'],
  ['#320243', '#FFA800'],
  ['#001D58', '#8FD3FF'],
  ['#0F200F', '#B6E388'],
  ['#222222', '#9AA0A6'],
];

function hash(seed: string): number {
  let h = 2166136261;
  for (let i = 0; i < seed.length; i += 1) {
    h ^= seed.charCodeAt(i);
    h = Math.imul(h, 16777619);
  }
  return h >>> 0;
}

export function placeholderImage(seed: string, glyph?: string, size = 400): string {
  const [a, b] = PALETTES[hash(seed) % PALETTES.length]!;
  const angle = hash(`${seed}:angle`) % 360;
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${size}" height="${size}" viewBox="0 0 ${size} ${size}">
<defs><linearGradient id="g" gradientTransform="rotate(${angle} .5 .5)"><stop offset="0" stop-color="${a}"/><stop offset="1" stop-color="${b}"/></linearGradient></defs>
<rect width="100%" height="100%" fill="url(#g)"/>
<circle cx="${size * 0.8}" cy="${size * 0.2}" r="${size * 0.28}" fill="#fff" fill-opacity=".10"/>
<circle cx="${size * 0.15}" cy="${size * 0.9}" r="${size * 0.34}" fill="#000" fill-opacity=".10"/>
${glyph ? `<text x="50%" y="55%" font-size="${size * 0.34}" text-anchor="middle" dominant-baseline="middle">${glyph}</text>` : ''}
</svg>`;
  return `data:image/svg+xml;utf8,${encodeURIComponent(svg)}`;
}
