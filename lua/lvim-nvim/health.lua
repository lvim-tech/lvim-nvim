-- lvim-nvim.health: `:checkhealth lvim-nvim` — the umbrella's install/config visibility. It reports the
-- Neovim version, whether lvim-pkg (which consumes the distribution manifest) is present, and then for every
-- plugin in pack.lua whether it is INSTALLED (its `lua/<name>/` tree is on the runtimepath) and whether it
-- has been LOADED (`package.loaded`). This is the one place where "which of the set is actually here / booted"
-- is visible — otherwise a partial install or a forwarder key that failed to load only shows as a transient
-- setup warning that scrolls away.
--
---@module "lvim-nvim.health"

local pack = require("lvim-nvim.pack")

local M = {}

--- The plugin MODULE name from a manifest entry ("lvim-tech/lvim-picker" → "lvim-picker").
---@param dep string
---@return string
local function modname(dep)
    return dep:match("([^/]+)$") or dep
end

--- Whether a plugin is on the runtimepath (its `lua/<name>/init.lua` or `lua/<name>.lua` resolves).
---@param name string
---@return boolean
local function installed(name)
    return #vim.api.nvim_get_runtime_file("lua/" .. name .. "/init.lua", false) > 0
        or #vim.api.nvim_get_runtime_file("lua/" .. name .. ".lua", false) > 0
end

--- Run the health checks.
function M.check()
    local h = vim.health
    h.start("lvim-nvim")

    if vim.fn.has("nvim-0.12") == 1 then
        h.ok("Neovim >= 0.12")
    else
        h.warn("Neovim < 0.12 — some lvim-tech plugins target 0.12+")
    end

    -- lvim-pkg drives the bundle pass that CONSUMES pack.lua; without it the manifest is never expanded and the
    -- set has to be installed another way (individually, or via lvim-installer).
    if installed("lvim-pkg") then
        h.ok("lvim-pkg present — its bundle pass expands pack.lua (whole-set install)")
    else
        h.info(
            "lvim-pkg not found — pack.lua is not auto-expanded; install plugins individually / via lvim-installer"
        )
    end

    local total = #pack.dependencies
    local n_installed, n_loaded, missing = 0, 0, {}
    for _, dep in ipairs(pack.dependencies) do
        local name = modname(dep)
        if installed(name) then
            n_installed = n_installed + 1
            if package.loaded[name] then
                n_loaded = n_loaded + 1
            end
        else
            missing[#missing + 1] = name
        end
    end

    h.info(("distribution manifest: %d plugins — %d installed, %d loaded"):format(total, n_installed, n_loaded))
    if #missing == 0 then
        h.ok("every manifest plugin is installed")
    else
        h.warn(("%d manifest plugin(s) NOT installed: %s"):format(#missing, table.concat(missing, ", ")))
    end
end

return M
