// Bolo 3D voice orb, a GPU fragment shader.
//
// It looks 3D but is cheap: instead of ray-marching, we intersect a sphere
// analytically per pixel, perturb its normal with animated waves, and light
// it (diffuse + specular + fresnel rim). The silhouette wobbles with the
// microphone level. Works on Impeller (Vulkan / OpenGL ES).
#include <flutter/runtime_effect.glsl>

precision mediump float;

uniform vec2 uSize;     // widget size in pixels
uniform float uTime;    // seconds
uniform float uLevel;   // 0..1 microphone loudness (smoothed)
uniform float uState;   // 0 idle, 1 listening, 2 thinking
uniform vec3 uColorA;   // primary colour (linear-ish RGB 0..1)
uniform vec3 uColorB;   // secondary colour

out vec4 fragColor;

void main() {
  vec2 frag = FlutterFragCoord().xy;
  float s = min(uSize.x, uSize.y);
  vec2 uv = (frag - 0.5 * uSize) / s * 2.0;   // -1..1, square
  uv.y = -uv.y;

  float t = uTime * (uState > 1.5 ? 2.2 : 1.0);
  float energy = clamp(uLevel, 0.0, 1.0) * step(0.5, uState) + (uState > 1.5 ? 0.35 : 0.0);

  // Breathing radius + wobbly silhouette driven by voice energy.
  float baseR = 0.58 + 0.015 * sin(uTime * 1.6) + 0.06 * energy;
  float ang = atan(uv.y, uv.x);
  float wob = (0.012 + 0.07 * energy) * sin(ang * 3.0 + t * 2.1) * sin(ang * 5.0 - t * 1.4);
  float r = baseR + wob;
  float d = length(uv);

  // Outer glow (halo), stronger while listening.
  float halo = exp(-max(d - r, 0.0) * 5.5) * (0.28 + 0.55 * energy);
  vec3 haloCol = mix(uColorA, uColorB, 0.5 + 0.5 * sin(ang + t * 0.5));

  if (d >= r) {
    float a = clamp(halo, 0.0, 1.0);
    fragColor = vec4(haloCol * a, a);
    return;
  }

  // Analytic sphere surface: z from x,y.
  float z = sqrt(max(r * r - d * d, 0.0));
  vec3 n = normalize(vec3(uv, z));

  // Animated "liquid" bands across the surface.
  float bands = sin(n.x * 5.0 + t * 1.3) * sin(n.y * 6.0 - t * 1.1) * sin(n.z * 4.0 + t * 0.9);
  vec3 pn = normalize(n + 0.18 * vec3(
      sin(n.y * 7.0 + t * 1.7),
      sin(n.z * 7.0 - t * 1.3),
      sin(n.x * 7.0 + t * 1.1)) * (0.4 + energy));

  vec3 light = normalize(vec3(-0.45, 0.6, 0.75));
  float diff = max(dot(pn, light), 0.0);
  vec3 refl = reflect(-light, pn);
  float spec = pow(max(refl.z, 0.0), 28.0);
  float fres = pow(1.0 - clamp(n.z, 0.0, 1.0), 2.2);

  vec3 base = mix(uColorA, uColorB, 0.5 + 0.5 * bands);
  vec3 col = base * (0.30 + 0.85 * diff)
           + vec3(1.0) * spec * 0.75
           + uColorB * fres * (0.9 + 0.8 * energy);

  // Inner core glow.
  col += uColorA * 0.35 * exp(-d * 3.0) * (0.5 + energy);

  // Anti-aliased edge.
  float edge = smoothstep(r, r - 0.012, d);
  float a = edge + (1.0 - edge) * halo;
  vec3 outCol = col * edge + haloCol * halo * (1.0 - edge);
  fragColor = vec4(outCol, clamp(a, 0.0, 1.0));
}
