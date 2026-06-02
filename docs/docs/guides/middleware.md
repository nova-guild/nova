# Middleware

Middleware is one of the fundamental features of Nova. It allows you to intercept, inspect, or modify requests before they reach your route handlers, and perform actions after the handler has finished.

Common use cases include:

- **Logging:** Tracking request times and paths.
- **Authentication:** Checking if a user is logged in.
- **Validation:** Ensuring the request body contains the correct data.
- **Security:** Adding headers.

## The Middleware Function

A middleware in Nova is a simple function that receives two arguments:

- `req` — The Request object.
- `next` — A function that, when called, passes control to the next middleware in the stack.

### The Onion Pattern

Nova uses the **Onion Pattern**. This means that when you call `next()`, execution **dives** into the next middleware or the final handler. Once the handler finishes, execution "bubbles" back up, running the code after `next()`.

```luau
local function myMiddleware(req, next)
    print("1. This runs BEFORE the route handler")

    next()

    print("2. This runs AFTER the route handler is finished")
end
```

**Example Flow:**

If you have Global Middleware `A`, Attribute `B`, and Handler `C`:

```bash
A (before next) → B (before next) → C (Handler) → B (after next) → A (after next)
```

## Global Middleware

Global middleware runs on **every single request** made to your server. These are defined when you initialize your Nova application.

`Nova.new()` accepts an optional second argument: a table of middleware functions.

```luau
local Nova = require("path/to/nova")

local app = Nova.new(8080, {
    myMiddleware1 = function(req, next)
        print(`[{req.method}] {req.path}`)
        next()
    end,
    myMiddleware1 = function(req, next)
        next()
    end
})

app:listen(function()
    print("Server running on http://localhost:8080")
end)
```

Global middlewares execute in the order they are defined.

## Route-Specific Middleware (Attributes)

For middleware that should only run on specific routes, Nova uses **Attributes** — a comment-based syntax inspired by how decorators work in other languages.

Attributes are defined directly above a route handler function using the `--@` prefix:

```luau
local Home = {}

--@Guard(Auth)
--@Interceptor(Transform)
function Home.Get()
    return Nova.response.send("Hello, World")
end

return Home
```

Nova ships with three built-in Attributes, each serving a distinct purpose:

| Attribute | Purpose |
|---|---|
| [`--@Guard`](/docs/guides/middleware/guard) | Protect routes — authentication and authorization |
| [`--@Interceptor`](/docs/guides/middleware/interceptor) | Wrap the handler — logging, response transformation |
| [`--@Validator`](/docs/guides/middleware/validator) | Validate incoming data — body, params, and query |

### Execution Order

Attributes always execute in this order, regardless of how they are defined:

```bash
Guard → Validator → Interceptor → Route Handler
```

Nova enforces this order at startup. If your Attributes are defined out of order, Nova will throw an error with a clear message telling you what to fix.

### Convention-Driven Resolution

Each Attribute references a **Rule** by name. Nova resolves Rules by convention from your `src/` directory:

| Attribute | Rule Directory |
|---|---|
| `--@Guard(...)` | `src/guards/` |
| `--@Interceptor(...)` | `src/interceptors/` |
| `--@Validator(...)` | `src/validators/` |

See the dedicated pages for each Attribute to learn how to define Rules.

## Important Notes

- **Always call `next()`** in global middleware. If you do not, the request will never reach the handler unless you are intentionally returning an early response.
- **Global middleware runs first**, before any Attributes on the route.
- **Attributes are route-specific** — they have no effect on routes that do not declare them.