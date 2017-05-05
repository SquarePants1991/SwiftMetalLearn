//
//  MainViewController.swift
//  SwiftMetalLearn
//
//  Created by wangyang on 2017/5/5.
//  Copyright © 2017年 wangyang. All rights reserved.
//

import UIKit
import GLKit

class MainViewController: BaseViewController {

    var vertexBuffer: MTLBuffer! = nil
    var uniformBuffer: MTLBuffer! = nil
    var transform: GLKMatrix4 = GLKMatrix4Identity
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initBuffers()
    }
    
    override func update(timeInterval: CFTimeInterval) {
        transform = GLKMatrix4MakeRotation(Float(self.elapsedTime), 0, 0, 1)
        
        // 更新uniform的缓冲区
        let uniformBufferSize = MemoryLayout<Float>.size * 16
        let uniformBufferPointer = uniformBuffer.contents()
        memcpy(uniformBufferPointer, transform.raw, uniformBufferSize)
    }
    
    override func draw(renderEncoder: MTLRenderCommandEncoder) {
        self.drawTriangles(renderEncoder: renderEncoder)
        self.drawLines(renderEncoder: renderEncoder)
        self.drawPoints(renderEncoder: renderEncoder)
    }
    
    func initBuffers() {
        let uniformBufferSize = MemoryLayout<Float>.size * 16
        uniformBuffer = device.makeBuffer(length: uniformBufferSize, options: MTLResourceOptions.cpuCacheModeWriteCombined)
        uniformBuffer.label = "uniforms"
    }
    
    // MARK: Draw Methods
    func drawTriangles(renderEncoder: MTLRenderCommandEncoder) {
        let vertexData:[Float] = [
            -0.5,   0.5,  0.0,   0,  0,  1,
            -0.5,  -0.5,  0.0,  0,  0,  1,
            0.5,   -0.5,  0.0,  0,  0,  1,
            0.5,    -0.5, 0.0,   0,  0,  1,
            0.5,  0.5,  0.0,    0,  0,  1,
            -0.5,   0.5,  0.0,  0,  0,  1
        ]
        let vertexBufferSize = MemoryLayout<Float>.size * vertexData.count
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: vertexBufferSize, options: MTLResourceOptions.cpuCacheModeWriteCombined)
        vertexBuffer.label = "vertices"
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, at: 1)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6, instanceCount: 1)
    }
    
    func drawTriangleStrip(renderEncoder: MTLRenderCommandEncoder) {
        let vertexData:[Float] = [
            -0.5,  -0.5,  0.0,  0,  0,  1,
            0.5,   -0.5,  0.0,  0,  0,  1,
            -0.5,   0.5,  0.0,   0,  0,  1,
            0.5,  0.5,  0.0,    0,  0,  1,
        ]
        let vertexBufferSize = MemoryLayout<Float>.size * vertexData.count
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: vertexBufferSize, options: MTLResourceOptions.cpuCacheModeWriteCombined)
        vertexBuffer.label = "vertices"
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, at: 1)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: 1)
    }
    
    func drawLines(renderEncoder: MTLRenderCommandEncoder) {
        let vertexData:[Float] = [
            -0.5,   0.5,  0.0,   1,  1,  1,
            -0.5,  -0.5,  0.0,  1,  1,  1,
            -0.5,  -0.5,  0.0,  1,  1,  1,
            0.5,   -0.5,  0.0,  1,  1,  1,
            0.5,   -0.5,  0.0,  1,  1,  1,
            0.5,  0.5,  0.0,    1,  1,  1,
            0.5,  0.5,  0.0,    1,  1,  1,
            -0.5,   0.5,  0.0,   1,  1,  1,
            ]
        let vertexBufferSize = MemoryLayout<Float>.size * vertexData.count
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: vertexBufferSize, options: MTLResourceOptions.cpuCacheModeWriteCombined)
        vertexBuffer.label = "vertices"
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, at: 1)
        renderEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: 8, instanceCount: 1)
    }
    
    func drawLineStrip(renderEncoder: MTLRenderCommandEncoder) {
        let vertexData:[Float] = [
            -0.5,   0.5,  0.0,   1,  1,  1,
            -0.5,  -0.5,  0.0,  1,  1,  1,
            0.5,   -0.5,  0.0,  1,  1,  1,
            0.5,  0.5,  0.0,    1,  1,  1,
            -0.5,   0.5,  0.0,   1,  1,  1,
            ]
        let vertexBufferSize = MemoryLayout<Float>.size * vertexData.count
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: vertexBufferSize, options: MTLResourceOptions.cpuCacheModeWriteCombined)
        vertexBuffer.label = "vertices"
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, at: 1)
        renderEncoder.drawPrimitives(type: .lineStrip, vertexStart: 0, vertexCount: 4, instanceCount: 1)
    }
    
    func drawPoints(renderEncoder: MTLRenderCommandEncoder) {
        let vertexData:[Float] = [
            -0.5,   0.5,  0.0,   1,  0,  1,
            -0.5,  -0.5,  0.0,  1,  0,  1,
            0.5,   -0.5,  0.0,  1,  0,  1,
            0.5,  0.5,  0.0,    1,  0,  1,
            ]
        let vertexBufferSize = MemoryLayout<Float>.size * vertexData.count
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: vertexBufferSize, options: MTLResourceOptions.cpuCacheModeWriteCombined)
        vertexBuffer.label = "vertices"
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, at: 1)
        renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: 4, instanceCount: 1)
    }
}
