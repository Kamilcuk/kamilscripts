
" Disable spelling inside ``` ``` sections
syntax region KcCodeRegion start=/^```$/ end=/^```$/ contains=@NoSpell

" Disable spelling incide --- --- sections
syntax region KcMarkdownExetensionRegion start=/^---$/ end=/^---$/ contains=@NoSpell
