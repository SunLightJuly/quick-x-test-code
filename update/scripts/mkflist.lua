
local function readFile(path)
    local file = io.open(path, "rb")
    if file then
        local content = file:read("*all")
        io.close(file)
        return content
    end
    return nil
end

require "lfs"

local function findindir (path, wefind, r_table, intofolder) 
    for file in lfs.dir(path) do 
        if file ~= "." and file ~= ".." then 
            local f = path.."\\"..file 
            --print ("\t "..f) 
            if string.find(f, wefind) ~= nil then 
                --print("\t "..f) 
                table.insert(r_table, f) 
            end 
            --[[
            local attr = lfs.attributes (f) 
            assert (type(attr) == "table") 
            if attr.mode == "directory" and intofolder then 
                findindir (f, wefind, r_table, intofolder) 
            else 
                for name, value in pairs(attr) do 
                    print (name, value) 
                end 
            end 
            ]]
        end 
    end
end

    MakeFileList = {}

    function MakeFileList:run(path)
        currentFolder = device.writablePath..path
        local input_table = {} 
        findindir(currentFolder, ".", input_table, true)
        local pthlen = string.len(currentFolder)+2
        local buf = "stage = {\n"
        for i,v in ipairs(input_table) do
            print(i,v)
            local fn = string.sub(v,pthlen)
            buf = buf.."\t{name=\""..fn.."\", code=\""
            local data=readFile(v)
            local ms = crypto.md5(data or "") or ""
            buf = buf..ms.."\", },\n"
        end
        buf = buf.."}"
         io.writefile(device.writablePath.."flist.txt", buf)
    end

    function MakeFileList:convertLF(path)
        currentFolder = device.writablePath..path
        local input_table = {} 
        findindir(currentFolder, "%.cpp", input_table, true)
        for i,v in ipairs(input_table) do
            print(i,v)
            local data=readFile(v)
            local ndata = string.gsub(data, "\013\010", "\013")
             io.writefile(v.."_", ndata)
        end
    end

    return MakeFileList