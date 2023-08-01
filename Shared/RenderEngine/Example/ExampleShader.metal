#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position [[ attribute(0) ]];
    float3 color [[ attribute(1) ]];
};

struct VertexConstants {
    float4x4 projectionViewModelMatrix;
};

struct FragmentIn {
    float4 screenPosition [[ position ]];
    half4 color;
};

vertex FragmentIn exampleVertex(const VertexIn vIn [[ stage_in ]],
                                constant VertexConstants &constants [[ buffer(1) ]]) {
    
    FragmentIn fIn;
    
    fIn.screenPosition = constants.projectionViewModelMatrix * float4(vIn.position, 1);
    fIn.color = half4(half3(vIn.color), 1);
    
    return fIn;
}

fragment half4 exampleFragment(FragmentIn fIn [[ stage_in ]]) {
    return fIn.color;
}
