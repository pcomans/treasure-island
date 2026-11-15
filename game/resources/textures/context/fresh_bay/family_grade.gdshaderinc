// Inputs and output are linear RGB; source_color uniforms/textures decode sRGB.
// Neutral atmospheric veil, no directional illumination baked into scenery.
// The distant art draws unlit, so the time of day reaches it through one factor
// (owner, 2026-11-14), horizon_light: 1 by day, less as the sun sets
// (game/scripts/world/day_light.gd). As it falls the art greys, darkens and fades
// into horizon_haze, the sky's own colour at the horizon (linear), so it reads as
// a hazy silhouette in the sky's hue at sunset and a dark shape at night, not
// daylight's teal hills on a pink sky. By day the art is exactly as drawn.
global uniform float horizon_light;
global uniform vec3 horizon_haze;

vec3 horizon_grade(vec3 color, float distance_m) {
 float value = dot(color, vec3(0.2126, 0.7152, 0.0722));
 vec3 restrained = mix(vec3(value), color, 0.62);
 restrained *= vec3(0.94, 0.98, 1.0);
 float veil = mix(0.035, 0.19, smoothstep(3500.0, 22000.0, distance_m));
 vec3 graded = mix(restrained, vec3(0.19, 0.245, 0.29), veil);
 float dusk = 1.0 - horizon_light;
 if (dusk > 0.0) {
  // Grey three times as fast as it dims, then up to 60 % of the way into a haze at
  // a quarter of the sky's brightness: from 5 degrees to sunset the art's luminance
  // is a quarter to a third of the horizon's behind it, so it reads as a silhouette
  // in the sky's hue (measured 2026-11-15; a haze at 0.7 left it at 0.5 to 0.6 of
  // the horizon's and one at 0.4 at about 0.4, a pale backlit skyline).
  float grey = dot(graded, vec3(0.2126, 0.7152, 0.0722));
  graded = mix(graded, vec3(grey), min(dusk * 3.0, 1.0)) * horizon_light;
  graded = mix(graded, horizon_haze * 0.25, min(dusk * 2.0, 1.0) * 0.6);
 }
 return graded;
}
