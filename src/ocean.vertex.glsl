
uniform mat4 textureMatrix;
uniform float time;

uniform float direction;
uniform float frequency;
uniform float amplitude;
uniform float steepness;
uniform float speed;

varying vec4 mirrorCoord;
varying vec4 worldPosition;

varying vec3 vvnormal;
#include <fog_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>

void addWave(
    float x, float y,
    float frequencyI, float amplitudeI, float steepnessI, vec2 directionI, float phaseI,
    inout vec3 o
)
{
    float sa = steepnessI * amplitudeI;
    float fdotpht = frequencyI * dot(directionI, vec2(x, y)) + phaseI * time;
    float sacf = sa * cos(fdotpht);
    o.x += directionI.x * sacf;
    o.y += directionI.y * sacf;
    o.z += amplitudeI * sin(fdotpht);
}

void addWaveNormal(
    float x, float y,
    float frequencyI, float amplitudeI, float steepnessI, vec2 directionI, float phaseI,
    vec3 p, inout vec3 n
)
{
    float fa = frequencyI * amplitudeI;
    float fdpt = frequencyI * dot(vec3(directionI, 0.0), p) + phaseI * time;
    float facf = fa * cos(fdpt);
    n.x -= (directionI.x * facf );
    n.y -= (directionI.y * facf );
    n.z -= (steepnessI * fa * sin(fdpt) );
}

// Ref. in GPU Gems 1
// https://developer.nvidia.com/gpugems/gpugems/part-i-natural-effects/chapter-1-effective-water-simulation-physical-models
vec3 gerstnerPositions(float x, float y)
{
    vec3 o;
    o.x = x;
    o.y = y;
    o.z = 0.0;
    addWave(x, y, frequency, amplitude, steepness, vec2(cos(direction), sin(direction)), speed, o);

    const int nbWaves = 1;
    for (int i = 0; i < nbWaves; i++)
    {
        float frequencyI = 0.05; // wi
        float amplitudeI = 20.0; // Ai
        float steepnessI = 1.0 / (frequencyI * amplitudeI); // Qi from 0 to 1/wiAi
        vec2 directionI = normalize(vec2(1.0, 0.0));
        float phaseI = 1.0; // phiI
//        addWave(x, y, frequencyI, amplitudeI, steepnessI, directionI, phaseI, o);
    }
    return o;
}

vec3 gerstnerNormals(float x, float y, vec3 p)
{
    vec3 n;
    n.x = 0.0;
    n.y = 0.0;
    n.z = 1.0;

    addWaveNormal(x, y, frequency, amplitude, steepness, vec2(cos(direction), sin(direction)), speed, p, n);
    const int nbWaves = 1;
    for (int i = 0; i < nbWaves; i++) {
        float frequencyI = 0.05; // wi
        float amplitudeI = 20.0; // Ai
        float steepnessI = 1.0 / (frequencyI * amplitudeI); // Qi from 0 to 1/wiAi
        vec2 directionI = normalize(vec2(1.0, 0.0));
        float phaseI = 1.0; // phiI

//        addWaveNormal(x, y, frequencyI, amplitudeI, steepnessI, directionI, phaseI, p, n);
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
