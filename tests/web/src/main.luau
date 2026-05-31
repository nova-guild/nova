local Nova = require("@nova")
local process = require("@adpt/process")

local PORT = tonumber(process.env.PORT) or 8080
local app = Nova.new(PORT, {
    Test1 = function(_req, next)
        next()
    end,
    Test2 = function(_req, next)
        next()
    end
})

app:listen(function()
	print(`Nova is running on Port {PORT}`)
end)
