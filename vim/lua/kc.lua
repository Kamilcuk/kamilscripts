-- kc.lua
-- local vim = require('vim')

---@generic N
---@generic M
---@param cmd boolean
---@param a N
---@param b M
---@return N | M
local function ternary(cmd, a, b)
    if cmd then
        return a
    else
        return b
    end
end

---@param cmd string
---@return boolean
local function hascmd(cmd)
    return vim.fn.executable(cmd)
end

local function log(what)
    print("kc.lua: " .. what)
end

---@param cmd string
---@param exe fun() -> nil|string
---@return boolean
local function doifnocmd(cmd, exe)
    if not vim.fn.executable("black") then
        if type(exe) == "function" then
            exe()
        elseif type(exe) == "string" then
            print("Executing " .. exe)
            vim.cmd(exe)
        else
            assert(false, "Type(exe)=" .. type(exe))
        end
        return true
    end
    return false
end

local function lcmd(what)
    log(what)
    vim.cmd(what)
end

local function execute(what)
    log("!" .. what)
    os.execute(what)
end

local function CocGetExtensions()
    local extensions = vim.fn.CocAction("extensionStats")
    local ret = {}
    for _, v in ipairs(extensions) do
        ret[v.id] = true
    end
    return ret
end

---@param what string
function CocInstall(what)
    if vim.fn.exists(":CocInstall") then
        if not CocGetExtensions()[what] then
            lcmd(":CocInstall " .. what)
        else
            log("Coc extension already installed: " .. what)
        end
    end
end

local CocInstallTodo = ""

---@param what string
function CocInstallRegister(what)
    CocInstallTodo = CocInstallTodo .. " " .. what
end

function CocInstallFlush()
    local tmp = CocInstallTodo
    CocInstallTodo = {}
    CocInstall(tmp)
end

---@param what string
local function npm_install(what)
    vim.cmd("!npm install -g " .. what)
end

-- Run TSInstall
---@param what string
local function TSInstall(what)
    if vim.fn.exists(":TSInstallSync") and vim.fn.exists(":TSUpdate") then
        if pcall(vim.treesitter.language.inspect, what) then
            lcmd(":TSUpdate " .. what)
        else
            lcmd(":TSInstall " .. what)
        end
    end
end

---@param list string[]
local function parallelcmd(list)
    local cmd = ""
    cmd = ""
    for _, i in ipairs(list) do
        cmd = cmd .. " '" .. i:gsub("^!", ""):gsub("'", "\\'") .. "'"
    end
    vim.cmd("!printf \\%s\\\\n " .. cmd .. " | xargs -P$(nproc) -i bash -xc {}")
end

-------------------------------------------------------------------------------

local Lang = {}

function Lang.nomad()
    vim.cmd("!pipx install nomad-tools")
end

function Lang.python()
    TSInstall("python")
    parallelcmd(
        {
            "pip install --upgrade pynvim",
            "pipx install --force black",
            "pipx install --force isort",
            "pipx install --force pyflyby && pipx runpip pyflyby install --upgrade black",
            "pipx install --force autoimport",
            "pipx install --force pylava && pipx inject pylava pyflakes==2.4.0",
            "npm install -g pyright"
        }
    )
    CocInstallRegister("coc-pyright coc-yaml")
end

function Lang.yaml()
    CocInstallRegister("coc-yaml")
end

function Lang.lua()
    TSInstall("lua")
    npm_install("lua-fmt")
    doifnocmd(
        "stylua",
        function()
            log("Install cargo and then cargo install stylua")
        end
    )
    CocInstallRegister("coc-lua")
end

function Lang.vim()
    CocInstallRegister("coc-vimlsp")
    TSInstall("vim")
end

function Lang.groovy()
    CocInstallRegister("coc-groovy")
    TSInstall("groovy")
end

function Lang.c()
    CocInstallRegister("coc-clangd coc-cmake")
    TSInstall("c")
end

function Lang.cmake()
    Lang.c()
    TSInstall("cmake")
end

function Lang.cpp()
    Lang.c()
    TSInstall("cpp")
end

function Lang.tex()
    -- CocInstallRegister("coc-vimtex")
    -- TSInstall("latex")
end

function Lang.ruby()
    CocInstallRegister("coc-solargraph")
    TSInstall("ruby")
end

function Lang.markdown()
    npm_install("markdownlint --save-dev")
    TSInstall("markdown")
end

function Lang.perl()
    -- vim.cmd("!cpan Perl::LangugeServer")
    npm_install("perlnavigator-server")
    CocInstallRegister("coc-perl")
    TSInstall("perl")
end

function Lang.javascript()
    npm_install("js-beautify")
    CocInstallRegister("coc-tsserver")
    TSInstall("javascript")
end

-------------------------------------------------------------------------------

local kc = {}

function kc.lang(arg)
    log(vim.inspect(arg))
    local filetype = (arg ~= nil and arg ~= "") and arg or vim.bo.filetype
    if filetype == nil or filetype == "" then
        log("Ignoring filetype because empty: " .. vim.inspect(filetype))
        return nil
    end
    log("Setuping for " .. vim.inspect(filetype))
    if filetype:lower() == "all" then
        for name, _ in pairs(Lang) do
            print("Setuping for " .. name)
            Lang[name]()
        end
    else
        local func = Lang[filetype]
        if func == nil then
            log("Configuration for " .. filetype .. " not found")
            return nil
        end
        func()
    end
    CocInstallFlush()
end

function kc.setup()
end

return kc
