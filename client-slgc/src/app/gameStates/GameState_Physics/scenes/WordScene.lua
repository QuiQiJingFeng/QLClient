local WordScene = class("WordScene",function() 
    return cc.Scene:createWithPhysics()
end)

function WordScene:ctor()
    local physicsWord = self:getPhysicsWorld()
    physicsWord:setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)

    local layer = cc.Layer:create()
    self:addChild(layer,1)

    local wall = cc.Node:create()
    wall:setPhysicsBody(cc.PhysicsBody:createEdgeBox(display.size,cc.PhysicsMaterial(0.1, 1.0, 0.0)))
    wall:setPosition(display.center );
    self:addChild(wall)
    layer:setCameraMask(cc.CameraFlag.USER1)


    self._camera = cc.Camera:createOrthographic(display.width,display.height,0,1)
    self._camera:setCameraFlag(cc.CameraFlag.USER1)
    self:addChild(self._camera)
    self._camera:setPosition3D(cc.vec3(0, 0, 0))
    self._camera:setDepth(1)

    local MATERIAL_DEFAULT = cc.PhysicsMaterial(0.1, 0.5, 0.5)
    local temp = cc.Sprite:create("art/img/Icon_face.png")
    temp:setPosition(cc.p(500,100))
    local body = cc.PhysicsBody:createBox(temp:getContentSize(), MATERIAL_DEFAULT)
    temp:setPhysicsBody(body)
    self:addChild(temp,1)
    temp:setCameraMask(cc.CameraFlag.USER1)
    
    local role = cc.Sprite:create("art/img/Icon_face.png")
    self._roleOriginPos = cc.p(200,role:getContentSize().height/2)
    role:setPosition(self._roleOriginPos)
    local body = cc.PhysicsBody:createBox(role:getContentSize(), MATERIAL_DEFAULT)
    role:setPhysicsBody(body)
    layer:addChild(role)
    role:setCameraMask(cc.CameraFlag.USER1)

    
    local diffX = 1
    game.Util:scheduleUpdate(function() 
        diffX = diffX + 1
        self._camera:setPositionX( diffX)
        print("FYD=-=====>diffX=",diffX)
    end, 0)

    self:registerScriptHandler(function(event)
        if "enter" == event then
            local ui = game.UIManager:getInstance():show("UIHelp")
            -- ui:setCameraMask(cc.CameraFlag.USER1)
        elseif "exit" == event then
        end
    end)
end

return WordScene