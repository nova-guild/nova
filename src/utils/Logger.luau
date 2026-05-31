--[[
    This will be the template for what the logger supposed to output:
    

    (Startup Message)

    Middleware:  Logger · cors · rateLimiter

    Routes:
    GET     /                Guard(AuthRule, AdminRule) · Interceptor(TransformRule)
    POST    /                Guard(AuthRule)
    GET     /users           Guard(AuthRule) · Validator(UserBody)
    GET     /users/:id       Guard(AuthRule)
    PUT     /users/:id       Guard(AuthRule) · Interceptor(Audit)
    DELETE  /users/:id       Guard(AuthRule, AdminRule)

    Ready in 9.3196 ms


    (Runtime Messages)

    GET  /  403  Guard(AuthRule, AdminRule) <-- The word AuthRule and AdminRule would turn into the same color as the status code
    GET  /users/:id  200  Guard(AuthRule) · Interceptor(Transform)
]]

local RouteLogger = {}

type GroupedAttributes = { [string]: { string } }
type RouteEntry = { path: string, method: string, grouped: GroupedAttributes }

local middlewareNames: { string } = {}
local entries: { RouteEntry } = {}

function RouteLogger.setMiddlewares(mws: { (any) -> any })
    for _, mw in mws do
        local name = debug.info(mw, "n") 
        if name and name ~= "" then
            table.insert(middlewareNames, name)
        end
    end
end

function RouteLogger.collect(path: string, method: string, grouped: GroupedAttributes)
    table.insert(entries, {
        path = path,
        method = method:upper(),
        grouped = grouped,
    })
end

local function formatAttributes(grouped: GroupedAttributes): string
    local parts = {}
    for attrName, args in grouped do
        table.insert(parts, string.format("%s(%s)", attrName, table.concat(args, ", ")))
    end
    return table.concat(parts, " · ")
end

function RouteLogger.getAttributes(path: string, method: string): string
    for _, e in entries do
        if e.path == path and e.method == method:upper() then
            return formatAttributes(e.grouped)
        end
    end
    return ""
end

function RouteLogger.flush()
    if #middlewareNames > 0 then
        print("\27[1mMiddleware:  \27[32;1m" .. table.concat(middlewareNames, " · ") .. "\27[0m")
        print("")
    end

    print("\27[1mRegistered Routes:\27[0m")

    table.sort(entries, function(a, b)
        local aHas = next(a.grouped) ~= nil
        local bHas = next(b.grouped) ~= nil
        if aHas ~= bHas then
            return aHas
        end
        return false
    end)

    local methodPad = 0
    local pathPad = 0

    for _, e in entries do
        if #e.method > methodPad then 
            methodPad = #e.method 
        end

        if #e.path > pathPad then 
            pathPad = #e.path 
        end
    end

    for _, e in entries do
        local paddedMethod = e.method .. string.rep(" ", methodPad - #e.method)
        local paddedPath = e.path .. string.rep(" ", pathPad - #e.path)
        local attrSuffix = ""

        if next(e.grouped) then
            attrSuffix = "   " .. formatAttributes(e.grouped)
        end

        print(string.format("\27[32m  [%s]  %s\27[34m%s\27[0m", paddedMethod, paddedPath, attrSuffix))
    end

    print("")
end

return RouteLogger
