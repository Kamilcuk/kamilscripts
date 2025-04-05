---@class MyModule
local M = {}

-- Split string containing words and comments into a list of words.
---@param txt string
---@return string[]
function M.shsplit(txt)
  local ret = {}
  for word in txt:gsub("[$#][^\r\n]+", ""):gmatch "%S+" do
    table.insert(ret, word)
  end
  return ret
end

---@class Config
---@field lsps string[]? All language server protocol configuration available in nvim-lspconfig.
---@field formatters string[]? All formatters configurations available in none-ls.nvim
---@field diagnostics string[]? All diagnostics utilities configurations available in none-ls.nvim
---@field accept string[]? An optional list of utilities to accept. Used to drastically reduce the startup time.
---@field ignore string[]? A list of ignored modules. They do not work mostly.
-- Is it unclear to me how to properly handle like python3 -m module.
-- I do not want to handle it, it would drastically increase startup time.
---@field ignore_cmds string[]? List of ignored commands. Bottom line, this is a list of interpreters.

---@type Config
M.config = {
  lsps = M.shsplit [[
  # curl -sSL https://api.github.com/repos/neovim/nvim-lspconfig/contents/lua/lspconfig/configs | jq -r '.[].name[:-4]' | fmt
  ada_ls agda_ls aiken air alloy_ls anakin_language_server angularls
  ansiblels antlersls apex_ls arduino_language_server asm_lsp ast_grep
  astro atlas autohotkey_lsp autotools_ls awk_ls azure_pipelines_ls
  bacon_ls ballerina basedpyright bashls basics_ls bazelrc_lsp beancount
  bicep biome bitbake_language_server bitbake_ls blueprint_ls bqnlsp
  bright_script bsl_ls buck2 buddy_ls buf_ls bufls bzl c3_lsp cadence
  cairo_ls ccls cds_lsp circom-lsp clangd clarity_lsp clojure_lsp
  cmake cobol_ls codeqlls coffeesense contextive coq_lsp crystalline
  csharp_ls css_variables cssls cssmodules_ls cucumber_language_server
  cue custom_elements_ls cypher_ls daedalus_ls dafny dagger dartls dcmls
  debputy delphi_ls denols dhall_lsp_server diagnosticls digestif djlsp
  docker_compose_language_service dockerls dolmenls dotls dprint drools_lsp
  ds_pinyin_lsp dts_lsp earthlyls ecsact efm elixirls elmls elp ember
  emmet_language_server emmet_ls erg_language_server erlangls esbonio
  eslint facility_language_server fennel_language_server fennel_ls fish_lsp
  flow flux_lsp foam_ls fortls fsautocomplete fsharp_language_server
  fstar futhark_lsp gdscript gdshader_lsp gh_actions_ls ghcide ghdl_ls
  ginko_ls gitlab_ci_ls glasgow gleam glint glsl_analyzer glslls
  golangci_lint_ls gopls gradle_ls grammarly graphql groovyls guile_ls
  harper_ls haxe_language_server hdl_checker helm_ls hhvm hie hlasm hls
  hoon_ls html htmx hydra_lsp hyprls idris2_lsp intelephense janet_lsp
  java_language_server jdtls jedi_language_server jinja_lsp jqls jsonls
  jsonnet_ls julials kcl koka kotlin_language_server kulala_ls lean3ls
  leanls lelwel_ls lemminx lexical lsp_ai ltex ltex_plus lua_ls luau_lsp
  lwc_ls m68k markdown_oxide marko-js marksman matlab_ls mdx_analyzer
  mesonlsp metals millet mint mlir_lsp_server mlir_pdll_lsp_server mm0_ls
  mojo motoko_lsp move_analyzer msbuild_project_tools_server muon mutt_ls
  nelua_lsp neocmake nextflow_ls nextls nginx_language_server nickel_ls
  nil_ls nim_langserver nimls nixd nomad_lsp ntt nushell nxls ocamlls
  ocamllsp ols omnisharp opencl_ls openedge_ls openscad_ls openscad_lsp
  oxlint pact_ls pasls pbls perlls perlnavigator perlpls pest_ls phan
  phpactor pico8_ls pkgbuild_language_server please poryscript_pls
  postgres_lsp powershell_es prismals prolog_ls prosemd_lsp protols psalm
  pug puppet purescriptls pylsp pylyzer pyre pyright qmlls quick_lint_js
  r_language_server racket_langserver raku_navigator reason_ls regal regols
  relay_lsp remark_ls rescriptls rls rnix robotcode robotframework_ls roc_ls
  rome rubocop ruby_lsp ruff ruff_lsp rune_languageserver rust_analyzer
  salt_ls scheme_langserver scry selene3p_ls serve_d shopify_theme_ls
  sixtyfps slangd slint_lsp smarty_ls smithy_ls snakeskin_ls snyk_ls
  solang solargraph solc solidity solidity_ls solidity_ls_nomicfoundation
  somesass_ls sorbet sourcekit sourcery spectral spyglassmc_language_server
  sqlls sqls standardrb starlark_rust starpls statix steep stimulus_ls
  stylelint_lsp stylua3p_ls superhtml svelte svlangserver svls swift_mesonls
  syntax_tree systemd_ls tabby_ml tailwindcss taplo tblgen_lsp_server
  teal_ls templ terraform_lsp terraformls texlab textlsp tflint theme_check
  thriftls tilt_ls tinymist ts_ls ts_query_ls tsp_server ttags turbo_ls
  turtle_ls tvm_ffi_navigator twiggy_language_server typeprof typos_lsp
  typst_lsp uiua ungrammar_languageserver unison unocss uvls v_analyzer
  vacuum vala_ls vale_ls vdmj vectorcode_server verible veridian
  veryl_ls vhdl_ls vimls visualforce_ls vls volar vscoqtop vtsls vuels
  wasm_language_tools wgsl_analyzer yamlls yang_lsp yls ziggy ziggy_schema
  zk zls
  ]],

  formatters = M.shsplit [[
  # curl -sSL https://api.github.com/repos/nvimtools/none-ls.nvim/contents/lua/null-ls/builtins/formatting | jq -r '.[].name[:-4]' | fmt
  alejandra asmfmt astyle atlas_fmt bean_format bibclean biome black
  blackd blade_formatter bsfmt buf buildifier cbfmt clang_format cljfmt
  cljstyle cmake_format codespell crystal_format csharpier cue_fmt
  cueimports d2_fmt dart_format dfmt djhtml djlint duster dxfmt elm_format
  emacs_scheme_mode emacs_vhdl_mode erb_format erb_lint erlfmt fantomas
  findent fish_indent fnlfmt forge_fmt format_r fprettify gdformat gersemi
  gleam_format gn_format gofmt gofumpt goimports goimports_reviser golines
  google_java_format haxe_formatter hclfmt htmlbeautifier isort isortd
  joker just ktlint leptosfmt markdownlint mdformat mix nginx_beautifier
  nimpretty nix_flake_fmt nixfmt nixpkgs_fmt npm_groovy_lint ocamlformat
  ocdc opentofu_fmt packer pg_format phpcbf phpcsfixer pint prettier
  prettierd pretty_php prisma_format protolint ptop puppet_lint purs_tidy
  pyink qmlformat racket_fixw raco_fmt rego remark rescript rubocop rubyfmt
  rufo rustywind scalafmt shellharden shfmt smlfmt sql_formatter sqlfluff
  sqlfmt sqlformat sqruff stylelint styler stylua surface swift_format
  swiftformat swiftlint terraform_fmt terragrunt_fmt textlint tidy topiary
  treefmt typstfmt typstyle uncrustify usort verible_verilog_format xmllint
  yamlfix yamlfmt yapf zprint
  ]],

  diagnostics = M.shsplit [[
  # curl -sSL https://api.github.com/repos/nvimtools/none-ls.nvim/contents/lua/null-ls/builtins/diagnostics | jq -r '.[].name[:-4]' | fmt
  actionlint alex ansiblelint bean_check bslint buf buildifier cfn_lint
  checkmake checkstyle clazy clj_kondo cmake_lint codespell commitlint
  cppcheck credo cue_fmt deadnix djlint dotenv_linter editorconfig_checker
  erb_lint fish gccdiag gdlint gitlint glslc golangci_lint hadolint
  haml_lint ktlint ltrs markdownlint markdownlint_cli2 markuplint mdl
  mlint mypy npm_groovy_lint opacheck perlimports phpcs phpmd phpstan
  pmd proselint protolint puppet_lint pydoclint pylint qmllint reek
  regal revive rpmspec rstcheck rubocop saltlint selene semgrep solhint
  spectral sqlfluff sqruff staticcheck statix stylelint stylint swiftlint
  teal terraform_validate terragrunt_validate textidote textlint tfsec
  tidy todo_comments trail_space trivy twigcs vacuum vale verilator vint
  write_good yamllint zsh
  ]],

  accept = {},
  ignore = M.shsplit [[
  bufls ruff_lsp # deprecated
  # dunno how to handle
  esbonio   # python3
  groovyls  # java
  flow   # npx
  nextflow_ls  # dotnet
  turtle_ls  # node
  perlls  # perl
  ]],
  ignore_cmds = M.shsplit [[
  java python python3 sh bash dotnet npx node perl
  ]],
}

---@param args Config?
function M.setup(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
  vim.api.nvim_create_user_command("AllLspInfo", M.show, {})
end

---@param str string the path string
local function basename(str) return str:gsub("(.*/)(.*)", "%2") end

---@type {string: boolean}
M._execache = {}

-- Check if a command exist and is ok to execute.
---@param cmd string[]
---@return boolean
function M._check_command(cmd)
  if
    type(cmd) == "table"
    and type(cmd[1]) == "string"
    and not vim.list_contains(M.config.ignore_cmds, cmd[1])
    and not vim.list_contains(M.config.ignore_cmds, basename(cmd[1]))
  then
    local v = M._execache[cmd[1]]
    if v == nil then
      v = vim.fn.executable(cmd[1]) == 1
      M._execache[cmd[1]] = v
    end
    return v
  end
  return false
end

---@class SomeRet
---@field cmd string[]

-- From a list of modules, get those that we are allowed to use.
---@param data string[]
---@param section string Import module to check if it is importable.
---@param get_cmd fun(any): string[]
---@return [string, string[], any]
function M._get_allowed(data, section, get_cmd)
  local ret = {}
  for _, name in ipairs(data) do
    if next(M.config.accept) == nil or vim.list_contains(M.config.accept, name) then
      if next(M.config.ignore) == nil or not vim.list_contains(M.config.ignore, name) then
        local ok, mod = pcall(require, section .. "." .. name)
        if ok then
          local cmd = get_cmd(mod)
          if M._check_command(cmd) then table.insert(ret, { name = name, cmd = cmd, mod = mod }) end
        end
      end
    end
  end
  return ret
end

function M._for_lspconfig()
  return M._get_allowed(
    M.config.lsps,
    "lspconfig.configs",
    function(mod) return mod.default_config and mod.default_config.cmd end
  )
end

-- Generate a list of strings ready to use for nvim-lspconfig servers configuration.
---@return string[]
function M.for_lspconfig()
  return vim.iter(M._for_lspconfig()):map(function(v) return v.name end):totable()
  -- return {"lua_ls"}
end

-- Abstract none-ls generation
---@param data string[]
---@param section string
function M._for_none_ls(data, section)
  return M._get_allowed(
    data,
    "null-ls.builtins." .. section,
    function(mod) return mod._opts and { mod._opts.command } end
  )
end

function M._for_none_ls_diagnostics() return M._for_none_ls(M.config.diagnostics, "diagnostics") end

function M._for_none_ls_formatters() return M._for_none_ls(M.config.formatters, "formatting") end

-- Generate a list of modules read to use for none-ls sources configuration.
function M.for_none_ls()
  local ret = M._for_none_ls_diagnostics()
  vim.list_extend(ret, M._for_none_ls_formatters())
  return vim.iter(ret):map(function(v) return v.mod end):totable()
end

function M._show(what, data)
  local txt = vim.iter(data):map(function(i) return "\t" .. i.name .. "\t" .. vim.fn.exepath(i.cmd[1]) end):join "\n"
  print("Enabled " .. #data .. " " .. what .. ":\n" .. txt)
end

-- Show what is enabled and what is not.
function M.show()
  M._show("lspconfig", M._for_lspconfig())
  M._show("null-ls formatters", M._for_none_ls_formatters())
  M._show("null-ls diagnostics", M._for_none_ls_diagnostics())
end

return M
