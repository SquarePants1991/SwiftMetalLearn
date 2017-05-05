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
    var projectionMatrix: GLKMatrix4 = GLKMatrix4Identity
    var viewMatrix: GLKMatrix4 = GLKMatrix4Identity
    var modelMatrix: GLKMatrix4 = GLKMatrix4Identity
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initBuffers()
        viewMatrix = GLKMatrix4Identity
    }
    
    override func update(timeInterval: CFTimeInterval) {
        let aspect: Float = Float(self.view.frame.size.width / self.view.frame.size.height)
        projectionMatrix = GLKMatrix4MakePerspective(90, aspect, 0.1, 1000)
        
        viewMatrix = GLKMatrix4MakeLookAt(0, 0, sin(Float(self.elapsedTime)) + 1.0, 0, 0, 0, 0, 1, 0)
        
        let translateMatrix = GLKMatrix4MakeTranslation(0, 0, -1)
        let rotateMatrix = GLKMatrix4MakeRotation(Float(self.elapsedTime), 0, 1, 0)
        modelMatrix = GLKMatrix4Multiply(translateMatrix, rotateMatrix)
        
        // 更新uniform的缓冲区
        let matrixSize = MemoryLayout<Float>.size * 16
        let uniformBufferPointer = uniformBuffer.contents()
        memcpy(uniformBufferPointer, projectionMatrix.raw, matrixSize)
        memcpy(uniformBufferPointer + MemoryLayout<Float>.size * 16, viewMatrix.raw, matrixSize)
        memcpy(uniformBufferPointer + MemoryLayout<Float>.size * 16 * 2, modelMatrix.raw, matrixSize)
    }
    
    override func draw(renderEncoder: MTLRenderCommandEncoder) {
        self.drawTriangles(renderEncoder: renderEncoder)
    }
    
    func initBuffers() {
        let uniformBufferSize = MemoryLayout<Float>.size * 16 * 3
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
}
