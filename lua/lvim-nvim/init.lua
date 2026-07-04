-- lvim-nvim: umbrella entry point for the whole lvim-tech plugin set. This monorepo is the single source of
-- truth; every bundled plugin is ALSO published as its own standalone repo (a generated mirror), so a user can
-- install the whole set OR just one plugin — the `lua/` paths are identical either way.
--
-- Two ways to use it, freely mixed:
--   • WHOLE SET   — install lvim-nvim (it pulls every lvim-tech plugin as a dependency) and configure them
--                   from ONE place: `require("lvim-nvim").setup({ ["lvim-picker"] = {…}, ["lvim-hud"] = {…} })`.
--   • STANDALONE  — install just one plugin and call its own `require("<plugin>").setup(…)`. Identical paths.
--
-- `setup()` is a thin, GENERIC forwarder keyed by the plugin's module name: for each `opts["<plugin>"]` it
-- calls `require("<plugin>").setup(that_table)`, in a dependency-safe order. It configures ANY lvim-tech plugin
-- (the split base modules AND the feature plugins) — each plugin still owns its own `setup()`; this just calls
-- them for you from one table.
--
---@module "lvim-nvim"

local M = {}

-- The dependency-safe order for the plugins that CARE about order (the split base modules): the base palette
-- first; lvim-hud (the message router) before lvim-msgarea (which registers its host/sink seams on hud); the
-- rest after. Any plugin NOT listed here (e.g. the feature plugins) is set up AFTER these, in arbitrary order
-- — their setup depends only on the base / ui / picker, which are already done by then.
---@type string[]
local ORDER = {
    "lvim-utils", -- base: cursor / palette / highlights / store
    "lvim-common", -- colorcolumn / gx
    "lvim-hud", -- editor periphery: chrome / cmdline / notify / input (the message router)
    "lvim-msgarea", -- the bottom message zone — registers seams with lvim-hud; MUST run after it
    "lvim-picker", -- the fuzzy finders
    "lvim-ui", -- the float toolkit
    "lvim-image", -- terminal-graphics images
    "lvim-dashboard", -- the start dashboard
}

--- Configure the lvim-tech set from one table. Each key is a plugin MODULE NAME and its value is that plugin's
--- own `setup()` options:
---   require("lvim-nvim").setup({
---     ["lvim-utils"]  = { cursor = {…} },
---     ["lvim-hud"]    = { chrome = {…}, notify = {…} },
---     ["lvim-picker"] = { … },
---     ["lvim-lsp"]    = { … },   -- feature plugins work too
---   })
--- A value of `true` (or `{}`) sets the plugin up with its defaults; `false` or nil skips it (not set up). A
--- plugin that is not installed is skipped with a warning, so a partial install still boots. The base modules
--- run in a fixed dependency order; every other key runs afterwards.
---@param opts? table<string, table|boolean>
function M.setup(opts)
    opts = opts or {}
    local done = {}

    --- Forward one plugin's options to its `setup()`.
    ---@param name string
    local function activate(name)
        if done[name] then
            return
        end
        done[name] = true
        local o = opts[name]
        if o == nil or o == false then
            return -- not configured / explicitly disabled
        end
        local ok, plugin = pcall(require, name)
        if not ok then
            vim.schedule(function()
                vim.notify("lvim-nvim: " .. name .. " is not installed — skipped", vim.log.levels.WARN)
            end)
            return
        end
        if type(plugin.setup) == "function" then
            plugin.setup(o == true and {} or o)
        end
    end

    -- 1. the ordered base modules.
    for _, name in ipairs(ORDER) do
        activate(name)
    end
    -- 2. every other configured plugin (feature plugins, or any new key), after the base set.
    for name in pairs(opts) do
        activate(name)
    end
end

return M
