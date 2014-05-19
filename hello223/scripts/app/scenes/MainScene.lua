
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

require("cclass")
CClass("CCNodeTest")

function MainScene:ctor()
	-- local node_t = CCNodeTest:create()
	print(CCNodeTest.test("test string!!!"))

    ui.newTTFLabel({text = "Hello, 世界", size = 64, align = ui.TEXT_ALIGN_CENTER})
        :pos(display.cx, display.cy)
        :addTo(self)
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
