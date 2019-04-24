---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ThinkPad E475.
--- DateTime: 2019/4/15 11:15
---

OpenList = require("obj.OpenList")
CloseList = require("obj.CloseList")
PathNode = require("obj.PathNode")

Astar = {}

-- 地图数据
-- 0:可通行
-- 1:不可通行(障碍物)
-- 2:路径点
Astar.map = nil


Astar.girdX = 8 -- 地图x轴大小
Astar.girdY = 8 -- 地图y轴大小
Astar.girdZ = 8 -- 地图z轴大小
Astar.openList = nil
Astar.closeList = nil

--获取最短路径
-- map:地图对象
-- ox,oy,oz:起点坐标
-- dx,dy,dz:终点坐标
-- dir:方向
function Astar.getPath(map,ox,oy,oz,dx,dy,dz,dir,reverse)
    -- init
    Astar.map = map
    Astar.openList = OpenList:new()
    Astar.closeList = CloseList:new()
    --
    local pathList = {}
    local originNode = PathNode:new(ox,oy,oz,dir,0,Astar.calcH(ox,oy,oz,dx,dy,dz))
    Astar.openList:add(originNode)

    while true do
        local minFNote = Astar.openList:getMinF()
        Astar.openList:remove(minFNote)
        Astar.closeList:add(minFNote)
        local aroundNotes = Astar.getNodeAround(minFNote)
        for k,arouNote in pairs(aroundNotes) do
            if not Astar.openList:contains(arouNote) then
                if arouNote.rot==0 or arouNote.rot==1 then
                    arouNote.rot=minFNote.rot
                end
                arouNote.father = minFNote
                local rotPrice = Astar.getRotatePrice(arouNote,minFNote)
                arouNote:setF(minFNote.g+1+rotPrice, Astar.calcH(arouNote.x,arouNote.y,arouNote.z,dx,dy,dz))
                Astar.openList:add(arouNote)
                if arouNote.x == dx and arouNote.y == dy and arouNote.z == dz then
                    local tempPathList = {}
                    local currNote = arouNote
                    while currNote do
                        table.insert(tempPathList, currNote)
                        currNote = currNote.father
                    end
                    if reverse then
                        return tempPathList
                    end
                    for i=#tempPathList,1,-1 do
                        table.insert(pathList, tempPathList[i])
                    end
                    --test
                    for k,v in pairs(Astar.closeList.close) do
                        Astar.setMapData(v.x,v.y,v.z,3)
                    end
                    --
                    return pathList
                end
            end
        end
        if Astar.openList:isEmpty() then
            break
        end
    end
    return nil
end

-- 获取某坐标位置的数据
function Astar.getPosInfo(x,y,z)
    return map:getPosInfo(x,y,z)
end

function Astar.calcH(x,y,z,dx,dy,dz)
    return 1.1*math.abs(x-dx)+math.abs(y-dy)+math.abs(z-dz)
end

--获取节点转向成本
-- node1:当前节点
-- node2:父节点
-- 0-5依次为下上北南西东
function Astar.getRotatePrice(node1, node2)
    --if node1.rot==node2.rot then
    --    return 0
    --elseif (node1.rot==2 and node2.rot==4) or (node1.rot==2 and node2.rot==5) or
    --        (node1.rot==3 and node2.rot==4) or (node1.rot==3 and node2.rot==5) or
    --        (node2.rot==2 and node1.rot==4) or (node2.rot==2 and node1.rot==5) or
    --        (node2.rot==3 and node1.rot==4) or (node2.rot==3 and node1.rot==5) then
    --    return 1
    --elseif (node1.rot==2 and node2.rot==3) or (node1.rot==3 and node2.rot==2) or
    --        (node1.rot==4 and node2.rot==5) or (node1.rot==5 and node2.rot==4) then
    --    return 2
    --end
    return 0
end

--检查格子是否符合条件
--忽略超出地图节点、障碍物节点、在closeList当中的节点
function Astar.checkNode(node)
    local x,y,z = node.x,node.y,node.z
    local ntype = Astar.getPosInfo(x,y,z)
    if not ntype then
        return false
    end
    if ntype == 1 then
        return false
    end
    if Astar.closeList:contains(node) then
        return false
    end
    return true
end

--获取周围的格子
function Astar.getNodeAround(node)
    local x,y,z = node.x, node.y, node.z
    local nodeList = {
        PathNode:new(x, y, z+1, 1),
        PathNode:new(x, y, z-1, 0),
        PathNode:new(x+1, y, z, 5),
        PathNode:new(x-1, y, z, 4),
        PathNode:new(x, y+1, z, 2),
        PathNode:new(x, y-1, z, 3),
    }
    local newList = {}
    for k,v in pairs(nodeList) do
        if Astar.checkNode(v) then
            table.insert(newList, v)
        end
    end
    return newList
end

--打印地图
-- sidex,sidey:地图显示大小
function Astar.printMap(pathList,sizex,sizey,sizez)
    local index = 1
    for z=0,sizez-1 do
        for y=0,sizey-1 do
            for x=0,sizex-1 do
                local node = Astar.getPosInfo(x,y,z)
                local hasNote = false
                if pathList and index<=#pathList then
                    for k,v in pairs(pathList) do
                        if x==v.x and y==v.y and z==v.z then
                            io.stdout:write(string.format(" %-2d", k))
                            index = index+1
                            hasNote = true
                            break
                        end
                    end
                end
                if not hasNote then
                    if node==0 then
                        io.stdout:write(" - ")
                    elseif node==1 then
                        io.stdout:write(" # ")
                    elseif node==2 then
                        io.stdout:write(" * ")
                    elseif node==3 then
                        io.stdout:write(" ! ")
                    end
                end
            end
            io.stdout:write("\n")
        end
        io.stdout:write("z="..tostring(z).."---------------\n")
    end
end

function Astar.setMapData(x,y,z,data)
    map:setPosInfo(x,y,z,data)
end

return Astar