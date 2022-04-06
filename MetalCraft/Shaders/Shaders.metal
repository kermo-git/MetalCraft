#include <metal_stdlib>
using namespace metal;

struct ModelConstants {
    float4x4 modelMatrix;
};

struct VertexIn {
    float3 position [[ attribute(0) ]];
    float4 color [[ attribute(1) ]];
};

struct RasterizerData {
    float4 position [[ position ]];
    half4 color;
};

vertex RasterizerData basic_vertex_shader(const VertexIn vIn [[ stage_in ]],
                                          constant ModelConstants &constants [[ buffer(1) ]]) {
    
    RasterizerData rd;
    
    rd.position = constants.modelMatrix * float4(vIn.position, 1);
    rd.color = half4(vIn.color);
    
    return rd;
}

fragment half4 basic_fragment_shader(RasterizerData rd [[ stage_in ]]) {
    return rd.color;
}
