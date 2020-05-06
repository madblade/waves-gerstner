uniform sampler2D mirrorSampler;
uniform float alpha;
uniform float time;
uniform float size;
uniform sampler2D normalSampler;
uniform vec3 sunColor;
uniform vec3 sunDirection;
uniform vec3 eye;
uniform vec3 waterColor;
varying vec3 vvnormal;
varying vec4 mirrorCoord;
varying vec4 worldPosition;

vec4 getNoise(vec2 uv)
{
    vec2 uv0 = (uv / 103.0) + vec2(time / 17.0, time / 29.0);
    vec2 uv1 = uv / 107.0-vec2( time / -19.0, time / 31.0);
    vec2 uv2 = uv / vec2(890.70, 980.30) + vec2(time / 101.0, time / 97.0);
    vec2 uv3 = uv / vec2(1091.0, 1027.0) - vec2(time / 109.0, time / -113.0);
    vec4 noise = texture2D(normalSampler, uv0) +
    texture2D(normalSampler, uv1) +
    texture2D(normalSampler, uv2) +
    texture2D(normalSampler, uv3);

    return noise * 0.5 - 1.0;
}

void sunLight(
const vec3 surfaceNormal, const vec3 eyeDirection,
float shiny, float spec, float diffuse,
inout vec3 diffuseColor, inout vec3 specularColor)
{
    vec3 reflection = normalize( reflect(-sunDirection, surfaceNormal) );
    float direction = max( 0.0, dot(eyeDirection, reflection) );
    specularColor += pow(abs(direction), shiny) * sunColor * spec;
    diffuseColor += max( dot(sunDirection, surfaceNormal), 0.0 ) * sunColor * diffuse;
}

    #include <packing>
    #include <bsdfs>
    #include <fog_pars_fragment>
    #include <logdepthbuf_pars_fragment>
    #include <lights_pars_begin>
    #include <shadowmap_pars_fragment>
    #include <shadowmask_pars_fragment>

void main() {

    #include <logdepthbuf_fragment>
    vec4 noise = getNoise( worldPosition.xz * size );
//    	vec3 surfaceNormal = normalize(vvnormal); //normalize( noise.xzy * vec3( 1.5, 1.0, 1.5 ) ); // this for gerstner
    	vec3 surfaceNormal = normalize( vvnormal + noise.xzy * vec3( 1.5, 1.0, 1.5 ) ); // this for mix
//      vec3 surfaceNormal = normalize( noise.xyz * vec3( 1.5, 1.0, 1.5 ) ); // this for texture

    vec3 diffuseLight = vec3(0.0);
    vec3 specularLight = vec3(0.0);

    vec3 worldToEye = eye - worldPosition.xyz;
    vec3 eyeDirection = normalize( worldToEye );
    sunLight( surfaceNormal, eyeDirection, 100.0, 2.0, 0.5, diffuseLight, specularLight );

    float distance = length(worldToEye);

    vec2 distortion = vec2(0);
    vec3 reflectionSample = vec3( texture2D( mirrorSampler, mirrorCoord.xy / mirrorCoord.w) );

    float theta = max( dot( eyeDirection, surfaceNormal ), 0.0 );
    float rf0 = 0.3;
    float reflectance = rf0 + ( 1.0 - rf0 ) * pow( abs( 1.0 - theta ), 5.0 );
    vec3 scatter = max( 0.0, dot( surfaceNormal, eyeDirection ) ) * waterColor;
    vec3 albedo = mix(
        ( sunColor * diffuseLight * 0.3 + scatter ) * getShadowMask(),
        ( vec3( 0.1 ) + reflectionSample * 0.9 + reflectionSample * specularLight ),
        reflectance
    );
    vec3 outgoingLight = albedo;
    gl_FragColor = vec4( outgoingLight, alpha );

    #include <tonemapping_fragment>
    #include <fog_fragment>
}
