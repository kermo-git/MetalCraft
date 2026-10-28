#include <metal_stdlib>
using namespace metal;

struct Quad {
    int2 blockPosXZ;
    uchar blockPosY;
    uchar shapeID_texRotation;
    ushort textureID;
    ushort quadPos;
    ushort quadSize;
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

half3 unpack_half3(ushort uint16_data) {
    half x = half(uint16_data >> 10) * 0.0625h;
    half y = half((uint16_data >> 5) & 0x1F) * 0.0625h;
    half z = half(uint16_data & 0x1F) * 0.0625h;
    return half3(x, y, z);
}

vertex FragmentIn worldVertex(const device Quad* quads [[ buffer(0) ]],
                              constant VertexConstants &constants [[ buffer(1) ]],
                              uint vertexID [[ vertex_id ]]) {
    // Find quad and unpack compressed data
    Quad quad = quads[vertexID / 6];
    
    int3 block_pos = int3(quad.blockPosXZ.x, quad.blockPosY, quad.blockPosXZ.y);
    half3 quad_pos = unpack_half3(quad.quadPos);
    half3 quad_size = unpack_half3(quad.quadSize);
    uchar shapeID = (quad.shapeID_texRotation >> 2) & 7;
    uchar tex_rotation = quad.shapeID_texRotation & 3;
    
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
    
    half3x2 tex_pos_projection_lookup[6] = {
        // UP
        half3x2(
            half2(1, 0),
            half2(0, 0),
            half2(0, 1)
        ),
        // DOWN
        half3x2(
            half2(-1, 0),
            half2(0, 0),
            half2(0, 1)
        ),
        // WEST
        half3x2(
            half2(0, 0),
            half2(0, -1),
            half2(1, 0)
        ),
        // EAST
        half3x2(
            half2(0, 0),
            half2(0, -1),
            half2(-1, 0)
        ),
        // SOUTH
        half3x2(
            half2(1, 0),
            half2(0, -1),
            half2(0, 0)
        ),
        // NORTH
        half3x2(
            half2(-1, 0),
            half2(0, -1),
            half2(0, 0)
        )
    };
    
    half2x2 tex_rotation_lookup[4] = {
        // NONE
        half2x2(half2(1, 0), half2(0, 1)),
        // CW
        half2x2(half2(0, -1), half2(1, 0)),
        // CCW
        half2x2(half2(0, 1), half2(-1, 0)),
        // FULL
        half2x2(half2(-1, 0), half2(0, -1)),
    };
    
    // Calculations
    FragmentIn fIn;
    fIn.textureID = quad.textureID;
    fIn.normal = normal_lookup[shapeID];
    
    uint vertex_index = vertexID % 6;
    
    half3 local_vertex_pos = vertex_pos_lookup[6*shapeID + vertex_index];
    local_vertex_pos = quad_size * local_vertex_pos + quad_pos;
    
    half2 tex_pos = tex_pos_projection_lookup[shapeID]*local_vertex_pos;
    fIn.textureCoords = tex_rotation_lookup[tex_rotation] * tex_pos;
    
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
