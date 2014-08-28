
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
        local p = CCPoint(x, y)
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
end

function MainScene:onEnter()
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt) self:onEnterFrame(dt) end)
    self:scheduleUpdate_()
    -- self.layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
    --     return self:onTouch(event.name, event.x, event.y)
    -- end)
    -- self.layer:setTouchEnabled(true)
end

function MainScene:onExit()
end

return MainScene
