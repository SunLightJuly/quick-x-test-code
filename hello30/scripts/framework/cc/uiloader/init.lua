
local uiloader = class("uiloader")
local ccsloader = import(".ccsloader")

function uiloader:ctor()
end

function uiloader:load(jsonFile)
	return ccsloader:load(jsonFile)
end

return uiloader
