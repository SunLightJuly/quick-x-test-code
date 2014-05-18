
function CClass(classname)
	-- check if classname has been declared
	-- ALL_CCLASS_REG = ALL_CCLASS_REG or {}
	local mt = ALL_CCLASS_REG[classname]
	-- print("mt="..mt)
	if (mt~=nil) then return end

	local s = lua_binder.load(classname)
	print(s)
	lua_binder.load(nil)
end