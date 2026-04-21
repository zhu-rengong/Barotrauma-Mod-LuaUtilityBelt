local registry = {}

local ignoredKeys = {}
for _, k in ipairs({
    "__add", "__sub", "__mul", "__div", "__mod", "__pow", "__unm", "__idiv",
    "__band", "__bor", "__bxor", "__bnot", "__shl", "__shr",
    "__eq", "__lt", "__le",
    "__index", "__newindex", "__pairs",
    "__concat", "__len", "__call",
    "__metatable", "__tostring",
    "__gc", "__close",
    "__mode",
    "__init", }) do
    ignoredKeys[k] = true
end

---@generic T
---@param obj T
---@return T
local function shallowCopy(obj)
    ---@type { table: table }
    local t_copies = {}

    local function copy(o)
        if type(o) ~= 'table' then return o end
        local t = t_copies[o]
        if t then return t end
        t = {}
        t_copies[o] = t
        for k, v in pairs(o) do
            t[copy(k)] = copy(v)
        end
        return t
    end

    return copy(obj)
end

local function instantiate(class)
    local ref = {}

    local function collectMembers(c)
        local mt = getmetatable(c)

        for _, super in pairs(mt.supers) do
            collectMembers(super)
        end

        for k, v in pairs(c) do
            if not ignoredKeys[k] then
                ref[k] = v
            end
        end
    end

    collectMembers(class)

    return setmetatable(shallowCopy(ref), class)
end

local classIdentifier = {}

---@generic T: string
---@param name `T`
---@param ... string
---@return T
local function declare(name, ...)
    local class = registry[name]
    if class then return class end

    local mt = { className = name, typeIdentifier = classIdentifier }

    mt.supers = {}
    for _, superName in ipairs { ... } do
        local super = registry[superName]
        assert(super ~= nil, ("Class '%s' cannot derive from undefined superclass '%s'!"):format(name, superName))
        mt.supers[superName] = super
    end

    class = setmetatable({}, mt)

    function class.__call(instance, ...)
        if class.__init then
            class.__init(instance, ...)
        end
        return instance
    end

    function mt.__call(_, ...)
        return instantiate(class)(...)
    end

    function mt.__index(_, k)
        for _, super in pairs(mt.supers) do
            local v = super[k]
            if v ~= nil then
                return v
            end
        end
    end

    registry[name] = class

    return class
end

---@generic T: string
---@param name `T`
---@return T
local function new(name)
    local class = registry[name]
    assert(class ~= nil, ("Class '%s' is not defined and cannot be instantiated!"):format(name))
    return instantiate(class)
end

---@param value any?
---@param first? boolean
---@return table?
local function getClassMetatable(value, first)
    if value == nil then
        return
    end

    if first == nil then
        first = true
    end

    if not first then
        if value.typeIdentifier == classIdentifier then
            return value
        end
    end

    local mt = getmetatable(value)
    if mt then
        return getClassMetatable(mt, false)
    end
end

---@param obj table
---@return string?
local function getClassName(obj)
    local mt = getClassMetatable(obj)
    if mt then
        return mt.className
    end
end

---@param obj table
---@param name string
---@return boolean
local function isDerivedFrom(obj, name)
    local mt = getClassMetatable(obj)

    if not mt then
        return false
    end

    if mt.supers[name] then
        return true
    end

    for _, super in pairs(mt.supers) do
        if isDerivedFrom(super, name) then
            return true
        end
    end

    return false
end

local liteoo = {}
liteoo.declare = declare
liteoo.new = new
liteoo.getClassName = getClassName
liteoo.isDerivedFrom = isDerivedFrom

return liteoo
