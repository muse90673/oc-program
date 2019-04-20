---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ThinkPad E475.
--- DateTime: 2019/4/15 0:25
---

PathNode = {}
PathNode.__index = PathNode

-- rot：节点当前朝向
function PathNode:new(x,y,z,rot,g,h,father)
    local o = {}
    setmetatable(o, PathNode)
    o.x = x
    o.y = y
    o.z = z
    o.rot = rot
    o.g = g or 0
    o.h = h or 0
    o.f = o.g+o.h
    o.father = father or nil
    return o
end

function PathNode:setF(g, h)
    self.g = g
    self.h = h
    self.f = g+h
end

function PathNode:setG(g)
    self.g = g
    self.f = g+self.h
end

function PathNode:show()
    return tostring(self.x)..","..tostring(self.y)..","..tostring(self.z)..", rot="..tostring(self.rot)..
        ",g="..self.g
end
return PathNode