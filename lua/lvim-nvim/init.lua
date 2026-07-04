-- lvim-nvim: umbrella entry point for the whole lvim-tech plugin set. This monorepo is the single source of
-- truth; every bundled plugin is ALSO published as its own standalone repo (a generated mirror), so a user can
-- install the whole set OR just one plugin — the `lua/` paths are identical either way. `setup()` is a thin
-- orchestrator: it forwards each per-plugin option table to that plugin's own `setup()`, in a dependency-safe
-- order, so the whole set is configured from one place. Every plugin also keeps its own
-- `require("<plugin>").setup()` for standalone use.
--
---@module "lvim-nvim"

local M = {}

---@class lvim-nvim.Config
--- Per-plugin option tables — each is forwarded verbatim to that plugin's own `setup()`.
---@field utils?     table         base (lvim-utils): cursor / palette / highlights / store
---@field ui?        table         the float toolkit (lvim-ui) — usually needs no options
---@field picker?    table|false   the fuzzy finders (lvim-picker) — false = don't set up
---@field hud?       table|false   editor periphery (lvim-hud): chrome / cmdline / notify / input — false = off
---@field msgarea?   table         the bottom message zone (lvim-msgarea)
---@field image?     table|false   terminal-graphics images (lvim-image) — false = off
---@field dashboard? table         the start dashboard (lvim-dashboard)
---@field common?    table         small extras (lvim-common): colorcolumn / gx

--- Safely require + setup one plugin. Missing plugin (not installed) is skipped with a warning rather than
--- a hard error, so a partial install still boots.
---@param name string     the plugin module name (e.g. "lvim-hud")
---@param opts table|nil   its option table (nil = defaults)
local function activate(name, opts)
    local ok, plugin = pcall(require, name)
    if not ok then
        vim.schedule(function()
            vim.notify("lvim-nvim: " .. name .. " is not installed — skipped", vim.log.levels.WARN)
        end)
        return
    end
    if type(plugin.setup) == "function" then
        plugin.setup(opts)
    end
end

--- Configure the lvim-tech set from one place. Each `opts.<plugin>` is forwarded to that plugin's `setup()`.
--- The order is dependency-safe:
---   1. lvim-utils  — the base (cursor / palette / highlights); everything reads its palette.
---   2. lvim-common — colorcolumn / gx (independent).
---   3. lvim-hud    — chrome / cmdline / notify / input (notify is the message router the zone binds to).
---   4. lvim-msgarea— the bottom zone; registers its host/sink seams with lvim-hud's cmdline + notify, so it
---                    MUST run after lvim-hud.
---   5. lvim-picker — the finders (also the msgarea navigator).
---   6. lvim-ui / lvim-image / lvim-dashboard — the remaining feature surfaces.
--- A key set to `false` opts that plugin out; a nil key uses the plugin's own default (notify + chrome are on
--- by default inside lvim-hud, image inside lvim-image — pass `false` to disable).
---@param opts? lvim-nvim.Config
function M.setup(opts)
    opts = opts or {}

    -- 1. base — eager, tiny; other plugins read its palette immediately after.
    if opts.utils ~= false then
        activate("lvim-utils", opts.utils or {})
    end

    -- 2. common extras (colorcolumn / gx) — only when configured.
    if opts.common then
        activate("lvim-common", opts.common)
    end

    -- 3. editor periphery (statusline / cmdline / notify / input).
    if opts.hud ~= false then
        activate("lvim-hud", opts.hud or {})
    end

    -- 4. the message zone — AFTER lvim-hud (it registers the cmdline host + notify history-sink seams).
    if opts.msgarea then
        activate("lvim-msgarea", opts.msgarea)
    end

    -- 5. the finders (+ the :LvimPicker command).
    if opts.picker ~= false then
        activate("lvim-picker", opts.picker or {})
    end

    -- 6. the float toolkit (only if the user passes options; it works without setup).
    if opts.ui then
        activate("lvim-ui", opts.ui)
    end

    -- 7. terminal-graphics images.
    if opts.image ~= false then
        activate("lvim-image", opts.image or {})
    end

    -- 8. the start dashboard.
    if opts.dashboard then
        activate("lvim-dashboard", opts.dashboard)
    end
end

return M
