augroup Binary
  au!
  au BufReadPre  *.bin let &bin=1
  au BufReadPost *.bin if &bin | %!xxd | set ft=xxd | endif
  au BufWritePre *.bin if &bin | %!xxd -r | endif
  au BufWritePost *.bin if &bin | %!xxd | set nomod | endif
augroup END

