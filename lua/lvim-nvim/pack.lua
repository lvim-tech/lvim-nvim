-- lvim-nvim.pack: the DISTRIBUTION manifest of the lvim-tech set — the single source of truth for WHICH
-- plugins make up the umbrella. Read by lvim-pkg.deps (via the host loader's `deps.bundle` pass) so that
-- installing lvim-nvim pulls the whole set automatically.
--
-- These are INSTALL-only entries: each plugin is registered so the package manager clones it, but it is NOT
-- turned into a load-order dependency of lvim-nvim. So every plugin still LOADS on its own spec / lazy triggers
-- and is CONFIGURED by the user's config (or through `require("lvim-nvim").setup({...})`) — distribution here,
-- configuration there. To add or drop a plugin from the set, edit this list only.
--
---@module "lvim-nvim.pack"

return {
    dependencies = {
        -- base + the split modules
        "lvim-tech/lvim-utils",
        "lvim-tech/lvim-ui",
        "lvim-tech/lvim-picker",
        "lvim-tech/lvim-hud",
        "lvim-tech/lvim-msgarea",
        "lvim-tech/lvim-image",
        "lvim-tech/lvim-dashboard",
        "lvim-tech/lvim-common",
        -- package / LSP / treesitter cores
        "lvim-tech/lvim-ls",
        "lvim-tech/lvim-pkg",
        "lvim-tech/lvim-installer",
        "lvim-tech/lvim-ts",
        -- feature plugins
        "lvim-tech/lvim-lsp",
        "lvim-tech/lvim-space",
        "lvim-tech/lvim-shell",
        "lvim-tech/lvim-control-center",
        "lvim-tech/lvim-colorscheme",
        "lvim-tech/lvim-keys-helper",
        "lvim-tech/lvim-linguistics",
        "lvim-tech/lvim-move",
        "lvim-tech/lvim-qf-loc",
        "lvim-tech/lvim-dependencies",
    },
}
