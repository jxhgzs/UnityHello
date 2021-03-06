function clone(object)
    local lookup_table = { }
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = { }
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end 

-- class.lua
-- Compatible with Lua 5.1 (not 5.0).
function class(base)
    local c = { }
    if type(base) == 'table' then
        -- our new class is a shallow copy of the base class!
        for i, v in pairs(base) do
            c[i] = v
        end
        c._base = base
    end
    -- the class will be the metatable for all its objects,
    -- and they will look up their methods in it.
    c.__index = c

    -- expose a constructor which can be called by <classname>(<args>)
    local mt = { }
    mt.__call = function(class_tbl, ...)
        local obj = { }
        setmetatable(obj, c)
        if class_tbl.init then
            class_tbl.init(obj, ...)
        else
            -- make sure that any stuff from the base class is initialized!
            if base and base.init then
                base.init(obj, ...)
            end
        end
        return obj
    end
    c.is_a = function(self, klass)
        local m = getmetatable(self)
        while m do
            if m == klass then return true end
            m = m._base
        end
        return false
    end
    setmetatable(c, mt)
    return c
end

-- A = class()
-- function A:init(x)
--     self.x = x
-- end
-- function A:test()
--     print(self.x)
-- end

-- B = class(A)
-- function B:init(x, y)
--     A.init(self, x)
--     self.y = y
-- end

-- b = B(1, 2)
-- b:test()

-- print(b:is_a(A))