#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    int3 position [[ attribute(0) ]];
    half3 normal [[ attribute(1) ]];
    half2 textureCoords [[ attribute(2) ]];
    ushort textureID [[ attribute(3) ]];
};

struct VertexConstants {
    int3 cameraOrigin;
    float4x4 projectionViewMatrix;
};

struct FragmentIn {
    float4 screenPosition [[ position ]];
    float3 worldPosition;
    half3 normal [[ flat ]];
    half2 textureCoords;
    short textureID [[ flat ]];
};

struct FragmentConstants {
    float3 cameraPos;
    half3 sunDirection;
    float fogDistanceSquared;
    half4 fogColor;
    half4 sunColor;
};

vertex FragmentIn worldVertex(const VertexIn vIn [[ stage_in ]],
                              constant VertexConstants &constants [[ buffer(1) ]]) {
    float3 vertex_pos = float3(vIn.position - constants.cameraOrigin);
    FragmentIn fIn;
    
    fIn.screenPosition = constants.projectionViewMatrix * float4(vertex_pos, 1);
    fIn.worldPosition = vertex_pos;
    fIn.normal = vIn.normal;
    fIn.textureCoords = vIn.textureCoords;
    fIn.textureID = vIn.textureID;
    
    return fIn;
}

fragment half4 worldFragment(FragmentIn fIn [[ stage_in ]],
                             constant FragmentConstants &constants [[ buffer(1) ]],
                             sampler sampler2D [[ sampler(0) ]],
                             texture2d_array<half> textures [[ texture(0) ]]) {
    
    float distFromCameraSqr = distance_squared(fIn.worldPosition, constants.cameraPos);
    float fullFogDistSqr = 0.9 * constants.fogDistanceSquared;
    
    if (distFromCameraSqr > fullFogDistSqr)
        return constants.fogColor;
    
    half4 textureColor = textures.sample(sampler2D, float2(fIn.textureCoords), fIn.textureID);
    half4 color = textureColor * 0.5;

    float sunIntensity = dot(fIn.normal, constants.sunDirection);
    
    if (sunIntensity > 0) {
        color += sunIntensity * constants.sunColor * textureColor;
    }
    
    float fogStartDistSqr = 0.8 * constants.fogDistanceSquared;
    if (distFromCameraSqr < fogStartDistSqr) {
        return color;
    }
    
    float fogLevel = (distFromCameraSqr - fogStartDistSqr) / (fullFogDistSqr - fogStartDistSqr);
    return color + fogLevel * (constants.fogColor - color);
}
