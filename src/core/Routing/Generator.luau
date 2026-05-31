local fs = require("@adpt/fs")
local process = require("@adpt/process")
local registerRoute = require("./RegisterRoute")
local AttributeResolver = require("../Attribute/Resolver")
local Attributes = require("../Attribute")
local Chain = require("../../utils/Chain")
local RouteHelper = require("./Helpers")
local RouteLogger = require("@utils/Logger")

local METHOD_NAMES = RouteHelper.METHOD_MAP
local readDir = fs.readDir
local metadata = fs.metadata
local cwd = process.cwd

local function buildAttributeMiddlewares(decoratorStrings: { string }): ({ any }, { [string]: { string } })
    local middlewares = {}
    local grouped: { [string]: { string } } = {}

    for _, raw in decoratorStrings do
        local parsedDecor = AttributeResolver.parseAttribute(raw)

        if parsedDecor then
            local factory = Attributes[parsedDecor.name]

            if factory then
                table.insert(middlewares, factory(parsedDecor.args))

                if not grouped[parsedDecor.name] then
                    grouped[parsedDecor.name] = {}
                end
                for _, arg in parsedDecor.args do
                    table.insert(grouped[parsedDecor.name], arg)
                end
            end
        end
    end

    return middlewares, grouped
end

local function applyAttributes(routeModule: any, extractedDecorators: { [string]: { string } }, routeKey: string)
    for _, method in METHOD_NAMES do
        local handler = routeModule[method]
        if typeof(handler) ~= "function" then
            continue
        end

        local decoratorStrings: { string }? = nil
        for fnName, decs in extractedDecorators do
            local tail = fnName:match("[:.]([%w_]+)$") or fnName
            if tail == method then
                decoratorStrings = decs
                break
            end
        end

        local grouped: { [string]: { string } } = {}

        if decoratorStrings and #decoratorStrings > 0 then
            local middlewares, resolvedGrouped = buildAttributeMiddlewares(decoratorStrings)
            grouped = resolvedGrouped

            if #middlewares > 0 then
                routeModule[method] = Chain(middlewares, handler)
            end
        end

        RouteLogger.collect(routeKey, method, grouped)
    end
end

local function generateRoute(currentDir: string, currentRoute: string)
    local resolvedDir = currentDir:gsub("@c/", cwd .. "/")
    local items = readDir(resolvedDir)

    for _, item in ipairs(items) do
        local path = currentDir .. "/" .. item
        local resolvedPath = path:gsub("@c/", cwd .. "/")

        if item == "route.luau" then
            local source = fs.readFile(resolvedPath)
            local extractedAttributes = AttributeResolver.extractAttribute(source)

            local modulePath = currentDir .. "/route"
            
            local routeKey = currentRoute == "" and "/" or currentRoute
            
            local routeModule = require(modulePath) :: any

            applyAttributes(routeModule, extractedAttributes, routeKey)

            registerRoute(routeKey, routeModule)
            
            -- print(`\27[32mRegistered Route: {routeKey}\27[0m`)

        elseif metadata(resolvedPath).kind == "dir" or metadata(resolvedPath).kind == "directory" then
            local nextRoute = currentRoute .. "/" .. item
            generateRoute(path, nextRoute)
        end
    end
end

return generateRoute
