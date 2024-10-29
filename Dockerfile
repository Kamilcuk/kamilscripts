FROM library/archlinux:base-devel AS base
RUN \
    pacman -Suy --needed --noconfirm \
		tar python awk grep gettext make diffutils bc vim rsync socat && \
    echo "$BASH_VERSION"

FROM base AS public_build
RUN pacman -Suy --noconfirm --needed base base-devel git sudo vim bash-completion
WORKDIR /app
COPY . .
RUN set -x && \
    pkg/archlinux/docker_build.sh ./archlinux-output && \
    pkg/archlinux/repo_create.sh ./public/archlinux/kamilrepo ./archlinux-output && \
    pkg/create_index.sh ./public/
FROM scratch AS public
COPY --from=public_build /app/public /
