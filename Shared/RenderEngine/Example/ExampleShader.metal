#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position          [[ attribute(0) ]];
    float3 color             [[ attribute(1) ]];
    float4 model_matrix_col0 [[ attribute(2) ]];
    float4 model_matrix_col1 [[ attribute(3) ]];
    float4 model_matrix_col2 [[ attribute(4) ]];
    float4 model_matrix_col3 [[ attribute(5) ]];
};

struct VertexConstants {
    float4x4 projectionView;
};

struct FragmentIn {
    float4 screenPosition [[ position ]];
    half4 color;
};

vertex FragmentIn exampleVertex(VertexIn vIn [[ stage_in ]],
                                constant VertexConstants &constants [[ buffer(2) ]]) {
    
    FragmentIn fIn;
    
    float4x4 model_matrix = float4x4(
        vIn.model_matrix_col0,
        vIn.model_matrix_col1,
        vIn.model_matrix_col2,
        vIn.model_matrix_col3
    );
    fIn.screenPosition = constants.projectionView * model_matrix * float4(vIn.position, 1);
    fIn.color = half4(half3(vIn.color), 1);
    
    return fIn;
}

fragment half4 exampleFragment(FragmentIn fIn [[ stage_in ]]) {
    return fIn.color;
}
