-- kc.lua

---@param cmd string
---@return boolean
local function hascmd(cmd)
    return vim.fn.executable(cmd)
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

---@param what string
function CocInstall(what)
    if vim.fn.exists("CocInstall") then
        vim.cmd(":CocInstall " .. what)
    end
end

---@param what string
function npm_install(what)
    vim.cmd("!npm install -g " .. what)
end

-------------------------------------------------------------------------------

---@class Lang
local Lang = {}

function Lang.nomad()
    vim.cmd("!pipx install nomad-watch")
end

function Lang.python()
    vim.cmd("!pip install --upgrade pynvim")
    vim.cmd("!pipx install black")
    vim.cmd("!pipx install isort")
    vim.cmd("!pipx install pyflyby")
    vim.cmd("!pipx runpip pyflyby install --upgrade black")
    npm_install("pyright")
    CocInstall("coc-pyright coc-yaml")
end

function Lang.yaml()
    CocInstall("coc-yaml")
end

function Lang.lua()
    CocInstall("coc-lua")
    doifnocmd(
        "stylua",
        function()
            print("Install cargo and then cargo install stylua")
        end
    )
end

function Lang.vim()
    CocInstall("coc-vimlsp")
end

function Lang.groovy()
    CocInstall("coc-groovy")
end

function Lang.c()
    CocInstall("coc-clangd coc-cmake")
end

function Lang.cmake()
    Lang.c()
end

function Lang.cpp()
    Lang.c()
end

function Lang.tex()
    CocInstall("coc-vimtext")
end

function Lang.ruby()
    CocInstall("coc-solargraph")
end

function Lang.markdown()
    npm_install("markdownlint --save-dev")
end

function Lang.perl()
    -- vim.cmd("!cpan Perl::LangugeServer")
    npm_install("perlnavigator-server")
    CocInstall("coc-perl")
end

function Lang.lua()
    npm_install("lua-fmt")
    CocInstall("coc-lua")
end

-------------------------------------------------------------------------------

local kc = {}

function kc.lang(args)
    print(vim.inspect(args))
    local filetype = args and args.fargs[1] or vim.bo.filetype
    assert(filetype ~= nil and filetype ~= "", "filetype = " .. vim.inspect(filetype))
    print("Setuping " .. vim.inspect(filetype))
    local func = Lang[filetype]
    if func == nil then
        print("Configuration for " .. filetype .. " not found")
        return nil
    end
    return func()
end

function kc.setup()
end

return kc
