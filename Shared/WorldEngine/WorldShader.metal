#include <metal_stdlib>
using namespace metal;

struct BlockFace {
    int2 positionXZ;
    uchar positionY;
    uchar orientation;
    ushort textureID;
};

struct VertexConstants {
    int3 cameraOrigin;
    float4x4 projectionViewMatrix;
};

struct FragmentIn {
    float4 screenPosition [[ position ]];
    float3 relativeWorldPosition;
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

vertex FragmentIn worldVertex(const device BlockFace* vertices [[ buffer(0) ]],
                              constant VertexConstants &constants [[ buffer(1) ]],
                              uint vertexID [[ vertex_id ]]) {
    
    BlockFace face = vertices[vertexID / 6];
    int3 block_pos = int3(face.positionXZ.x, face.positionY, face.positionXZ.y);
    float3 block_origin = float3(block_pos - constants.cameraOrigin);
    
    uint vertex_index = vertexID % 6;
    uint face_orientation = face.orientation & 7;
    // uint block_orientation = face.orientation >> 3;

    float3 vertex_pos = float3(0, 0, 0);
    half3 normal = half3(0, 0, 0);
    
    /*
     1 --- 2/4
     |     / |
     |    /  |
     |   /   |
     |  /    |
     0/3 --- 5
     */
    switch (face_orientation) {
        case 0: // UP
            normal = half3(0, 1, 0);
            switch (vertex_index) {
                case 0:
                case 3:
                    vertex_pos = block_origin + float3(0, 1, 1);
                    break;
                case 1:
                    vertex_pos = block_origin + float3(0, 1, 0);
                    break;
                case 2:
                case 4:
                    vertex_pos = block_origin + float3(1, 1, 0);
                    break;
                default:
                    vertex_pos = block_origin + float3(1, 1, 1);
                    break;
            }
            break;
        case 1: // DOWN
            normal = half3(0, -1, 0);
            switch (vertex_index) {
                case 0:
                case 3:
                    vertex_pos = block_origin + float3(1, 0, 1);
                    break;
                case 1:
                    vertex_pos = block_origin + float3(1, 0, 0);
                    break;
                case 2:
                case 4:
                    vertex_pos = block_origin + float3(0, 0, 0);
                    break;
                default:
                    vertex_pos = block_origin + float3(0, 0, 1);
                    break;
            }
            break;
        case 2: // WEST
            normal = half3(-1, 0, 0);
            switch (vertex_index) {
                case 0:
                case 3:
                    vertex_pos = block_origin + float3(0, 0, 0);
                    break;
                case 1:
                    vertex_pos = block_origin + float3(0, 1, 0);
                    break;
                case 2:
                case 4:
                    vertex_pos = block_origin + float3(0, 1, 1);
                    break;
                default:
                    vertex_pos = block_origin + float3(0, 0, 1);
                    break;
            }
            break;
        case 3: // EAST
            normal = half3(1, 0, 0);
            switch (vertex_index) {
                case 0:
                case 3:
                    vertex_pos = block_origin + float3(1, 0, 1);
                    break;
                case 1:
                    vertex_pos = block_origin + float3(1, 1, 1);
                    break;
                case 2:
                case 4:
                    vertex_pos = block_origin + float3(1, 1, 0);
                    break;
                default:
                    vertex_pos = block_origin + float3(1, 0, 0);
                    break;
            }
            break;
        case 4: // SOUTH
            normal = half3(0, 0, 1);
            switch (vertex_index) {
                case 0:
                case 3:
                    vertex_pos = block_origin + float3(0, 0, 1);
                    break;
                case 1:
                    vertex_pos = block_origin + float3(0, 1, 1);
                    break;
                case 2:
                case 4:
                    vertex_pos = block_origin + float3(1, 1, 1);
                    break;
                default:
                    vertex_pos = block_origin + float3(1, 0, 1);
                    break;
            }
            break;
        default: // NORTH
            normal = half3(0, 0, -1);
            switch (vertex_index) {
                case 0:
                case 3:
                    vertex_pos = block_origin + float3(1, 0, 0);
                    break;
                case 1:
                    vertex_pos = block_origin + float3(1, 1, 0);
                    break;
                case 2:
                case 4:
                    vertex_pos = block_origin + float3(0, 1, 0);
                    break;
                default:
                    vertex_pos = block_origin + float3(0, 0, 0);
                    break;
            }
            break;
    }
    
    half2 texture_coords = half2(0, 0);
    
    switch (vertex_index) {
        case 0:
        case 3:
            texture_coords = half2(0, 1);
            break;
        case 1:
            texture_coords = half2(0, 0);
            break;
        case 2:
        case 4:
            texture_coords = half2(1, 0);
            break;
        default:
            texture_coords = half2(1, 1);
            break;
    }
    
    /* switch (orientation) {
        case 0: // NONE
            break;
        case 1: // Y90
            break;
        case 2: // YNEG90
            break;
        case 3: // Y180
            break;
        case 4: // X90
            break;
        case 5: // X90_Y90
            break;
        case 6: // X90_NEGY90
            break;
        default: // X90_Y180
            break;
    } */
    
    FragmentIn fIn;
    
    fIn.screenPosition = constants.projectionViewMatrix * float4(vertex_pos, 1);
    fIn.relativeWorldPosition = vertex_pos;
    fIn.normal = normal;
    fIn.textureCoords = texture_coords;
    fIn.textureID = face.textureID;
    
    return fIn;
}

fragment half4 worldFragment(FragmentIn fIn [[ stage_in ]],
                             constant FragmentConstants &constants [[ buffer(1) ]],
                             sampler sampler2D [[ sampler(0) ]],
                             texture2d_array<half> textures [[ texture(0) ]]) {
    
    float distFromCameraSqr = distance_squared(fIn.relativeWorldPosition, constants.cameraPos);
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
