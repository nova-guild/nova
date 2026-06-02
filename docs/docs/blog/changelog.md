# Changelog

## `v0.6.0` - June 2, 2026

***`Nova.chain()` has been removed from the public API. Route-specific middleware is now handled exclusively through Attributes (`--@Guard`, `--@Interceptor`, `--@Validator`).***

### Added

- Exception handling utility with common HTTP error responses (`Nova.exception`) (#76)
- Request validation via `--@Validator` attribute with support for `body`, `param`, and `query` (#73)
- Interceptor support via `--@Interceptor` attribute using onion architecture (#72)
- Guard attribute now supports multiple rules — `--@Guard(Auth, Admin)` (#72)
- Initial `--@Guard` attribute support with comment-based syntax (#69)

### Changed

- Startup logger now displays registered routes with their applied Attributes (#75)
- Runtime request logs now include status code and applied Attributes, with color-coded output by status class (`2xx` green, `3xx` blue, `4xx`/`5xx` red) (#75)
- Core architecture restructured and modularized; adapters renamed (#71)
- `libs/` renamed to `adapters/` (#69)
- `Nova.chain()` is no longer exposed publicly — route-specific middleware must now be defined using Attributes (#69)

### Fixed

- Correct status property access in `devMiddleware` (#74)

---

**Before**
```luau
Home.Get = Nova.chain({ AuthMiddleware, AdminMiddleware }, function()
    return Nova.response.send("Hello, World")
end)
```

**After**
```luau
--@Guard(AuthRule, AdminRule)
--@Interceptor(TransformRule)
function Home.Get()
    return Nova.response.send("Hello, World")
end
```

## `v0.5.7-test` - May 4, 2026

### Changed

- Update changelog header format in Discord notification

## `v0.5.7` - May 4, 2026

### Changed

- Enhance changelog extraction and Discord notification formatting (#65)

## `v0.5.6` - May 4, 2026

### Changed

- Enhance release workflow to notify Discord and consolidate notification logic (#63)

## `v0.5.5` - May 4, 2026

### Added

- Add Discord release notifier workflow for automated notifications (#61)
- Add development mode with request logging and runtime argument support (#60)
- Add web test suite (#57)

### Changed

- Optimize header normalization (#59)
- **(Docs)** Restructure documentation and add comprehensive Luau guides (#58)
- Simplify routing dispatcher and improve request object consistency (#56)

## `v0.5.4` - April 27, 2026

### Added

- Implement custom test runner and add initial unit tests (#49)
- Add error handling to file and directory checks in LuteFs (#47)
- Add initial CI workflow for testing with Lune, Zune, and Lute (#50)
- Streamline function calls and improve code readability across multiple modules (#51)

### Changed

- Improve release workflow and fix documentation (#46)
- Convert matchRoute to iterative with targeted recursive fallback (#48)

## `v0.5.2` - April 24, 2026

### Changed

- Improve loadEnv function to handle multiple environment files
- Streamline runtime check and enhance file system operations
- Update project name and version in pesde.toml
  
### Removed

- Temporarily remove obsolete CI configuration and related files

## `v0.5.1` - April 19, 2026

### Added

- **GitHub Actions for Release Note:** Implemented GitHub Actions workflow for release automation.

### Changed

- Update `CHANGELOG` and `README` for Lute support

## `v0.5.0` - April 19, 2026

***Nova now runs on Lune, Zune and Lute through a runtime adapter layer.***

### Added

- **Lute Runtime Support:** Added `fs`, `net`, `process`, `serde`, and `task` adapters, bringing full Lute runtime support to Nova.

## `v0.4.0` - April 14, 2026

***Nova now runs on both Lune and Zune through a runtime adapter layer.***

### Added

- **Runtime Abstraction Layer**: Introduced an adapter pattern for core libraries (`fs`, `net`, `process`, `serde`, and `task`), decoupling the framework from specific runtime implementations.
- **Zune Runtime Support**: Added full support for the Zune runtime.

### Changed

- **Runtime-Agnostic Utilities**: Refactored internal utility functions to utilize the new abstraction layer, removing direct dependencies on `@lune` built-ins.
- **Enhanced CI Pipeline**: Updated GitHub Actions to install Zune and execute the test suite across both Lune and Zune runtimes to ensure cross-runtime compatibility.

## `v0.3.5` - March 29, 2026

### Changed

* Refactor middleware and remove unnecessary optimizations

## `v0.3.4` - March 25, 2026

### Added
- **Catch-All Routing (`[...slug]`)**: Introduced Next.js-inspired terminal wildcard routes. Wildcards instantly absorb all remaining URL segments in $O(1)$ time, providing extremely fast dynamic deep-routing.
- **URL-Encoded Body Parsing**: The request dispatcher now supports `application/x-www-form-urlencoded` payloads out of the box, automatically parsing them into the `request.body` table.

### Changed
- **Zero-Allocation Route Parsing**: Completely rewrote the internal path parser. Replaced expensive regex/pattern matching (`:match`, `:gsub`) with raw C-level byte checking (`string.byte`) for dynamic route registration and trailing slash removal, drastically reducing memory allocations per request.
- **Dynamic Parameter Memory Optimization**: Replaced standard array shifting (`table.insert(list, 1, val)`) with pre-allocated Luau arrays (`table.create`) and linear indexed assignments, massively speeding up dynamic route segment extraction.
- **Dispatcher Refactoring (DRY)**: Consolidated the internal route execution logic. Static and dynamic routes now share a unified, centralized block for `HEAD` method fallbacks, handler validation, and `405 Method Not Allowed` responses.

## `v0.3.2` - March 15, 2026

###  Fixed

Fixed typos on `routing.luau`

## `v0.3.1` - March 14, 2026

### Fixed

Resolved a critical ***EOF while parsing*** crash that occurred during `GET` requests or requests with empty bodies.

## `v0.3.0` - March 14, 2026

This version removes the automatic detection of Content-Type. You must now use the specific response functions (e.g., `.json()`, `.html()`) to ensure your headers are set correctly. This change give developers explicit control over the response stream.

### Added

- **Explicit Response Utilities:** A new suite of methods under Nova.response to handle common web formats with the correct MIME types:
  - `.send(body, config)` - Generic response handler.
  - `.json(table, config)` - Automatically encodes a table to JSON and sets `application/json`.
  - `.html(string, config)` - Sets `text/html` for server-side rendered content.
  - `.css(string, config)` - Sets `text/css` for stylesheet delivery.
  - `.js(string, config)` - Sets `text/javascript` for client-side scripts.

### Changed

- **Response Handling Logic:** Refactored the core engine to move away from automatic type detection. The system no longer attempts to guess the Content-Type based on the Luau type provided to the router, reducing overhead and preventing ambiguity.

### Fixed

- Resolved a critical bug where the server failed to correctly receive or buffer the request body during POST and PUT operations, ensuring payload integrity for data-driven routes.

### Removed

- `isHtml` property from the response configuration table has been removed. This is now handled exclusively by the .html() utility function.

---

### Implementation Example

```lua
function Home.Get(request)
    -- The new way to send a JSON response
    return Nova.response.json({ msg = "Hello World" })
end
```

## `v0.2.1` - March 9, 2026

### Fixed

- Fixed Nova types not appearing on the latest version

## `v0.2.0` - March 9, 2026

### Added

- Automated discovery of `favicon.ico` in the app directory with dev-mode cache-busting.
- Added automatic `HEAD` method fallback to `GET` handlers.

### Changed

- Replaced O(N) linear route matching with a high-performance Radix Tree (Trie) for O(L) dispatching.
- Implemented O(1) static route fast-path alongside dynamic route handling.
- Integrated `--!native` and `--!optimize 2` to all core files.

### Fixed

- Improved middleware chaining robustness and fixed header merging logic.
- Corrected internal typos in the Nova constructor.