
command! -bang -bar -nargs=+ CMakeHelp call cmakehelp#open(<q-args>)
setlocal keywordprg=:CMakeHelp
