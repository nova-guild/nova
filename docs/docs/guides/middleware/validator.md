# Validator

A Validator checks the incoming request data before it reaches the route handler. If any field fails validation, Nova responds immediately with a list of all errors. If everything passes, the request proceeds.

Validators run after Guards and before Interceptors:

```bash
Guard → Validator → Interceptor → Route Handler
```

## Defining a Validator Attribute

Apply a Validator to a route handler using the `--@Validator` comment above the function:

```luau
local Home = {}

--@Validator(CreateUser)
function Home.Post()
    return Nova.response.json({ message = "User created" })
end

return Home
```

## Defining a Validator Rule

Validator Rules live in `src/validators/`. Each file exports a table with up to three optional keys: `body`, `param`, and `query`. You only need to define the ones you want to validate.

```luau
-- src/validators/CreateUser.luau
return {
    body = {
        username = { type = "string", required = true, min = 3, max = 20 },
        email    = { type = "string", required = true, pattern = "^[%w.]+@[%w]+%.[%a]+$" },
        age      = { type = "number", required = true, min = 13 },
    },
    query = {
        ref = { required = false },
    },
}
```

## Validation Fields

Each field key maps to a rule definition with the following options:

| Field | Type | Description |
|---|---|---|
| `type` | `string?` | Expected type — `"string"`, `"number"`, etc. Not applicable to `param` and `query` since they are always strings |
| `required` | `boolean?` | Whether the field must be present |
| `min` | `number?` | Minimum length (strings) or minimum value (numbers) |
| `max` | `number?` | Maximum length (strings) or maximum value (numbers) |
| `pattern` | `string?` | Lua pattern the value must match — commonly used for email format validation |

## Validation Targets

A Validator Rule can validate three parts of the request:

- **`body`** — The request body. Supports all fields including `type`.
- **`param`** — Route parameters (e.g. `/users/[id]`). `type` is omitted since params are always strings.
- **`query`** — Query string values (e.g. `?page=1`). Same as `param` — `type` is omitted.

## Error Response

Nova validates **all fields** before responding. If multiple fields fail, the response includes every error at once rather than stopping at the first:

```json
{
    "errors": [
        "username is required",
        "email does not match the expected pattern"
    ]
}
```