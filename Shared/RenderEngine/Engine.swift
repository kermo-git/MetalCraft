import MetalKit

// Cube mapping: https://metalbyexample.com/reflection-and-refraction/
// Shadow mapping: https://github.com/carolight/Metal-Shadow-Map

class Engine {
    static let device: MTLDevice = MTLCreateSystemDefaultDevice()!
    static let commandQueue: MTLCommandQueue = device.makeCommandQueue()!
    static let library: MTLLibrary = device.makeDefaultLibrary()!
    static let depthStencil: MTLDepthStencilState = getDepthStencilState()
    static let sampler: MTLSamplerState = getSamplerState()
    
    static let pixelFormat = MTLPixelFormat.bgra8Unorm
    static let depthPixelFormat = MTLPixelFormat.depth32Float
    
    static func loadTexture(fileName: String, 
                            loader: MTKTextureLoader = MTKTextureLoader(device: device),
                            fileExtension: String = "png",
                            origin: MTKTextureLoader.Origin = MTKTextureLoader.Origin.topLeft) -> MTLTexture {
        
        var result: MTLTexture!
        
        if let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) {
            
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
    
    static func loadTextureArray(fileNames: [String], imageWidth: Int, imageHeight: Int) -> MTLTexture {
        let descriptor = MTLTextureDescriptor()
        descriptor.textureType = .type2DArray
        descriptor.pixelFormat = pixelFormat
        descriptor.width = imageWidth
        descriptor.height = imageHeight
        descriptor.depth = 1
        descriptor.mipmapLevelCount = 1
        descriptor.sampleCount = 1
        descriptor.arrayLength = fileNames.count
        descriptor.allowGPUOptimizedContents = true
        descriptor.usage = .shaderRead
        
        let textureArray = device.makeTexture(descriptor: descriptor)!
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let encoder = commandBuffer.makeBlitCommandEncoder()!
        let loader = MTKTextureLoader(device: device)
        
        for (i, fileName) in fileNames.enumerated() {
            let texture = loadTexture(fileName: fileName, loader: loader)
            
            encoder.copy(
                from: texture, sourceSlice: 0, sourceLevel: 0,
                to: textureArray, destinationSlice: i, destinationLevel: 0,
                sliceCount: 1, levelCount: 1
            )
        }
        encoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        return textureArray
    }
    
    static func getSamplerState() -> MTLSamplerState {
        let descriptor = MTLSamplerDescriptor()
        descriptor.minFilter = .nearest
        descriptor.magFilter = .nearest
        descriptor.mipFilter = .linear
        return device.makeSamplerState(descriptor: descriptor)!
    }

    static func getDepthStencilState() -> MTLDepthStencilState {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.isDepthWriteEnabled = true
        descriptor.depthCompareFunction = .less
        return device.makeDepthStencilState(descriptor: descriptor)!
    }

    static func getRenderPipelineState(vertexShaderName: String,
                                       fragmentShaderName: String,
                                       vertexDescriptor: MTLVertexDescriptor) -> MTLRenderPipelineState? {
        
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].pixelFormat = pixelFormat
        descriptor.depthAttachmentPixelFormat = depthPixelFormat
        descriptor.vertexFunction = library.makeFunction(name: vertexShaderName)
        descriptor.fragmentFunction = library.makeFunction(name: fragmentShaderName)
        descriptor.vertexDescriptor = vertexDescriptor
        
        do {
            return try device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
}
