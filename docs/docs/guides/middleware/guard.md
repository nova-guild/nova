# Guard

A Guard protects a route by running an authorization check before the handler is reached. If the check passes, the request proceeds. If it fails, Nova halts the pipeline and responds immediately.

Guards are the first Attribute to execute in the pipeline:

```bash
Guard → Validator → Interceptor → Route Handler
```

## Defining a Guard Attribute

Apply a Guard to a route handler using the `--@Guard` comment above the function:

```luau
local Home = {}

--@Guard(Auth)
function Home.Get()
    return Nova.response.send("Hello, World")
end

return Home
```

Multiple rules can be passed to a single Guard:

```luau
--@Guard(Auth, Admin)
function Home.Get()
    return Nova.response.send("Hello, World")
end
```

Rules are executed left to right. If any rule fails, the pipeline halts.

## Defining a Guard Rule

Guard Rules live in `src/guards/`. Each file exports a single function that receives the request and returns a `boolean`.

```luau
-- src/guards/Auth.luau
local Nova = require("@nova")

local function Auth(req: Nova.Request)
    return true -- allow the request
end

return Auth
```

If the rule returns `false`, Nova responds with `401 Unauthorized` and the pipeline stops. If it returns `true`, the request moves to the next step.

## Throwing Exceptions

Returning `false` always produces a `401`. If you need a different status code, use `Nova.exception` with Luau's `error()` instead:

```luau
local Nova = require("@nova")
local Exception = Nova.exception

local function Auth(req: Nova.Request)
    error(Exception.Forbidden())
end

return Auth
```

`error()` halts execution immediately and Nova's global error handler catches it, responding with the appropriate status code and message.

You can also pass a custom message:

```luau
error(Exception.Forbidden("You do not have access to this resource"))
```

See the [Exception](/docs/guides/exception) page for all available exceptions.