#include <metal_stdlib>
using namespace metal;

struct Quad {
    int2 blockPosXZ;
    uchar blockPosY;
    uchar shapeID;
    uchar rotationID;
    ushort textureID;
};

struct VertexConstants {
    int3 cameraOrigin;
    float4x4 projectionViewMatrix;
};

struct FragmentIn {
    float4 screenPosition [[ position ]];
    float3 worldPosition;
    half3 normal [[ flat ]];
    half2 textureCoords;
    ushort textureID [[ flat ]];
};

struct FragmentConstants {
    float3 cameraPos;
    half3 sunDirection;
    float fogDistanceSquared;
    half4 fogColor;
    half4 sunColor;
};

vertex FragmentIn worldVertex(constant VertexConstants &constants [[ buffer(0) ]],
                              const device half3* vertex_pos_buffer [[ buffer(1) ]],
                              const device uchar* triangle_normal_buffer [[ buffer(2) ]],
                              const device half2* texture_pos_buffer [[ buffer(3) ]],
                              const device half3x3* rotation_buffer [[ buffer(4) ]],
                              const device Quad* quad_buffer [[ buffer(5) ]],
                              uint vertexID [[ vertex_id ]]) {
    
    uint quadID = vertexID / 6;
    uint vertex_index = vertexID % 6;
    
    Quad quad = quad_buffer[quadID];
    half3x3 rotation_matrix = rotation_buffer[quad.rotationID];
    int3 block_pos = int3(quad.blockPosXZ.x, quad.blockPosY, quad.blockPosXZ.y);
    
    FragmentIn fIn;
    fIn.textureID = quad.textureID;
    
    fIn.textureCoords = texture_pos_buffer[6*quad.shapeID + vertex_index];
    
    float3 block_origin = float3(block_pos - constants.cameraOrigin);
    half3 local_vertex_pos = rotation_matrix * vertex_pos_buffer[6*quad.shapeID + vertex_index];
    float3 vertex_pos = block_origin + float3(local_vertex_pos);
    
    fIn.screenPosition = constants.projectionViewMatrix * float4(vertex_pos, 1);
    fIn.worldPosition = vertex_pos;
    
    half3 normal_lookup[6] = {
        half3( 0,  1,  0), // UP
        half3( 0, -1,  0), // DOWN
        half3(-1,  0,  0), // WEST
        half3( 1,  0,  0), // EAST
        half3( 0,  0,  1), // SOUTH
        half3( 0,  0, -1)  // NORTH
    };
    
    if (vertex_index < 3) {
        fIn.normal = rotation_matrix * normal_lookup[triangle_normal_buffer[2*quad.shapeID]];
    } else {
        fIn.normal = rotation_matrix * normal_lookup[triangle_normal_buffer[2*quad.shapeID + 1]];
    }
    
    return fIn;
}

fragment half4 worldFragment(FragmentIn fIn [[ stage_in ]],
                             constant FragmentConstants &constants [[ buffer(1) ]],
                             sampler sampler2D [[ sampler(0) ]],
                             texture2d_array<half> textures [[ texture(0) ]]) {
    
    float distFromCameraSqr = distance_squared(fIn.worldPosition, constants.cameraPos);
    float fullFogDistSqr = 0.9 * constants.fogDistanceSquared;
    
    if (distFromCameraSqr > fullFogDistSqr)
        return constants.fogColor;
    
    half4 textureColor = textures.sample(sampler2D, float2(fIn.textureCoords), fIn.textureID);
    half4 color = textureColor * 0.5h;

    half sunIntensity = dot(fIn.normal, constants.sunDirection);
    
    if (sunIntensity > 0.0h) {
        color += sunIntensity * constants.sunColor * textureColor;
    }
    
    float fogStartDistSqr = 0.8 * constants.fogDistanceSquared;
    if (distFromCameraSqr < fogStartDistSqr) {
        return color;
    }
    
    half fogLevel = half((distFromCameraSqr - fogStartDistSqr) / (fullFogDistSqr - fogStartDistSqr));
    return color + fogLevel * (constants.fogColor - color);
}
