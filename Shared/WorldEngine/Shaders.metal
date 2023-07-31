#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position [[ attribute(0) ]];
    float2 textureCoords [[ attribute(1) ]];
    int textureID [[ attribute(2) ]];
};

struct SceneConstants {
    float4x4 projectionViewMatrix;
};

struct FragmentIn {
    float4 screenPosition [[ position ]];
    float3 worldPosition;
    float2 textureCoords;
    int textureID [[ flat ]];
};

struct FragmentConstants {
    float3 cameraPos;
    float renderDistance;
    float4 fogColor;
};

vertex FragmentIn vertexShader(const VertexIn vIn [[ stage_in ]],
                               constant SceneConstants &sceneConstants [[ buffer(1) ]]) {
    
    FragmentIn fIn;
    
    float4 worldPosition = float4(vIn.position, 1);
    fIn.screenPosition = sceneConstants.projectionViewMatrix * worldPosition;
    fIn.worldPosition = vIn.position;
    fIn.textureCoords = vIn.textureCoords;
    fIn.textureID = vIn.textureID;
    
    return fIn;
}

fragment half4 fragmentShader(FragmentIn fIn [[ stage_in ]],
                              constant FragmentConstants &constants [[ buffer(1) ]],
                              sampler sampler2D [[ sampler(0) ]],
                              array<texture2d<half>, 5> textures [[ texture(0) ]]) {
    
    texture2d<half> texture = textures[fIn.textureID];
    half4 textureColor = texture.sample(sampler2D, fIn.textureCoords);
    
    float distanceFromCamera = distance(fIn.worldPosition, constants.cameraPos);
    float fogStartDistance = 0.6 * constants.renderDistance;
    float fullFogDistance = 0.9 * constants.renderDistance;
    half4 fogColor = half4(constants.fogColor);
    
    if (distanceFromCamera < fogStartDistance)
        return textureColor;
    if (distanceFromCamera < fullFogDistance) {
        half fogLevel = (distanceFromCamera - fogStartDistance) / (fullFogDistance - fogStartDistance);
        return textureColor + fogLevel * (fogColor - textureColor);
    }
    return fogColor;
}
