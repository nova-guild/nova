local fs = require("@adpt/fs")
local process = require("@adpt/process")

local cwd = process.cwd
local registry: { [string]: { [string]: (req: any, ...any) -> any } } = {}

local DECORATOR_DIRS = {
	"guards",
	"validators",
	"interceptors"
}

--[[
    Load a registry for all the attribute rules from the given mainDir.

    @param mainDir **:** `string` The path of the main directory.
    @return `void`
]]
local function loadRegistry(mainDir: string)
	for _, dirName in DECORATOR_DIRS do
		local resolvedPath = mainDir:gsub("@c/", cwd .. "/") .. "/../" .. dirName

		if not fs.isDir(resolvedPath) then
			continue
		end

		local items = fs.readDir(resolvedPath)
		local namespace = dirName:sub(1, 1):upper() .. dirName:sub(2, -2)
		registry[namespace] = {}

		for _, item in items do
			local name = item:match("^(.+)%.luau$")

			if name then
				local modulePath = mainDir .. "/../" .. dirName .. "/" .. name
				local ok, result = pcall(require, modulePath)

				if ok and type(result) == "function" or type(result) == "table" then
					registry[namespace][name] = result
				-- else
				-- 	print(`[Nova] Failed to load {namespace} '{name}': {tostring(result)}`)
				end
			end
		end
	end
end

return {
	loadRegistry = loadRegistry,
	registry = registry,
}
