#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[ attribute(0) ]];
    float2 textureCoords [[ attribute(1) ]];
};

struct SceneConstants {
    float4x4 projectionViewMatrix;
};

struct ShaderBlockFace {
    float4x4 modelMatrix;
    int textureID;
};

struct FragmentIn {
    float4 position [[ position ]];
    float3 worldPosition;
    float2 textureCoords;
    int textureID [[ flat ]];
};

struct FragmentConstants {
    float3 playerPos;
    float renderDistance;
    float4 fogColor;
};

vertex FragmentIn vertexShader(VertexIn vIn [[ stage_in ]],
                               constant SceneConstants &sceneConstants [[ buffer(1) ]],
                               constant ShaderBlockFace *blockFaces [[ buffer(2) ]],
                               uint instanceID [[ instance_id ]]) {
    
    ShaderBlockFace blockface = blockFaces[instanceID];
    FragmentIn fIn;
    
    float4 worldPosition = blockface.modelMatrix * vIn.position;
    fIn.position = sceneConstants.projectionViewMatrix * worldPosition;
    fIn.worldPosition = float3(worldPosition);
    fIn.textureCoords = vIn.textureCoords;
    fIn.textureID = blockface.textureID;
    
    return fIn;
}

fragment half4 fragmentShader(FragmentIn fIn [[ stage_in ]],
                              constant FragmentConstants &constants [[ buffer(1) ]],
                              sampler sampler2D [[ sampler(0) ]],
                              array<texture2d<half>, 5> textures [[ texture(0) ]]) {
    
    texture2d<half> texture = textures[fIn.textureID];
    half4 textureColor = texture.sample(sampler2D, fIn.textureCoords);
    
    float distanceFromPlayer = distance(fIn.worldPosition, constants.playerPos);
    float fogStartDistance = 0.6 * constants.renderDistance;
    float fullFogDistance = 0.9 * constants.renderDistance;
    half4 fogColor = half4(constants.fogColor);
    
    if (distanceFromPlayer < fogStartDistance)
        return textureColor;
    if (distanceFromPlayer < fullFogDistance) {
        half fogLevel = (distanceFromPlayer - fogStartDistance) / (fullFogDistance - fogStartDistance);
        return textureColor + fogLevel * (fogColor - textureColor);
    }
    return fogColor;
}
