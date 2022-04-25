#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[ attribute(0) ]];
    float2 textureCoords [[ attribute(1) ]];
};

struct SceneConstants {
    float4x4 projectionViewMatrix;
};

struct FaceConstants {
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
                               constant FaceConstants *constantsArray [[ buffer(2) ]],
                               uint instanceID [[ instance_id ]]) {
    
    FaceConstants faceConstants = constantsArray[instanceID];
    FragmentIn fIn;
    
    fIn.position = sceneConstants.projectionViewMatrix * faceConstants.modelMatrix * vIn.position;
    fIn.normal = faceConstants.normal;
    fIn.textureCoords = vIn.textureCoords;
    fIn.textureID = faceConstants.textureID;
    
    return fIn;
}

fragment half4 fragmentShader(FragmentIn fIn [[ stage_in ]],
                              constant FragmentConstants &constants [[ buffer(1) ]],
                              sampler sampler2D [[ sampler(0) ]],
                              array<texture2d<half>, 5> textures [[ texture(0) ]]) {
    
    texture2d<half> texture = textures[fIn.textureID];
    half4 color = texture.sample(sampler2D, fIn.textureCoords);
    float intensity = max(0.3, dot(constants.sunDirection, fIn.normal));
    return intensity * color;
}
