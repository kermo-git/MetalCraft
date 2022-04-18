#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[ attribute(0) ]];
    float4 normal [[ attribute(1) ]];
    float2 textureCoords [[ attribute(2) ]];
};

struct VertexConstants {
    float4x4 projectionViewModel;
    float4x4 rotation;
    int textureID;
};

struct FragmentIn {
    float4 position [[ position ]];
    float3 normal;
    float2 textureCoords;
    int textureID [[ flat ]];
};

struct FragmentConstants {
    float3 sunDirection;
};

float3 toFloat3(float4 vec) {
    return float3(vec.x, vec.y, vec.z);
}

vertex FragmentIn vertexShader(VertexIn vIn [[ stage_in ]],
                               constant VertexConstants *constantsArray [[ buffer(1) ]],
                               uint instanceID [[ instance_id ]]) {
    
    VertexConstants constants = constantsArray[instanceID];
    FragmentIn fIn;
    
    fIn.position = constants.projectionViewModel * vIn.position;
    fIn.normal = toFloat3(constants.rotation * vIn.normal);
    fIn.textureCoords = vIn.textureCoords;
    fIn.textureID = constants.textureID;
    
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
