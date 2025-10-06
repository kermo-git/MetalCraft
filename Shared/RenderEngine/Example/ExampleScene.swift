import simd
import Metal

class ExampleScene: MetalScene {
    var clearColor = MTLClearColor(red: 0, green: 0,
                                   blue: 0, alpha: 0)
    
    var engine = Engine()
    
    private var renderPipeline: MTLRenderPipelineState
    private var depthStencilState: MTLDepthStencilState
    
    struct Vertex: Sizeable {
        let position: Float3
        let color: Float3
    }
    
    struct VertexConstants: Sizeable {
        var projectionViewModelMatrix = matrix_identity_float4x4
    }
    
    var vertexConstants = VertexConstants()
    var vertexBuffer, indexBuffer: MTLBuffer
    var indexCount: Int
    
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
        indexBuffer = engine.device.makeBuffer(bytes: indices,
                                               length: indices.memorySize(),
                                               options: [])!
        
        vertexBuffer = engine.device.makeBuffer(bytes: vertices,
                                                length: vertices.memorySize(),
                                                options: [])!
        
        let descriptor = MTLVertexDescriptor()
        
        descriptor.attributes[0].format = .float3
        descriptor.attributes[0].bufferIndex = 0
        descriptor.attributes[0].offset = 0
        
        descriptor.attributes[1].format = .float3
        descriptor.attributes[1].bufferIndex = 0
        descriptor.attributes[1].offset = Float3.memorySize()
        
        descriptor.layouts[0].stride = Vertex.memorySize()
        
        renderPipeline = getRenderPipelineState(
            device: engine.device,
            vertexShaderName: "exampleVertex",
            fragmentShaderName: "exampleFragment",
            vertexDescriptor: descriptor
        )!
        depthStencilState = getDepthStencilState(engine.device)
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
        time = max(time + deltaTime, 2 * Float.pi)
        let modelMarix = translate(0, 0, -3) * rotateAroundY(time) * rotateAroundX(toRadians(30))
        let pvm = projectionMatrix * camera.viewMatrix * modelMarix
        vertexConstants.projectionViewModelMatrix = pvm
    }
    
    func render(_ encoder: MTLRenderCommandEncoder) {
        encoder.setDepthStencilState(depthStencilState)
        encoder.setRenderPipelineState(renderPipeline)
        encoder.setVertexBytes(&vertexConstants, length: VertexConstants.memorySize(), index: 1)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.drawIndexedPrimitives(type: .triangle,
                                      indexCount: indexCount,
                                      indexType: .uint16,
                                      indexBuffer: indexBuffer,
                                      indexBufferOffset: 0)
    }
}
