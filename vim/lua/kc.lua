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

-------------------------------------------------------------------------------

local Lang = {}

---@param what string
function Lang._CocInstall(what)
    vim.cmd(":CocInstall " .. what)
end

function Lang.nomad()
	doifnocmd("nomad-watch", "!pipx install nomad-watch")
end

function Lang.python()
	Lang._CocInstall("coc-pyright")
	doifnocmd("black", "!pipx install black")
	doifnocmd("isort", "!pipx install isort")
	doifnocmd("pyflyby-diff", "!pipx install pyflyby && pipx pipenv pyflyby install --upgrade black")
	doifnocmd("pyright", "!pipx install pyright")
end

function Lang.lua()
	Lang._CocInstall("coc-lua")
	doifnocmd("stylua", function()
		print("Install cargo and then cargo install stylua")
	end)
end

function Lang.vim()
    Lang._CocInstall("coc-vimlsp")
end

function Lang.groovy()
    Lang._CocInstall("coc-groovy")
end

function Lang.c()
    Lang._CocInstall("coc-clangd")
    Lang._CocInstall("coc-cmake")
end

function Lang.cmake()
    Lang.c()
end

function Lang.cpp()
    Lang.c()
end

function Lang.tex()
    Lang._CocInstall("coc-vimtext")
end

function Lang.ruby()
    Lang._CocInstall("coc-solargraph")
end

function Lang._main(args)
	print(vim.inspect(args))
	local filetype = args.fargs[1] or vim.bo.filetype
	assert(filetype ~= nil and filetype ~= "", "filetype = " .. vim.inspect(filetype))
	print("Setuping " .. vim.inspect(filetype))
	return Lang[filetype]()
end

-------------------------------------------------------------------------------

local kc = {}

function kc.setup()
	vim.api.nvim_create_user_command("KcSetupLang", Lang._main, { nargs = "?" })
	vim.api.nvim_create_user_command("SetupLang", Lang._main, { nargs = "?" })
end

return kc
