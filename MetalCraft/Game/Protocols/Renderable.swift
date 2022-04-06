import Metal

protocol Renderable {
    func doRender(_ encoder: MTLRenderCommandEncoder)
}
