
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    local label = ui.newTTFLabel({
        text = "Hello, 你好！",
        size = 64,
        x = display.cx,
        y = display.cy,
        align = ui.TEXT_ALIGN_CENTER
    })
    self:addChild(label)
end

function MainScene:onEnter()
    mk = require("mkflist")
    --mk:run("files")
    mk:convertLF("files")

    if device.platform ~= "android" then return end

    -- avoid unmeant back
    self:performWithDelay(function()
        -- keypad layer, for android
        local layer = display.newLayer()
        layer:addKeypadEventListener(function(event)
            if event == "back" then game.exit() end
        end)
        self:addChild(layer)

        layer:setKeypadEnabled(true)
    end, 0.5)
end

return MainScene
