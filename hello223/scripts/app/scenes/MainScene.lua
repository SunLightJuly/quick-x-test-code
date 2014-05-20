
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

require("cclass")
CClassNameSpace("ccx")

-- local cc = {}

cclass("CCNodeTest", cc, "NodeTest")
cclass("CCSpriteTest", cc, "SpriteTest")

function MainScene:ctor()
	-- local node_t = CCNodeTest:create()
	-- local sprite = cc.Sprite:create()


	print(cc.SpriteTest:setPosition(10, 10).test("test cc.spritetest!!!"))

	-- print(ccx.CCSpriteTest.test("test sprite!!!"))
	-- print(ccx.CCNodeTest.test("test string!!!"))
	-- print(ccx.CCNodeTest.test("test string again!!!"))

    ui.newTTFLabel({text = "Hello, 世界", size = 64, align = ui.TEXT_ALIGN_CENTER})
        :pos(display.cx, display.cy)
        :addTo(self)
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
