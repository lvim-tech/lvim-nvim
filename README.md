# lvim-nvim

The umbrella distribution of the **lvim-tech** Neovim plugin set — one repository that bundles every
lvim-tech plugin, while **each plugin remains installable on its own**.

This repository is the **single source of truth** (a monorepo); every bundled plugin is also published as
its own standalone repository (a generated mirror). Because all plugins share one merged `lua/` tree, the
`require(...)` paths are identical whether you install the whole set or a single plugin — your config does
not change.

> Status: **work in progress** — the monorepo is being assembled.

## Installation

Requires **Neovim >= 0.12.x** — the bundled lvim-installer and lvim-pkg use Neovim's native `vim.pack`.

### lvim-installer (recommended)

Install and manage it from the LVIM package manager — open the **Plugins** tab and install / update / pin it:

```vim
:LvimInstaller plugins
```

lvim-installer installs plugins through Neovim's built-in `vim.pack`, so no external plugin manager is needed.

### Native (vim.pack)

```lua
vim.pack.add({
    { src = "https://github.com/lvim-tech/lvim-nvim" },
})
require("lvim-nvim").setup({})
```

### A single plugin standalone

Install just one plugin and its lvim-tech dependencies — the `require(...)` paths are the same as in the
umbrella. For example `lvim-ui` (which needs `lvim-utils`):

```lua
vim.pack.add({
    { src = "https://github.com/lvim-tech/lvim-utils" },
    { src = "https://github.com/lvim-tech/lvim-ui" },
})
```

## Configure

One entry point configures the set; each `opts.<plugin>` is forwarded to that plugin's own `setup()`:

```lua
require("lvim-nvim").setup({
    utils = {}, -- base: cursor / palette / highlights / store
    common = {}, -- colorcolumn / gx
    hud = {}, -- editor periphery: chrome / cmdline / notify / input (false = off)
    msgarea = {}, -- the bottom message zone
    picker = {}, -- the fuzzy finders (false = off)
    ui = {}, -- the float toolkit (usually needs no options)
    image = {}, -- terminal-graphics images (false = off)
    dashboard = {}, -- the start dashboard
})
```

`setup()` forwards each `opts.<plugin>` to that plugin's own `setup()` in a dependency-safe order (base →
common → hud → msgarea → picker → ui → image → dashboard). A key set to `false` opts that plugin out; a
missing plugin (not installed) is skipped with a warning, so a partial install still boots. Each option table
is exactly what that plugin's standalone `setup()` accepts — see the plugin's own README.

## License

BSD-3-Clause.
