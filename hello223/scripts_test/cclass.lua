
local function getArrayType( c )
	if c=="C" then
		return "string" --type("")
	else
		return "userdata"
	end
end

local function getRetType( typeString )
	if not typeString then
		return
	end

	local c = string.sub(typeString, 1, 1)
	if c=="[" then
		return getArrayType( string.sub(typeString, 2, 2) )
	elseif c=="Z" then
		return "boolean"
	elseif c=="I" then
		return "number"
	elseif c=="F" then
		return "number"
	end

	return "cclass", string.sub(typeString, 2, -2)
end

-- if cls is a "cclass" and not a "cclass object" return true
function cclass_is_class( cls )
	if type(cls)~="table" then return false end
	local mt = getmetatable(cls)
	if not mt or not mt.classname_ then return false end
	if cclass_is_obj(cls) then return false end
	return true
end

-- if obj is a "cclass object" return true
function cclass_is_obj( obj )
	if not obj.udata_ then return false end

	return true
end

local function wrapObj(udata, mt)
	local obj = {}
	obj.udata_ = udata
	setmetatable(obj, mt)
	return obj
end

local function convert_args( args, types )
	-- dump(args)
	local args_new = {nil}
	if type(types)~="table" then return args_new end

	local n
	local typeWant
	local typeCur
	for i,v in ipairs(types) do
		-- local arg = args[i]
		n = i
		typeCur = cclass_type_name(args[i])
		typeWant = v
		if cclass_type_compare( typeCur, typeWant, cc ) then 
			typeCur = typeWant
		else
			break 
		end
		if type(args[i])~=typeCur then
			if not args[i].udata_ then 
				typeCur = type(args[i])
				break
			end
			args[i] = args[i].udata_
		end
	end	

	-- dump(args)
	if typeCur==typeWant then return args end

	print("[CCLASS ERR] bad argument #"..n.."("..typeWant.." expected, got "..typeCur)
end

local function convert_args1( args )
	for i,v in ipairs(args) do
		if type(v)=="table" and v.udata_ then
			args[i] = v.udata_
		end
	end

	return args
end

local function split_sign_string( str )
	if not str or string.len(str)<1 then return true end
	local args = string.split(str, '|')
	-- dump(args)
	for i,v in ipairs(args) do
		if v=='F' or v=='I' or v=='J' then 
			args[i] = "number" 
		elseif v=='T' then
			args[i] = "string"
		elseif v=='Z' then 
			args[i] = "boolean"
		end
	end
	-- dump(args)
	return args
end

local cclass_is_class_ = cclass_is_class
local cclass_is_obj_ = cclass_is_obj

local function call_cfunction_evt( mt, evt, evtname, ... )
	-- print("call_cfunction_evt--------->")
	-- dump(evt)
	-- if not evt.mothodParamsType then
	-- 	evt.mothodParamsType = split_sign_string(evt.methodSign)
	-- end

	local args = {...}
	local self_obj = args[1]
	-- if cclass_is_class_(self_obj) then
	-- 	-- somebady should use "Class:Func"
	-- 	-- remove the extra param
	-- 	table.remove(args,1)
	-- elseif not cclass_is_obj_(self_obj) then
	-- 	self_obj = nil
	-- end
	if not cclass_is_obj_(self_obj) then
		self_obj = nil
	end

	-- args = convert_args( args, evt.mothodParamsType )
	-- args = convert_args1( args )
	-- if not args then
	-- 	print("[CCLASS ERR] Error in "..mt.classname_..":"..evtname)
	-- 	return
	-- end
	-- dump(args)

	local retType = getRetType(evt.retType)
	-- if return void, return self object instead
	if not retType then
		-- evt.cfunc(unpack(args))
		evt.cfunc(...)
		return self_obj
	-- return c-object
	elseif retType=="cclass" then
		-- local udata = evt.cfunc(unpack(args))
		local udata = evt.cfunc(...)
		return wrapObj(udata, mt)
	end

	-- return normal
	-- return evt.cfunc(unpack(args))
	return evt.cfunc(...)
end

function cclass_has_super( obj, supername )
		local mt_ = getmetatable(obj)
		if not mt_ then return false end
		-- print("cclass_has_super("..mt_.classname_..","..supername..")")

		for i,v in ipairs(mt_.cclass_super) do
			-- print("cclass_has_super: v="..v)
			if v==supername then return true end
			local super_ = mt_.namespace_[v]
			if cclass_has_super( super_, supername ) then
				return true
			end
		end

		return false
end

local function cclass_mt_index( target, keyname )
		-- find function in metatable
		local mt_ = getmetatable(target)

		local evt = mt_[keyname]
		if evt then
			if type(evt)~="table" or not evt.cfunc then
				return evt
			end

			local function evt_func( ... )
				return call_cfunction_evt(mt_, evt, keyname, ...)
			end

			return evt_func
		end

		-- find function in super classes
		for i,v in ipairs(mt_.cclass_super) do
			local super_ = mt_.namespace_[v]
			if super_[keyname] then
				return super_[keyname]
			end
		end
end

function cclass(classname, namespace, aliasname)
	-- check namespace
	if type(namespace)~="table" then
		print("namespace error!")
		return
	end

	-- check if classname has been declared
	if namespace[classname] then
		print("CClass "..classname.." registered")
		return
	end

	-- load cclass
	local mt, err = lua_binder.load(classname)
	if (mt==nil) then
		print("CClass Error: "..err)
		return
	end

	-- set namespace
	mt.namespace_ = namespace
	-- set classname
	mt.classname_ = classname

	-- set __index
	mt.__index = cclass_mt_index

	-- dump(mt)
	local cls = {}
	setmetatable(cls, mt)
	namespace[classname] = cls
	if aliasname then 
		namespace[aliasname] = cls
	end
end

-- param "cur" & "want" is string of class name
-- param "ns" is namespace
-- if cur==want or class(want) is super class of class(cur), return true
function cclass_type_compare( cur, want, ns )
	if cur==want then return true end
	if cclass_has_super(ns[cur], want) then return true end

	return false
end

-- if obj is cclass type, return it's real class name
-- otherwise, return type(obj)
function cclass_type_name( obj )
	local t = type(obj)
	-- print("cclass_type_name: t= "..t)
	if t~="table" and t~="userdata" then return t end
	local mt = getmetatable(obj)
	-- print(mt)
	-- print(mt.classname_)
	if mt and mt.classname_ then
		return mt.classname_
	else
		return t
	end
end

local function CClass(classname, namespace)
	-- check if classname has been declared
	local nsn = namespace.cclass_namespace_name
	if namespace[classname] then
		print("CClass "..nsn.."."..classname.." registered")
		return
	end
	print("start register: "..nsn.."."..classname)
	-- ALL_CCLASS_REG = ALL_CCLASS_REG or {}
	-- local mt = ALL_CCLASS_REG[classname]
	-- if (mt~=nil) then return end

	-- dump(QUICKX_CCLASS_REG_FUNC)

	-- mt = {}
	local mt, err = lua_binder.load(classname)
	if (mt==nil) then
		print("CClass Error: "..err)
		-- return
		mt = {}
	end
	mt.namespace_string = namespace.cclass_namespace_name
	-- dump(mt)

	mt.__index = cclass_mt_index

	local cls = {}
	setmetatable(cls, mt)
	-- rawset(_G, classname, cls)
	-- dump(_G[classname])
	namespace[classname] = cls

	-- ALL_CCLASS_REG[classname] = mt
end

function CClassNameSpace( name )
	if type(_G[name])=="table" then
		return
	end

	local mt = {}
	mt.cclass_namespace_name = name
	mt.__index = function ( target, k )
		local mt_ = getmetatable(target)
		if mt_[k] then return mt_[k] end
		CClass(k, mt_)
		return mt_[k]
	end

	local ns = {}
	-- ns.cclass_namespace_name = "ns_"..name
	setmetatable(ns, mt)
	rawset(_G, name, ns)
end

