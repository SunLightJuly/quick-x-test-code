print("==============================test ffi")

local ffi = require("ffi")

print("==============================test ffi 1", ffi)

ffi.cdef[[
//int luabinderload(const char * classname);
//int test_add_xy(int x, int y);
int printf(const char*, ...);
]]

print("==============================test ffi 2", ffi)

local rni = ffi.C.printf("Hello %s!\n", "world")
-- local rni = ffi.C.luabinderload("CCNodeTest")
-- local rni = ffi.C.test_add_xy(26, 24)
print("rni···:", rni)

return ffi
