command! -range HtmlQuote call kc#htmlentities(<line1>, <line2>, 1)
command! -range HtmlUnquote call kc#htmlentities(<line1>, <line2>, 0)
