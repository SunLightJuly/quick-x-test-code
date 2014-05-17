
function CClass(classname)
	-- check if classname has been declared
	ALL_CCLASS_REG = ALL_CCLASS_REG or {}
	local mt = ALL_CCLASS_REG[classname]
	if (mt~=nil) then return end

end