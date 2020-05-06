// Approach reference
// https://developer.nvidia.com/gpugems/gpugems/part-i-natural-effects/chapter-1-effective-water-simulation-physical-models

// Normal textures
uniform mat4 textureMatrix;

// User-specified first wave
uniform float direction;
uniform float frequency;
uniform float amplitude;
uniform float steepness;
uniform float speed;

// Additional coefficients stored in texture
uniform int wavesToAdd;
uniform sampler2D coefficientSampler;

// Simulation step
uniform float time;

varying vec4 mirrorCoord;
varying vec4 worldPosition;
varying vec3 vvnormal;
#include <fog_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>

const int NB_WAVES = 16;

void addWave(
    float x, float y,
    float frequencyI, float amplitudeI, float steepnessI, float directionI, float phaseI,
    inout vec3 o, bool doIt
)
{
    if (!doIt) return;
    vec2 d = vec2(cos(directionI), sin(directionI));
    float s = steepnessI / (clamp(amplitudeI, 0.01, 1e7) * frequencyI);
    float sa = s * amplitudeI;
    float fdotpht = frequencyI * dot(d, vec2(x, y)) + phaseI * time;
    float sacf = sa * cos(fdotpht);
    o.x += d.x * sacf;
    o.y += d.y * sacf;
    o.z += amplitudeI * sin(fdotpht);
}

void addWaveNormal(
    float x, float y,
    float frequencyI, float amplitudeI, float steepnessI, float directionI, float phaseI,
    vec3 p, inout vec3 n, bool doIt
)
{
    if (!doIt) return;
    vec2 d = vec2(cos(directionI), sin(directionI));
    float s = steepnessI / (clamp(amplitudeI, 0.01, 1e7) * frequencyI);
    float fa = frequencyI * amplitudeI;
    float fdpt = frequencyI * dot(vec3(d, 0.0), p) + phaseI * time;
    float facf = fa * cos(fdpt);
    n.x -= (d.x * facf );
    n.y -= (d.y * facf );
    n.z -= (s * fa * sin(fdpt) );
}

vec3 gerstnerPositions(float x, float y)
{
    vec3 o = vec3(x, y, 0.0);

    addWave(x, y, frequency, amplitude, steepness, direction, speed, o, wavesToAdd < 1);

    float tx = 0.0; float ty = 0.0;
    for (int i = 0; i < NB_WAVES; i++)
    {
        if (i >= wavesToAdd) break;
        tx++; if (tx > 7.0) { tx = 0.0; ty++; }
        vec4 rgb1 = texture2D(coefficientSampler, vec2(tx + 0.01, ty + 0.01) / 8.0);
        tx++; if (tx > 7.0) { tx = 0.0; ty++; }
        vec4 rgb2 = texture2D(coefficientSampler, vec2(tx + 0.01, ty + 0.01) / 8.0);
        float directionI = float(rgb1.r) * 2.0 * 3.1415;
        float frequencyI = float(rgb1.g) * 0.4;
        float amplitudeI = float(rgb1.b) * 40.0;
        float steepnessI = float(rgb2.r) * 1.0;
        float phaseI     = float(rgb2.g) * 5.0;
        addWave(x, y, frequencyI, amplitudeI, steepnessI, directionI, phaseI, o, true); // i == wavesToAdd - 1);
    }

    return o;
}

vec3 gerstnerNormals(float x, float y, vec3 p)
{
    vec3 n = vec3(0.0, 0.0, 1.0);

    addWaveNormal(x, y, frequency, amplitude, steepness, direction, speed, p, n, wavesToAdd < 1);

    float tx = 0.0; float ty = 0.0;
    for (int i = 0; i < NB_WAVES; i++)
    {
        if (i >= wavesToAdd) break;
        tx++; if (tx > 7.0) { tx = 0.0; ty++; }
        vec4 rgb1 = texture2D(coefficientSampler, vec2(tx + 0.01, ty + 0.01) / 8.0);
        tx++; if (tx > 7.0) { tx = 0.0; ty++; }
        vec4 rgb2 = texture2D(coefficientSampler, vec2(tx + 0.01, ty + 0.01) / 8.0);
        float directionI = float(rgb1.r) * 2.0 * 3.1415;
        float frequencyI = float(rgb1.g) * 0.1;
        float amplitudeI = float(rgb1.b) * 40.0;
        float steepnessI = float(rgb2.r) * 1.0;
        float phaseI     = float(rgb2.g) * 5.0;
        addWaveNormal(x, y, frequencyI, amplitudeI, steepnessI, directionI, phaseI, p, n, true); // i == wavesToAdd - 1);
    }

    return n;
}

void main()
{
    mirrorCoord = modelMatrix * vec4( position, 1.0 );
    worldPosition = mirrorCoord.xyzw;
    mirrorCoord = textureMatrix * mirrorCoord;
    vec4 mvPosition =  modelViewMatrix * vec4( position, 1.0 );

    // this is how to use gerstner
    vec3 newPo = gerstnerPositions(position.x, position.y);
    vec3 gn = gerstnerNormals(position.x, position.y, newPo);
    vvnormal = normalMatrix * gn;
    mvPosition = modelViewMatrix * vec4(newPo.x, newPo.y, newPo.z, 1.0);

    gl_Position = projectionMatrix * mvPosition;

    #include <logdepthbuf_vertex>
    #include <fog_vertex>
    #include <shadowmap_vertex>
}
