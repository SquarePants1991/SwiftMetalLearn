//
//  Shaders.metal
//  SwiftMetalLearn
//
//  Created by wangyang on 2017/5/2.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

struct VertexInOut
{
    float4  position [[position]];
    float4  color;
};
struct Uniforms
{
    float4x4 transform;
};

vertex VertexInOut passThroughVertex(uint vid [[ vertex_id ]],
                                     constant packed_float4* position  [[ buffer(0) ]],
                                     constant Uniforms& transform    [[ buffer(1) ]])
{
    VertexInOut outVertex;
    
    outVertex.position = transform.transform * float4(position[vid]);
    outVertex.color    = float4(1.0,0.0,0.0,1.0);
    
    return outVertex;
};

fragment half4 passThroughFragment(VertexInOut inFrag [[stage_in]])
{
    return half4(inFrag.color);
};
