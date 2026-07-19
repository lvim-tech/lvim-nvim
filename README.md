# lvim-nvim

The umbrella distribution of the **lvim-tech** Neovim plugin set — one repository that bundles every
lvim-tech plugin, while **each plugin remains installable on its own**.

lvim-nvim is a **thin umbrella**: it ships a generic `setup()` forwarder (below) plus a **distribution
manifest** (`lua/lvim-nvim/pack.lua`) listing every lvim-tech plugin's own repository. The set is distributed
as those individual repos — installing lvim-nvim through **lvim-installer / lvim-pkg** reads the manifest and
pulls them all; the `require(...)` paths are identical to installing a plugin standalone, so your config does
not change either way.

> Status: **work in progress**. A single merged-tree mirror (install lvim-nvim alone and get every module in
> one `lua/` tree) is planned but not yet published — until then the whole set arrives via the manifest, as
> described below.

## Installation

Requires **Neovim >= 0.12.x** — the bundled lvim-installer and lvim-pkg use Neovim's native `vim.pack`.

### lvim-installer / lvim-pkg — the whole set (recommended)

Install lvim-nvim from the LVIM package manager — open the **Plugins** tab and install / update / pin it:

```vim
:LvimInstaller plugins
```

lvim-installer / lvim-pkg install through Neovim's built-in `vim.pack` and **expand the distribution manifest
automatically**: `lua/lvim-nvim/pack.lua` lists every lvim-tech repo, and the bundle pass clones them all. No
external plugin manager is needed. This is the path that yields the whole set from a single install.

### Native (vim.pack) — list the repos explicitly

Bare `vim.pack.add` does **not** read `pack.lua` (only lvim-pkg's bundle pass does), so under plain native
`vim.pack` you list the plugin repos you want yourself. lvim-nvim then just provides the `setup()` forwarder:

```lua
vim.pack.add({
    { src = "https://github.com/lvim-tech/lvim-nvim" },
    { src = "https://github.com/lvim-tech/lvim-utils" }, -- base (required by everything)
    { src = "https://github.com/lvim-tech/lvim-ui" },
    { src = "https://github.com/lvim-tech/lvim-picker" },
    -- …add the other lvim-tech repos you want; the full set is listed in lua/lvim-nvim/pack.lua
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
    -- Each key is a plugin MODULE NAME; its value is exactly what that plugin's own setup() accepts.
    ["lvim-utils"] = { cursor = {} }, -- base: cursor / palette / highlights / store
    ["lvim-common"] = { gx = {}, colorcolumn = {} }, -- colorcolumn / gx
    ["lvim-hud"] = { chrome = {}, notify = {}, cmdline = {}, input = {} }, -- editor periphery
    ["lvim-msgarea"] = { enable = true }, -- the bottom message zone
    ["lvim-picker"] = {}, -- the fuzzy finders
    ["lvim-image"] = {}, -- terminal-graphics images
    ["lvim-dashboard"] = { enable = true }, -- the start dashboard
    -- Feature plugins configure through it too (they each still own their setup()):
    ["lvim-lsp"] = {},
    ["lvim-space"] = {},
})
```

`setup()` is a **generic forwarder**: for each `["<plugin>"] = opts` it calls `require("<plugin>").setup(opts)`,
in a dependency-safe order (the base modules first — utils → common → hud → msgarea → picker → ui → image →
dashboard — then every other key). It configures ANY lvim-tech plugin, module or feature; each plugin still
owns its own `setup()`, so **standalone use is identical** — install just one plugin and call its
`require("<plugin>").setup()` directly. A value of `true` (or `{}`) uses the plugin's defaults; `false` or a
missing key skips it; a plugin that is not installed is skipped with a warning, so a partial install still
boots.

## License

BSD-3-Clause.
