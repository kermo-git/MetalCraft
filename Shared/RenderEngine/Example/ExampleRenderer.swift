import simd
import Metal

class ExampleRenderer: Renderer {
    var clearColor = MTLClearColor(red: 0, green: 0,
                                   blue: 0, alpha: 0)
    
    var engine = Engine()
    
    private var renderPipeline: MTLRenderPipelineState
    private var depthStencilState: MTLDepthStencilState
    
    struct Vertex {
        let position: Float3
        let color: Float3
    }
    
    struct Instance {
        let model: Float4x4
    }
    
    struct VertexConstants {
        var projectionView = matrix_identity_float4x4
    }
    
    var vertexConstants = VertexConstants()
    var vertexBuffer, indexBuffer, instanceBuffer: MTLBuffer
    var indexCount, instanceCount: Int
    
    init() {
        let vertices = [
            Vertex(position: Float3(-0.5, -0.5, -0.5), color: Float3(0.8, 0.2, 0.2)),
            Vertex(position: Float3(-0.5, -0.5,  0.5), color: Float3(0.2, 0.8, 0.2)),
            Vertex(position: Float3(-0.5,  0.5, -0.5), color: Float3(0.2, 0.8, 0.8)),
            Vertex(position: Float3(-0.5,  0.5,  0.5), color: Float3(0.8, 0.8, 0.0)),
            Vertex(position: Float3( 0.5, -0.5, -0.5), color: Float3(0.8, 0.0, 0.8)),
            Vertex(position: Float3( 0.5, -0.5,  0.5), color: Float3(0.8, 0.2, 0.2)),
            Vertex(position: Float3( 0.5,  0.5, -0.5), color: Float3(0.2, 0.8, 0.2)),
            Vertex(position: Float3( 0.5,  0.5,  0.5), color: Float3(0.2, 0.2, 0.8))
        ]
        
        let indices: [UInt16] = [
            // Bottom face
            0, 1, 4,
            1, 4, 5,
            // Front face
            0, 4, 2,
            4, 2, 6,
            // Left face
            0, 1, 2,
            1, 2, 3,
            // Back face
            1, 5, 3,
            5, 3, 7,
            // Right face
            4, 5, 6,
            5, 6, 7,
            // Top face
            2, 6, 3,
            6, 3, 7
        ]
        indexCount = indices.count
        
        let instances = [
            Instance(
                model: translate(-1, 0, -3) *
                rotateAroundX(toRadians(30)) *
                rotateAroundY(toRadians(-50)) *
                scale(1, 0.5, 0.5)
            ),
            Instance(
                model: translate(1, 0, -3) *
                rotateAroundY(toRadians(30)) *
                rotateAroundX(toRadians(30))
            )
        ]
        instanceCount = instances.count
        
        indexBuffer = engine.device.makeBuffer(bytes: indices,
                                               length: indices.memoryStride(),
                                               options: [])!
        
        vertexBuffer = engine.device.makeBuffer(bytes: vertices,
                                                length: vertices.memoryStride(),
                                                options: [])!
        
        instanceBuffer = engine.device.makeBuffer(bytes: instances,
                                                  length: instances.memoryStride(),
                                                  options: [])!
        
        let descriptor = MTLVertexDescriptor()
        
        descriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        descriptor.layouts[0].stepFunction = .perVertex
        
        // Vertex position
        descriptor.attributes[0].bufferIndex = 0
        descriptor.attributes[0].format = .float3
        descriptor.attributes[0].offset = 0
        
        // Vertex color
        descriptor.attributes[1].bufferIndex = 0
        descriptor.attributes[1].format = .float3
        descriptor.attributes[1].offset = MemoryLayout<Float3>.stride
        
        descriptor.layouts[1].stride = MemoryLayout<Instance>.stride
        descriptor.layouts[1].stepFunction = .perInstance
        
        // Instance model
        descriptor.attributes[2].bufferIndex = 1
        descriptor.attributes[2].format = .float4
        descriptor.attributes[2].offset = 0
        
        descriptor.attributes[3].bufferIndex = 1
        descriptor.attributes[3].format = .float4
        descriptor.attributes[3].offset = MemoryLayout<Float4>.stride
        
        descriptor.attributes[4].bufferIndex = 1
        descriptor.attributes[4].format = .float4
        descriptor.attributes[4].offset = 2 * MemoryLayout<Float4>.stride
        
        descriptor.attributes[5].bufferIndex = 1
        descriptor.attributes[5].format = .float4
        descriptor.attributes[5].offset = 3 * MemoryLayout<Float4>.stride
        
        renderPipeline = engine.getRenderPipelineState(
            vertexShaderName: "exampleVertex",
            fragmentShaderName: "exampleFragment",
            vertexDescriptor: descriptor
        )!
        depthStencilState = engine.getDepthStencilState()
        setAspectRatio(1)
    }
    
    var camera = Camera()
    var projectionMatrix: Float4x4 = matrix_identity_float4x4
    
    func setAspectRatio(_ aspectRatio: Float) {
        projectionMatrix = perspective(degreesFov: camera.degreesFov,
                                       aspectRatio: aspectRatio,
                                       near: 0.1,
                                       far: 1000)
    }
    
    var time: Float = 0
    func update(deltaTime: Float) {
        vertexConstants.projectionView = projectionMatrix * camera.viewMatrix
    }
    
    func render(_ encoder: MTLRenderCommandEncoder) {
        encoder.setDepthStencilState(depthStencilState)
        encoder.setRenderPipelineState(renderPipeline)
        
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setVertexBuffer(instanceBuffer, offset: 0, index: 1)
        encoder.setVertexBytes(
            &vertexConstants,
            length: MemoryLayout<VertexConstants>.stride,
            index: 2
        )
        
        encoder.drawIndexedPrimitives(type: .triangle,
                                      indexCount: indexCount,
                                      indexType: .uint16,
                                      indexBuffer: indexBuffer,
                                      indexBufferOffset: 0,
                                      instanceCount: instanceCount)
    }
}

import SwiftUI

#Preview {
    MetalView(renderer: ExampleRenderer())
}
