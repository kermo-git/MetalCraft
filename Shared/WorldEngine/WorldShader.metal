#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[ attribute(0) ]];
    float2 textureCoords [[ attribute(1) ]];
    int textureID [[ attribute(2) ]];
};

struct VertexConstants {
    float4x4 projectionViewMatrix;
};

struct FragmentIn {
    float4 screenPosition [[ position ]];
    float4 worldPosition;
    float2 textureCoords;
    int textureID [[ flat ]];
};

struct FragmentConstants {
    float4 cameraPos;
    float renderDistance;
    float4 fogColor;
};

vertex FragmentIn worldVertex(const VertexIn vIn [[ stage_in ]],
                              constant VertexConstants &constants [[ buffer(1) ]]) {
    FragmentIn fIn;
    
    fIn.screenPosition = constants.projectionViewMatrix * vIn.position;
    fIn.worldPosition = vIn.position;
    fIn.textureCoords = vIn.textureCoords;
    fIn.textureID = vIn.textureID;
    
    return fIn;
}

fragment float4 worldFragment(FragmentIn fIn [[ stage_in ]],
                              constant FragmentConstants &constants [[ buffer(1) ]],
                              sampler sampler2D [[ sampler(0) ]],
                              texture2d_array<float> textures [[ texture(0) ]]) {
    
    float4 textureColor = textures.sample(sampler2D, fIn.textureCoords, fIn.textureID);
    
    float distanceFromCamera = distance(fIn.worldPosition, constants.cameraPos);
    float fogStartDistance = 0.6 * constants.renderDistance;
    float fullFogDistance = 0.9 * constants.renderDistance;
    
    if (distanceFromCamera < fogStartDistance)
        return textureColor;
    if (distanceFromCamera < fullFogDistance) {
        half fogLevel = (distanceFromCamera - fogStartDistance) / (fullFogDistance - fogStartDistance);
        return textureColor + fogLevel * (constants.fogColor - textureColor);
    }
    return constants.fogColor;
}
