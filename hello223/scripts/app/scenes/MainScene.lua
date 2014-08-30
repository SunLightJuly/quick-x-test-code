
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
	local lbl = 
    ui.newTTFLabel({text = "Hello, World", size = 64, align = ui.TEXT_ALIGN_CENTER})
        :pos(display.cx, display.cy)
        :addTo(self)
end

function MainScene:onTouch(event, x, y)

    if event == "began" then
        print("3----numObjs: ", TestClass:getNumObjs())
        print("gc_count", collectgarbage("count"))

        if self.stopFlag then
            self.stopFlag = false
        else
            self.stopFlag = true
            collectgarbage("collect")
            print("4----numObjs: ", TestClass:getNumObjs())
            print("gc_count", collectgarbage("count"))
        end
        -- local p = CCPoint(x, y)
        -- if self.addCoinButtonBoundingBox:containsPoint(p) then
        --     self.state = "ADD"
        -- elseif self.removeCoinButtonBoundingBox:containsPoint(p) then
        --     self.state = "REMOVE"
        -- else
        --     self.state = "IDLE"
        -- end
        return true
    elseif event ~= "moved" then
        self.state = "IDLE"
    end
end

function MainScene:onEnterFrame(dt)
    if self.stopFlag then
        return
    end

    print("1----numObjs: ", TestClass:getNumObjs())

    local t = {}
    for i=1,1000 do
        table.insert(t, TestClass())
    end
    print("2----numObjs: ", TestClass:getNumObjs())
            -- collectgarbage("collect")
            -- print("C----numObjs: ", TestClass:getNumObjs())
            print("gc_count", collectgarbage("count"))
end

function MainScene:onEnter()
    -- dump(TestClass)
    -- local mt = getmetatable(TestClass)
    -- dump(mt)
    print("0----numObjs: ", TestClass:getNumObjs())
    print("gc_count", collectgarbage("count"))

    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt) self:onEnterFrame(dt) end)
    self:scheduleUpdate_()

    self.layer = display.newLayer():addTo(self)
    self.layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        return self:onTouch(event.name, event.x, event.y)
    end)
    self.layer:setTouchEnabled(true)
end

function MainScene:onExit()
end

return MainScene
