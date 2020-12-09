
if [[ $- != *i* ]]; then return; fi

if type nvim > /dev/null 2>&1; then
  alias vim='nvim'
fi

