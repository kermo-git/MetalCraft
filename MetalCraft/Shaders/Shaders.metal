#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position [[ attribute(0) ]];
    float2 textureCoords [[ attribute(1) ]];
};

struct ModelConstants {
    float4x4 projectionViewModel;
    int textureIdx;
};

struct RasterizerData {
    float4 position [[ position ]];
    float2 textureCoords;
    int textureIdx [[ flat ]];
};

vertex RasterizerData vertexShader(const VertexIn vIn [[ stage_in ]],
                                   constant ModelConstants *constantsArray [[ buffer(1) ]],
                                   uint instanceID [[ instance_id ]]) {
    
    ModelConstants modelConstants = constantsArray[instanceID];
    RasterizerData rd;
    
    rd.position = modelConstants.projectionViewModel * float4(vIn.position, 1);
    rd.textureCoords = vIn.textureCoords;
    rd.textureIdx = modelConstants.textureIdx;
    
    return rd;
}

fragment half4 fragmentShader(const RasterizerData rd [[ stage_in ]],
                              sampler sampler2D [[ sampler(0) ]],
                              array<texture2d<half>, 5> textures [[ texture(0) ]]) {
    
    
    texture2d<half> texture = textures[rd.textureIdx];
    return texture.sample(sampler2D, rd.textureCoords);
}

