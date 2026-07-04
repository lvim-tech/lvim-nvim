-- lvim-nvim: umbrella entry point for the whole lvim-tech plugin set. This monorepo is the single source of
-- truth; every bundled plugin is ALSO published as its own standalone repo (a generated mirror), so a user can
-- install the whole set OR just one plugin — the `lua/` paths are identical either way. `setup()` is a thin
-- LAZY orchestrator: it splits the per-plugin option tables and activates each plugin on its real trigger, so
-- nothing heavy loads at startup. Every plugin also keeps its own `require("<plugin>").setup()`.
--
---@module "lvim-nvim"

local M = {}

---@class lvim-nvim.Config
--- Per-plugin option tables — each is forwarded verbatim to that plugin's own `setup()`. Fields are added as
--- plugins are imported into the monorepo (see .claude/lvim-split-plan.md for the full inventory).
---@field utils? table
---@field ui? table
---@field picker? table
---@field hud? table
---@field image? table|false
---@field dashboard? table
---@field common? table

--- Configure the lvim-tech set from one place. A thin lazy orchestrator: forwards each `opts.<plugin>` to that
--- plugin's `setup()` — the base (lvim-utils) eagerly, the rest on their real trigger (command / FileType /
--- keymap / event) so startup stays cheap. SKELETON — filled in as the monorepo is populated.
---@param opts? lvim-nvim.Config
function M.setup(opts)
    opts = opts or {}
    -- TODO(migration): forward opts.<plugin> → require("<plugin>").setup(); base eager, the rest lazy.
end

return M
