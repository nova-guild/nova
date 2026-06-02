# Exception

Nova provides a built-in `Exception` module for throwing structured HTTP errors from anywhere in your application — route handlers, Guard rules, Interceptors, or Validators. Exceptions are caught by Nova's global error handler and converted into a proper HTTP response automatically.

## Usage

Luau does not have a `throw` keyword, but `error()` behaves similarly — it halts execution immediately and can be caught by `pcall`. Nova's global error handler uses `pcall` under the hood, so it detects when an Exception is thrown and responds with the appropriate status code and message.

```luau
local Nova = require("@nova")
local Exception = Nova.exception

local function Auth(req: Nova.Request)
    error(Exception.Forbidden())
end

return Auth
```

This reads almost exactly like `throw new ForbiddenException()` in other languages.

## Custom Messages

Every built-in Exception accepts an optional message. If omitted, a default message is used.

```luau
-- Uses default message: "Forbidden"
error(Exception.Forbidden())

-- Uses a custom message
error(Exception.Forbidden("You do not have access to this resource"))
```

## Built-in Exceptions

### 4xx — Client Errors

| Function | Status | Default Message |
|---|---|---|
| `Exception.BadRequest()` | `400` | Bad Request |
| `Exception.Unauthorized()` | `401` | Unauthorized |
| `Exception.Forbidden()` | `403` | Forbidden |
| `Exception.NotFound()` | `404` | Not Found |
| `Exception.Conflict()` | `409` | Conflict |
| `Exception.TooManyRequests()` | `429` | Too Many Requests |

### 5xx — Server Errors

| Function | Status | Default Message |
|---|---|---|
| `Exception.InternalServerError()` | `500` | Internal Server Error |
| `Exception.BadGateway()` | `502` | Bad Gateway |
| `Exception.ServiceUnavailable()` | `503` | Service Unavailable |

## Custom Exceptions

If you need a status code not covered by the built-in functions, use `Exception.HttpException()` directly — it is the base function all others are built on:

```luau
error(Exception.HttpException(418, "I'm a teapot"))
```

The first argument is the status code and the second is the message. Both are required.

## Important Notes

- `error()` halts execution immediately. Nothing after it runs.
- Exceptions are only meaningful when thrown inside Nova's request pipeline. Throwing one outside of a request context will not produce an HTTP response.
- All built-in Exceptions accept an optional custom message. `HttpException` requires one.