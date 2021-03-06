//
//  Shaders.metal
//  SwiftMetalLearn
//
//  Created by wangyang on 2017/5/2.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

struct VertexIn
{
    packed_float3  position;
    packed_float3  color;
};

struct VertexOut
{
    float4  position [[position]];
    float4  color;
    float pointSize [[ point_size ]];
};
struct Uniforms
{
    float4x4 projectionMatrix;
    float4x4 viewMatrix;
    float4x4 modelMatrix;
};


vertex VertexOut passThroughVertex(uint vid [[ vertex_id ]],
                                     const device VertexIn* vertexIn [[ buffer(0) ]],
                                     const device Uniforms& uniform [[ buffer(1) ]])
{
    VertexOut outVertex;
    VertexIn inVertex = vertexIn[vid];
    float4x4 mvp = uniform.projectionMatrix * uniform.viewMatrix * uniform.modelMatrix;
    outVertex.position = mvp * float4(inVertex.position, 1.0);
    outVertex.color = float4(inVertex.color, 1.0);
    
    outVertex.pointSize = 20;
    return outVertex;
};

fragment half4 passThroughFragment(VertexOut inFrag [[stage_in]])
{
    return half4(inFrag.color);
};
