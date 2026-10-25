#include <metal_stdlib>
using namespace metal;

struct Quad {
    int2 blockPosXZ;
    uchar blockPosY;
    ushort quadPos;
    ushort quadSize_quadOrientation_texRotation;
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

half unpack_half(ushort uint16_val, ushort shift) {
    return half((uint16_val >> shift) & 0x1F) * 0.0625h;
}

vertex FragmentIn worldVertex(const device Quad* quads [[ buffer(0) ]],
                              constant VertexConstants &constants [[ buffer(1) ]],
                              uint vertexID [[ vertex_id ]]) {
    // Find quad unpack compressed data
    Quad quad = quads[vertexID / 6];
    
    int3 block_pos = int3(quad.blockPosXZ.x, quad.blockPosY, quad.blockPosXZ.y);
    
    half3 quad_pos = half3(unpack_half(quad.quadPos, 10),
                           unpack_half(quad.quadPos, 5),
                           unpack_half(quad.quadPos, 0));
    
    half2 quad_size = half2(unpack_half(quad.quadSize_quadOrientation_texRotation, 10),
                            unpack_half(quad.quadSize_quadOrientation_texRotation, 5));
    
    uchar quad_orientation = (quad.quadSize_quadOrientation_texRotation >> 2) & 7;
    uchar tex_rotation = quad.quadSize_quadOrientation_texRotation & 3;
    
    // Define lookup tables
    /*
     1 --- 2/4
     |     / |
     |    /  |
     |   /   |
     |  /    |
     0/3 --- 5
     */
    half3 vertex_pos_lookup[36] = {
        // UP
        half3(0, 0, 1), half3(0, 0, 0), half3(1, 0, 0),
        half3(0, 0, 1), half3(1, 0, 0), half3(1, 0, 1),
        // DOWN
        half3(1, 0, 1), half3(1, 0, 0), half3(0, 0, 0),
        half3(1, 0, 1), half3(0, 0, 0), half3(0, 0, 1),
        // WEST
        half3(0, 0, 0), half3(0, 1, 0), half3(0, 1, 1),
        half3(0, 0, 0), half3(0, 1, 1), half3(0, 0, 1),
        // EAST
        half3(0, 0, 1), half3(0, 1, 1), half3(0, 1, 0),
        half3(0, 0, 1), half3(0, 1, 0), half3(0, 0, 0),
        // SOUTH
        half3(0, 0, 0), half3(0, 1, 0), half3(1, 1, 0),
        half3(0, 0, 0), half3(1, 1, 0), half3(1, 0, 0),
        // NORTH
        half3(1, 0, 0), half3(1, 1, 0), half3(0, 1, 0),
        half3(1, 0, 0), half3(0, 1, 0), half3(0, 0, 0),
    };
    
    half3 normal_lookup[6] = {
        half3( 0,  1,  0), // UP
        half3( 0, -1,  0), // DOWN
        half3(-1,  0,  0), // WEST
        half3( 1,  0,  0), // EAST
        half3( 0,  0,  1), // SOUTH
        half3( 0,  0, -1)  // NORTH
    };
    
    half2 tex_pos_lookup[24] = {
        // NONE
        half2(0, 1), half2(0, 0), half2(1, 0),
        half2(0, 1), half2(1, 0), half2(1, 1),
        // CW
        half2(1, 1), half2(0, 1), half2(0, 0),
        half2(1, 1), half2(0, 0), half2(1, 0),
        // CCW
        half2(0, 0), half2(1, 0), half2(1, 1),
        half2(0, 0), half2(1, 1), half2(0, 1),
        // FULL
        half2(1, 0), half2(1, 1), half2(0, 1),
        half2(1, 0), half2(0, 1), half2(0, 0),
    };
    
    // Calculations
    FragmentIn fIn;
    fIn.textureID = quad.textureID;
    fIn.normal = normal_lookup[quad_orientation];
    
    uint vertex_index = vertexID % 6;
    fIn.textureCoords = tex_pos_lookup[6*tex_rotation + vertex_index];
    
    half3 quad_size_multiplier = half3(1, 1, 1);
    
    if (quad_orientation < 2) {
        // UP, DOWN
        quad_size_multiplier = half3(quad_size.x, 1, quad_size.y);
    } else if (quad_orientation < 4) {
        // WEST, EAST
        quad_size_multiplier = half3(1, quad_size.y, quad_size.x);
    } else {
        // SOUTH, NORTH
        quad_size_multiplier = half3(quad_size.x, quad_size.y, 1);
    }
    
    half3 local_vertex_pos = vertex_pos_lookup[6*quad_orientation + vertex_index];
    local_vertex_pos = quad_size_multiplier * local_vertex_pos + quad_pos;
    
    float3 block_origin = float3(block_pos - constants.cameraOrigin);
    float3 vertex_pos = block_origin + float3(local_vertex_pos);
    
    fIn.screenPosition = constants.projectionViewMatrix * float4(vertex_pos, 1);
    fIn.worldPosition = vertex_pos;
    
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
