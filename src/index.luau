local net = require("@adpt/net")
local fs = require("@adpt/fs")
local serde = require("@adpt/serde")
local process = require("@adpt/process")
local Types = require("./types")
local routeDispatcher = require("@core/Routing/Dispatcher")
local generateRoute = require("@core/Routing/Generator")
local loadEnv = require("@utils/LoadEnv")
local MainDir = require("@utils/MainDir")
local generateAlias = require("@utils/GenerateAlias")
local attrRegistryGenerator = require("@core/Attribute/RegistryGenerator")
local RouteLogger = require("@utils/Logger")

export type Next = Types.Next
export type Nova = Types.Nova
export type Request = Types.Request
export type RequestWith<T> = Types.RequestWith<T>
export type ResponseOptions = Types.ResponseOptions

local serve = net.serve
local isFile = fs.isFile
local readFile = fs.readFile
local encode = serde.encode
local cwd = process.cwd

local Nova = {}
Nova.__index = Nova

Nova.chain = require("@utils/Chain")
Nova.response = require("@utils/Response")

local function devMiddleware(req: Types.Request, next: Types.Next)
    local res = next()
    local status = res.config.status or 200

    local statusColor = "\27[31m"
    if status >= 200 and status < 300 then
        statusColor = "\27[32m"
    elseif status >= 300 and status < 400 then
        statusColor = "\27[34m"
    end

    if req.path ~= "/favicon.ico" then
        local attrs = RouteLogger.getAttributes(req.path, req.method)
        local attrSuffix = attrs ~= "" and ("  " .. statusColor .. attrs .. "\27[0m") or ""
        print(string.format("[%s] %s %s%d\27[0m%s", req.method, req.path, statusColor, status, attrSuffix))
    end
end

function Nova.new(port: number, middlewares: { (req: Types.Request, next: Types.Next) -> () }?)
    local self = setmetatable({}, Nova)
    self.port = port
    self.middlewares = middlewares
    self.dev = table.find(process.args, "dev") ~= nil

    loadEnv()
    generateAlias()

    return self :: Nova
end

function Nova:listen(handler: () -> ())
    local start = os.clock()

    local mainDirName = MainDir
    local mainDir = `@c/{mainDirName}`

    local faviconPath = `{cwd}/{mainDirName}/favicon.ico`
    local isDev = self.dev

    local INTERNAL_ERROR_RESPONSE = {
        status = 500,
        body = encode("json", { error = "Internal Server Error" }),
        headers = { ["Content-Type"] = "application/json" }
    }

    local FAVICON_EMPTY_RESPONSE = { status = 204 }
    local FAVICON_CACHED_RESPONSE: any = nil

    if isFile(faviconPath) then
        FAVICON_CACHED_RESPONSE = {
            status = 200,
            body = readFile(faviconPath),
            headers = {
                ["Content-Type"] = "image/x-icon",
                ["Cache-Control"] = "public, max-age=86400"
            }
        }
    end

    RouteLogger.setMiddlewares(self.middlewares or {})

    attrRegistryGenerator.loadRegistry(mainDir)
    generateRoute(mainDir, "")

    RouteLogger.flush()

    local allMiddlewares = self.middlewares and table.clone(self.middlewares) or {}

    if isDev then
        table.insert(allMiddlewares :: { Types.Middleware }, 1, devMiddleware :: Types.Middleware)
    end

    local rootPipeline = Nova.chain(allMiddlewares :: { Types.Middleware }, routeDispatcher)

    serve(self.port, {
        address = "0.0.0.0",
        handleRequest = function(request)
            if request.path == "/favicon.ico" and request.method == "GET" then
                if isDev and isFile(faviconPath) then
                    return {
                        status = 200,
                        body = readFile(faviconPath),
                        headers = {
                            ["Content-Type"] = "image/x-icon",
                            ["Cache-Control"] = "no-cache"
                        }
                    }
                end
                return FAVICON_CACHED_RESPONSE or FAVICON_EMPTY_RESPONSE :: net.NetResponse
            end

            local success, result: Types.ResponsePayload | any = pcall(rootPipeline, request)

            if not success then
                if isDev then
                    local errorMessage = debug.traceback(tostring(result), 2)
                    print("\27[31m[Error]: " .. errorMessage .. "\27[0m")
                end
                return INTERNAL_ERROR_RESPONSE :: net.NetResponse
            end

            local status: number
            local headers = nil

            if result.config then
                status = result.config.status
                headers = result.config.headers
            end

            return {
                status = status or 200,
                body = result and result.body or nil,
                headers = headers
            }
        end
    })

    local finish = os.clock() - start
    print(string.format("\nReady in %.4f ms\n", finish * 1000))

    if handler then
        handler()
    end
end

return Nova
