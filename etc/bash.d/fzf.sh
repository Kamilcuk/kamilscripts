
if [[ -e /usr/share/fzf/key-bindings.bash ]]; then
	. /usr/share/fzf/key-bindings.bash
	. /usr/share/fzf/completion.bash
elif command -v fzf-share >/dev/null; then
  source "$(fzf-share)/key-bindings.bash"
  source "$(fzf-share)/completion.bash"
fi

