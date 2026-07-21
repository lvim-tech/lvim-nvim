-- lvim-nvim.pack: the DISTRIBUTION manifest of the lvim-tech set — the single source of truth for WHICH
-- plugins make up the umbrella. Read by lvim-pkg.deps (via the host loader's `deps.bundle` pass) so that
-- installing lvim-nvim pulls the whole set automatically.
--
-- These are INSTALL-only entries: each plugin is registered so the package manager clones it, but it is NOT
-- turned into a load-order dependency of lvim-nvim. So every plugin still LOADS on its own spec / lazy triggers
-- and is CONFIGURED by the user's config (or through `require("lvim-nvim").setup({...})`) — distribution here,
-- configuration there. To add or drop a plugin from the set, edit this list only.
--
-- INCLUSION RULE (so the next audit can reconcile mechanically): every lvim-tech plugin that exists in the
-- source tree AND has a PUBLISHED, non-empty repo under github.com/lvim-tech (the bundle pass clones each, so
-- an unpushed / empty repo must NOT be listed). Regenerate by intersecting the tree's `lvim-*` dirs with
-- `gh repo list lvim-tech`. lvim-nvim itself is excluded (the umbrella does not depend on itself).
--
---@module "lvim-nvim.pack"

return {
    dependencies = {
        -- base + the split UI modules (these also have a fixed setup ORDER in init.lua)
        "lvim-tech/lvim-utils",
        "lvim-tech/lvim-ui",
        "lvim-tech/lvim-common",
        "lvim-tech/lvim-hud",
        "lvim-tech/lvim-msgarea",
        "lvim-tech/lvim-picker",
        "lvim-tech/lvim-fuzzy",
        "lvim-tech/lvim-icons",
        "lvim-tech/lvim-image",
        "lvim-tech/lvim-dashboard",
        -- package / LSP / treesitter / DAP cores
        "lvim-tech/lvim-pkg",
        "lvim-tech/lvim-installer",
        "lvim-tech/lvim-ls",
        "lvim-tech/lvim-lsp",
        "lvim-tech/lvim-ts",
        "lvim-tech/lvim-dap",
        "lvim-tech/lvim-dap-view",
        -- feature plugins (alphabetical)
        "lvim-tech/lvim-breadcrumbs",
        "lvim-tech/lvim-buf-history",
        "lvim-tech/lvim-build",
        "lvim-tech/lvim-calendar",
        "lvim-tech/lvim-cmp",
        "lvim-tech/lvim-color-picker",
        "lvim-tech/lvim-colorscheme",
        "lvim-tech/lvim-comment",
        "lvim-tech/lvim-context",
        "lvim-tech/lvim-control-center",
        "lvim-tech/lvim-cycle",
        "lvim-tech/lvim-db",
        "lvim-tech/lvim-dependencies",
        "lvim-tech/lvim-files",
        "lvim-tech/lvim-forge",
        "lvim-tech/lvim-git",
        "lvim-tech/lvim-indent",
        "lvim-tech/lvim-jump",
        "lvim-tech/lvim-keyring",
        "lvim-tech/lvim-keys-helper",
        "lvim-tech/lvim-lang",
        "lvim-tech/lvim-linguistics",
        "lvim-tech/lvim-move",
        "lvim-tech/lvim-pairs",
        "lvim-tech/lvim-qf-loc",
        "lvim-tech/lvim-remote",
        "lvim-tech/lvim-replace",
        "lvim-tech/lvim-shell",
        "lvim-tech/lvim-snippets",
        "lvim-tech/lvim-space",
        "lvim-tech/lvim-table",
        "lvim-tech/lvim-tasks",
        "lvim-tech/lvim-term",
        "lvim-tech/lvim-undo",
        "lvim-tech/lvim-vault",
        "lvim-tech/lvim-winmove",
        "lvim-tech/lvim-winnav",
        "lvim-tech/lvim-winpick",
    },
}
