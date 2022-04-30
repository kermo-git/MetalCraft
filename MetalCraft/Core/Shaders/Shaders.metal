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
    float3 normal;
    int textureID;
};

struct FragmentIn {
    float4 position [[ position ]];
    float2 textureCoords;
    float3 normal [[ flat ]];
    int textureID [[ flat ]];
};

struct FragmentConstants {
    float3 sunDirection;
};

float3 toFloat3(float4 vec) {
    return float3(vec.x, vec.y, vec.z);
}

vertex FragmentIn vertexShader(VertexIn vIn [[ stage_in ]],
                               constant SceneConstants &sceneConstants [[ buffer(1) ]],
                               constant ShaderBlockFace *blockFaces [[ buffer(2) ]],
                               uint instanceID [[ instance_id ]]) {
    
    ShaderBlockFace blockface = blockFaces[instanceID];
    FragmentIn fIn;
    
    fIn.position = sceneConstants.projectionViewMatrix * blockface.modelMatrix * vIn.position;
    fIn.normal = blockface.normal;
    fIn.textureCoords = vIn.textureCoords;
    fIn.textureID = blockface.textureID;
    
    return fIn;
}

fragment half4 fragmentShader(FragmentIn fIn [[ stage_in ]],
                              constant FragmentConstants &constants [[ buffer(1) ]],
                              sampler sampler2D [[ sampler(0) ]],
                              array<texture2d<half>, 5> textures [[ texture(0) ]]) {
    
    texture2d<half> texture = textures[fIn.textureID];
    half4 color = texture.sample(sampler2D, fIn.textureCoords);
    float intensity = max(0.6, dot(constants.sunDirection, fIn.normal));
    return intensity * color;
}
