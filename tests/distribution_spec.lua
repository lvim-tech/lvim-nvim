-- The distribution list, reconciled against the tree, and the forwarder that reads it.
--
-- pack.lua states its own inclusion rule so that an audit can be mechanical: "every lvim-tech
-- plugin that exists in the source tree AND has a PUBLISHED, non-empty repo … lvim-nvim itself is
-- excluded". Running that reconciliation is the point of this file: a plugin that joins the tree
-- and never reaches the manifest is a plugin nobody installing the umbrella gets, and nothing
-- about the code would say so.
--
-- The list it is reconciled against is the SIBLING CHECKOUTS beside this one, so the case skips
-- rather than lies when they are not there.

local manifest = require("lvim-nvim.pack")
local nvim = require("lvim-nvim")

--- The plugin NAMES the manifest distributes, and any repo listed twice.
---@return table<string, boolean> names
---@return string[] duplicates
local function listed()
    local names, duplicates = {}, {}
    for _, repo in ipairs(manifest.dependencies) do
        local name = repo:match("([^/]+)$")
        if names[name] then
            duplicates[#duplicates + 1] = name
        end
        names[name] = true
    end
    return names, duplicates
end

--- The `lvim-*` directories beside this checkout, or nil when there are none to compare with.
---@return table<string, boolean>|nil
local function siblings()
    local root = vim.fn.fnamemodify(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h"), ":h")
    local out, n = {}, 0
    for name, kind in vim.fs.dir(root) do
        if kind == "directory" and name:match("^lvim%-") then
            out[name] = true
            n = n + 1
        end
    end
    return n > 1 and out or nil
end

-- Plugins present in the tree and deliberately NOT distributed. Pinning them here is what makes
-- the reconciliation useful: a NEW plugin that goes unlisted fails the case below, while these two
-- stay a decision somebody made rather than a drift nobody noticed.
--
--   lvim-gtk   — the standing audit rule excludes it (it is not a Neovim plugin).
--   lvim-pack  — the loader that READS this manifest; it has to be installed before it can bundle
--                anything, so listing it would be circular.
local NOT_DISTRIBUTED = {
    ["lvim-gtk"] = true,
    ["lvim-pack"] = true,
}

describe("lvim-nvim: the distribution manifest")

it("there is a manifest, and it is a list of repos", function()
    truthy(type(manifest.dependencies) == "table" and #manifest.dependencies > 40, "the whole set")
    for i, repo in ipairs(manifest.dependencies) do
        truthy(type(repo) == "string", "entry " .. i .. " is not a repo")
        truthy(repo:match("^lvim%-tech/lvim%-[%w%-]+$"), repo .. " is not an lvim-tech repo")
    end
end)

it("nothing is listed twice", function()
    local _, duplicates = listed()
    eq({}, duplicates, "a repo listed twice would be cloned twice")
end)

it("the umbrella does not distribute itself", function()
    eq(nil, (listed())["lvim-nvim"], "the umbrella cannot depend on itself")
end)

it("every distributed plugin exists in the tree", function()
    local tree = siblings()
    if not tree then
        skip("reconciling the manifest with the tree", "the sibling checkouts are not beside this one")
        return
    end
    for name in pairs((listed())) do
        truthy(tree[name], name .. " is distributed but is not in the source tree -- the bundle would clone it")
    end
end)

it("every plugin in the tree is distributed, or explicitly not", function()
    local tree = siblings()
    if not tree then
        skip("reconciling the manifest with the tree", "the sibling checkouts are not beside this one")
        return
    end
    local names = listed()
    local unlisted = {}
    for name in pairs(tree) do
        if name ~= "lvim-nvim" and not names[name] and not NOT_DISTRIBUTED[name] then
            unlisted[#unlisted + 1] = name
        end
    end
    table.sort(unlisted)
    eq(
        {},
        unlisted,
        "in the tree and not in the manifest: nobody installing the umbrella gets these. "
            .. "Add them to pack.lua, or to NOT_DISTRIBUTED in this spec with the reason"
    )
end)

it("the setup ORDER only names plugins the manifest distributes", function()
    -- A base module that is ordered but not distributed would be configured and never installed.
    local names = listed()
    local order = { "lvim-utils", "lvim-common", "lvim-hud", "lvim-msgarea", "lvim-picker", "lvim-ui" }
    for _, name in ipairs(order) do
        truthy(names[name], name .. " is set up in a fixed order but is not distributed")
    end
end)

describe("lvim-nvim: forwarding options to each plugin's own setup")

--- Run `nvim.setup(opts)` with a stubbed module registry, and report what each stub was handed.
---@param opts table
---@param stubs table<string, table|false>  module name → the module to pretend is installed (false = absent)
---@return table<string, any>  module name → the options its setup() received
local function forwarded(opts, stubs)
    local got = {}
    local saved = {}
    for name, stub in pairs(stubs) do
        saved[name] = package.loaded[name]
        if stub == false then
            package.loaded[name] = nil
        else
            package.loaded[name] = stub(got, name)
        end
    end

    local notified = vim.notify
    vim.notify = function() end
    local ok, err = pcall(nvim.setup, opts)
    vim.notify = notified

    for name in pairs(stubs) do
        package.loaded[name] = saved[name]
    end
    truthy(ok, tostring(err))
    return got
end

--- A stub module whose setup() records what it was given.
---@return fun(got: table, name: string): table
local function recorder()
    return function(got, name)
        return {
            setup = function(o)
                got[name] = o
            end,
        }
    end
end

it("a table of options reaches that plugin's setup", function()
    local got = forwarded({ ["lvim-spec-a"] = { x = 1 } }, { ["lvim-spec-a"] = recorder() })
    eq({ x = 1 }, got["lvim-spec-a"])
end)

it("true means defaults", function()
    local got = forwarded({ ["lvim-spec-a"] = true }, { ["lvim-spec-a"] = recorder() })
    eq({}, got["lvim-spec-a"], "a plugin asked for with no options is set up with its own")
end)

it("false and nil mean leave it alone", function()
    local got = forwarded(
        { ["lvim-spec-a"] = false, ["lvim-spec-b"] = nil },
        { ["lvim-spec-a"] = recorder(), ["lvim-spec-b"] = recorder() }
    )
    eq(nil, got["lvim-spec-a"], "explicitly disabled")
    eq(nil, got["lvim-spec-b"], "never mentioned")
end)

it("a plugin that is not installed is skipped, and the rest still boot", function()
    local got = forwarded({
        ["lvim-spec-missing-xyz"] = { x = 1 },
        ["lvim-spec-a"] = { y = 2 },
    }, { ["lvim-spec-a"] = recorder() })
    eq({ y = 2 }, got["lvim-spec-a"], "a partial install must still configure what IS there")
end)

it("a module without a setup() is skipped rather than called", function()
    local got = forwarded({ ["lvim-spec-nosetup"] = { x = 1 } }, {
        ["lvim-spec-nosetup"] = function()
            return { not_setup = true }
        end,
    })
    eq(nil, got["lvim-spec-nosetup"])
end)

it("the base modules are set up before the feature plugins", function()
    local order = {}
    local stubs = {}
    local function tracker(name)
        return function(_, _)
            return {
                setup = function()
                    order[#order + 1] = name
                end,
            }
        end
    end
    for _, name in ipairs({ "lvim-utils", "lvim-hud", "lvim-msgarea" }) do
        stubs[name] = tracker(name)
    end
    stubs["lvim-spec-feature"] = tracker("lvim-spec-feature")

    forwarded({
        ["lvim-spec-feature"] = true,
        ["lvim-msgarea"] = true,
        ["lvim-hud"] = true,
        ["lvim-utils"] = true,
    }, stubs)

    local pos = {}
    for i, name in ipairs(order) do
        pos[name] = i
    end
    truthy(pos["lvim-utils"] < pos["lvim-hud"], "the palette comes first: " .. vim.inspect(order))
    truthy(
        pos["lvim-hud"] < pos["lvim-msgarea"],
        "the zone registers its seams ON hud, so hud has to be up first: " .. vim.inspect(order)
    )
    truthy(pos["lvim-utils"] < pos["lvim-spec-feature"], "a feature plugin comes after the base set")
end)

it("each plugin is set up once, even when it is both ordered and a key", function()
    local calls = 0
    forwarded({ ["lvim-utils"] = { a = 1 } }, {
        ["lvim-utils"] = function()
            return {
                setup = function()
                    calls = calls + 1
                end,
            }
        end,
    })
    eq(1, calls, "the ordered pass and the general pass must not both run it")
end)
