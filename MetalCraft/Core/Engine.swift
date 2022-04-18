import MetalKit

// Cube mapping: https://metalbyexample.com/reflection-and-refraction/
// Shadow mapping: https://github.com/carolight/Metal-Shadow-Map

class Engine {
    static let Device: MTLDevice = MTLCreateSystemDefaultDevice()!
    static let CommandQueue: MTLCommandQueue = Device.makeCommandQueue()!
    static let DefaultLibrary: MTLLibrary = Device.makeDefaultLibrary()!
    static let DepthPencilState: MTLDepthStencilState = getDepthStencilState()
    static let RenderPipelineState: MTLRenderPipelineState = getRenderPipelineState(
        descriptor: getRenderPipelineDescriptor(
            vertexFunction: getShaderFunction(name: "vertexShader"),
            fragmentFunction: getShaderFunction(name: "fragmentShader"),
            vDescriptor: getVertexDescriptor()
    ))!
    static let SamplerState: MTLSamplerState = getSamplerState()
    
    static func loadTexture(fileName: String, fileExtension: String = "png",
                           origin: MTKTextureLoader.Origin = MTKTextureLoader.Origin.topLeft) -> MTLTexture {
        
        var result: MTLTexture!
        
        if let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) {
            
            let loader = MTKTextureLoader(device: Device)
            let options: [MTKTextureLoader.Option : Any] = [
                MTKTextureLoader.Option.origin: origin,
                MTKTextureLoader.Option.generateMipmaps: true
            ]
            
            do {
                result = try loader.newTexture(URL: url, options: options)
                result.label = fileName
            } catch let error as NSError {
                print("Error creating texture \(fileName): \(error)")
            }
        } else {
            print("Texture \(fileName) does not exist!")
        }
        return result
    }
    
    static func getSamplerState() -> MTLSamplerState {
        let descriptor = MTLSamplerDescriptor()
        descriptor.minFilter = .nearest
        descriptor.magFilter = .nearest
        descriptor.mipFilter = .linear
        return Device.makeSamplerState(descriptor: descriptor)!
    }

    static func getDepthStencilState() -> MTLDepthStencilState {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.isDepthWriteEnabled = true
        descriptor.depthCompareFunction = .less
        return Device.makeDepthStencilState(descriptor: descriptor)!
    }
    
    static func getShaderFunction(name: String) -> MTLFunction {
        return DefaultLibrary.makeFunction(name: name)!
    }
    
    static func getRenderPipelineDescriptor(
        vertexFunction: MTLFunction,
        fragmentFunction: MTLFunction,
        vDescriptor: MTLVertexDescriptor) -> MTLRenderPipelineDescriptor {
            
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].pixelFormat = Preferences.PixelFormat
        descriptor.depthAttachmentPixelFormat = Preferences.DepthPixelFormat
        descriptor.vertexFunction = vertexFunction
        descriptor.fragmentFunction = fragmentFunction
        descriptor.vertexDescriptor = vDescriptor
            
        return descriptor
    }

    static func getRenderPipelineState(descriptor: MTLRenderPipelineDescriptor) -> MTLRenderPipelineState? {
        do {
            return try Device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
}
