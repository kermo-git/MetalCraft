#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position [[ attribute(0) ]];
    float3 normal [[ attribute(1) ]];
    float2 textureCoords [[ attribute(2) ]];
    int textureID [[ attribute(3) ]];
};

struct VertexConstants {
    float4x4 projectionViewMatrix;
};

struct FragmentIn {
    float4 screenPosition [[ position ]];
    float3 worldPosition;
    float3 normal [[ flat ]];
    float2 textureCoords;
    int textureID [[ flat ]];
};

struct FragmentConstants {
    float3 cameraPos;
    float3 sunDirection;
    float fogDistanceSquared;
    float4 fogColor;
    float4 sunColor;
};

vertex FragmentIn worldVertex(const VertexIn vIn [[ stage_in ]],
                              constant VertexConstants &constants [[ buffer(1) ]]) {
    FragmentIn fIn;
    
    fIn.screenPosition = constants.projectionViewMatrix * float4(vIn.position, 1);
    fIn.worldPosition = vIn.position;
    fIn.normal = vIn.normal;
    fIn.textureCoords = vIn.textureCoords;
    fIn.textureID = vIn.textureID;
    
    return fIn;
}

fragment float4 worldFragment(FragmentIn fIn [[ stage_in ]],
                              constant FragmentConstants &constants [[ buffer(1) ]],
                              sampler sampler2D [[ sampler(0) ]],
                              texture2d_array<float> textures [[ texture(0) ]]) {
    
    float distFromCameraSqr = distance_squared(fIn.worldPosition, constants.cameraPos);
    float fullFogDistSqr = 0.9 * constants.fogDistanceSquared;
    
    if (distFromCameraSqr > fullFogDistSqr)
        return constants.fogColor;
    
    float4 textureColor = textures.sample(sampler2D, fIn.textureCoords, fIn.textureID);
    float4 color = textureColor * 0.5;

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
