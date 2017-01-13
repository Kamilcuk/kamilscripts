# link


https://wiki.archlinux.org/index.php/PKGBUILD

# defualt makepkg

```
# This is an example PKGBUILD file. Use this as a start to creating your own,
# and remove these comments. For more information, see 'man PKGBUILD'.
# NOTE: Please fill out the license field for your package! If it is unknown,
# then please put 'unknown'.

# Maintainer: Your Name <youremail@domain.com>
pkgname=NAME
pkgver=VERSION
pkgrel=1
epoch=
pkgdesc=""
arch=()
url=""
license=('GPL')
groups=()
depends=()
makedepends=()
checkdepends=()
optdepends=()
provides=()
conflicts=()
replaces=()
backup=()
options=()
install=
changelog=
source=("$pkgname-$pkgver.tar.gz"
        "$pkgname-$pkgver.patch")
noextract=()
md5sums=()
validpgpkeys=()

prepare() {
	cd "$pkgname-$pkgver"
	patch -p1 -i "$srcdir/$pkgname-$pkgver.patch"
}

build() {
	cd "$pkgname-$pkgver"
	./configure --prefix=/usr
	make
}

check() {
	cd "$pkgname-$pkgver"
	make -k check
}

package() {
	cd "$pkgname-$pkgver"
	make DESTDIR="$pkgdir/" install
}
```

# example .install file

```
# This is a default template for a post-install scriptlet.
# Uncomment only required functions and remove any functions
# you don't need (and this header).

## arg 1:  the new package version
#pre_install() {
	# do something here
#}

## arg 1:  the new package version
#post_install() {
	# do something here
#}

## arg 1:  the new package version
## arg 2:  the old package version
#pre_upgrade() {
	# do something here
#}

## arg 1:  the new package version
## arg 2:  the old package version
#post_upgrade() {
	# do something here
#}

## arg 1:  the old package version
#pre_remove() {
	# do something here
#}

## arg 1:  the old package version
#post_remove() {
	# do something here
#}
```

# end 
