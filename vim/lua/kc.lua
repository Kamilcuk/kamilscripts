-- kc.lua
-- local vim = require('vim')

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

local function lcmd(what)
	print(what)
	vim.cmd(what)
end

local function execute(what)
	print("!" .. what)
	os.execute(what)
end

---@param what string
function CocInstall(what)
	if vim.fn.exists(":CocInstall") then
		lcmd(":CocInstall " .. what)
	end
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
	vim.cmd("!pipx install nomad-watch")
end

function Lang.python()
	TSInstall("python")
	parallelcmd({
		"pip install --upgrade pynvim",
		"pipx install --force black",
		"pipx install --force isort",
		"pipx install --force pyflyby && pipx runpip pyflyby install --upgrade black",
		"pipx install --force autoimport",
		"pipx install --force pylava && pipx runpip pylava install pyflakes==2.4.0",
		"npm install -g pyright",
	})
	CocInstall("coc-pyright coc-yaml")
end

function Lang.yaml()
	CocInstall("coc-yaml")
end

function Lang.lua()
	TSInstall("lua")
	npm_install("lua-fmt")
	doifnocmd("stylua", function()
		print("Install cargo and then cargo install stylua")
	end)
	CocInstall("coc-lua")
end

function Lang.vim()
	CocInstall("coc-vimlsp")
	TSInstall("vim")
end

function Lang.groovy()
	CocInstall("coc-groovy")
	TSInstall("groovy")
end

function Lang.c()
	CocInstall("coc-clangd coc-cmake")
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
	CocInstall("coc-vimtext")
	TSInstall("tex")
end

function Lang.ruby()
	CocInstall("coc-solargraph")
	TSInstall("ruby")
end

function Lang.markdown()
	npm_install("markdownlint --save-dev")
	TSInstall("markdown")
end

function Lang.perl()
	-- vim.cmd("!cpan Perl::LangugeServer")
	npm_install("perlnavigator-server")
	CocInstall("coc-perl")
	TSInstall("perl")
end

-------------------------------------------------------------------------------

local kc = {}

function kc.lang(arg)
	print(vim.inspect(arg))
	local filetype = arg and arg or vim.bo.filetype
	assert(filetype ~= nil and filetype ~= "", "filetype = " .. vim.inspect(filetype))
	print("Setuping " .. vim.inspect(filetype))
	local func = Lang[filetype]
	if func == nil then
		print("Configuration for " .. filetype .. " not found")
		return nil
	end
	return func()
end

function kc.setup() end

return kc
