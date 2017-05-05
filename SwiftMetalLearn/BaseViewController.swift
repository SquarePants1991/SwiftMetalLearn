//
//  GameViewController.swift
//  SwiftMetalLearn
//
//  Created by wangyang on 2017/5/2.
//  Copyright © 2017年 wangyang. All rights reserved.
//

import UIKit
import Metal
import MetalKit
import GLKit

class BaseViewController: UIViewController {
    
    var device: MTLDevice! = nil
    
    var commandQueue: MTLCommandQueue! = nil
    var pipelineState: MTLRenderPipelineState! = nil
    var pipelineStateDescriptor: MTLRenderPipelineDescriptor! = nil;
    var metalLayer: CAMetalLayer! = nil
    let sampleCount: Int = 4
    
    var lastUpdateTime: CFTimeInterval = 0
    var displayLink: CADisplayLink! = nil
    var elapsedTime: CFTimeInterval = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initMetal()
        initPipline()
        initRenderLoop()
    }
    
    func initMetal() {
        device = MTLCreateSystemDefaultDevice()
        guard device != nil else { // Fallback to a blank UIView, an application could also fallback to OpenGL ES here.
            print("Metal is not supported on this device")
            self.view = UIView(frame: self.view.frame)
            return
        }
        
        metalLayer = CAMetalLayer()         
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true   
        metalLayer.frame = view.layer.frame 
        view.layer.addSublayer(metalLayer)
    }
    
    func initPipline() {
        commandQueue = device.makeCommandQueue()
        commandQueue.label = "main metal command queue"
        
        let defaultLibrary = device.newDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "passThroughFragment")!
        let vertexProgram = defaultLibrary.makeFunction(name: "passThroughVertex")!
        
        self.pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = metalLayer.pixelFormat
        pipelineStateDescriptor.sampleCount = sampleCount
        
        do {
            try pipelineState = device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let error {
            print("Failed to create pipeline state, error \(error)")
        }
    }
    
    func initRenderLoop() {
        self.displayLink = CADisplayLink(target: self, selector: #selector(renderLoop))
        self.displayLink.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        self.lastUpdateTime = self.displayLink.timestamp
    }
    
    func renderLoop() {
        let currentTime = self.displayLink.timestamp
        _update(timeInterval: currentTime - self.lastUpdateTime)
        self.lastUpdateTime = currentTime
    }
    
    func _update(timeInterval: CFTimeInterval) {
        self.elapsedTime += timeInterval
        self.update(timeInterval: timeInterval)
        
        guard let drawable = metalLayer?.nextDrawable() else { return }
        let renderPassDescriptor = genMultisampleRenderPassDescriptor(sampleCount: sampleCount, texture: drawable.texture)
        let commandBuffer = commandQueue.makeCommandBuffer()
        commandBuffer.label = "Frame command buffer"
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoder.label = "render encoder"
        renderEncoder.pushDebugGroup("begin draw")
        renderEncoder.setRenderPipelineState(pipelineState)
       
        self.draw(renderEncoder: renderEncoder)
        
        renderEncoder.popDebugGroup()
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func genMultisampleRenderPassDescriptor(sampleCount: Int, texture: MTLTexture) -> MTLRenderPassDescriptor {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: texture.pixelFormat, width: texture.width, height: texture.height, mipmapped: false)
        desc.textureType = MTLTextureType.type2DMultisample;
        desc.sampleCount = sampleCount;
        let multisampleTexture = device.makeTexture(descriptor: desc)
        renderPassDescriptor.colorAttachments[0].texture = multisampleTexture
        renderPassDescriptor.colorAttachments[0].resolveTexture = texture
        
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreAction.multisampleResolve
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0, blue: 0, alpha: 1.0)
        return renderPassDescriptor
    }

    func update(timeInterval: CFTimeInterval) {

    }
    
    func draw(renderEncoder: MTLRenderCommandEncoder) {

    }
}
