# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="4"

inherit eutils toolchain-funcs unpacker

DESCRIPTION="ELF related utils for ELF 32/64 binaries that can check files for security relevant properties"
HOMEPAGE="https://wiki.gentoo.org/index.php?title=Project:Hardened/PaX_Utilities"
SRC_URI="mirror://gentoo/${P}.tar.xz
	http://dev.gentoo.org/~solar/pax/${P}.tar.xz
	http://dev.gentoo.org/~vapier/dist/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-freebsd ~ia64-hpux ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="caps debug python seccomp"

RDEPEND="caps? ( >=sys-libs/libcap-2.24 )
	python? ( dev-python/pyelftools )
	seccomp? ( sys-libs/libseccomp )"
DEPEND="${RDEPEND}
	caps? ( virtual/pkgconfig )
	seccomp? ( virtual/pkgconfig )
	app-arch/xz-utils"

_emake() {
	emake \
		USE_CAP=$(usex caps) \
		USE_DEBUG=$(usex debug) \
		USE_PYTHON=$(usex python) \
		USE_SECCOMP=$(usex seccomp) \
		"$@"
}

src_configure() {
	# Avoid slow configure+gnulib+make if on an up-to-date Linux system
	if use prefix || ! use kernel_linux || \
	   has_version '<sys-libs/glibc-2.10'
	then
		econf $(use_with caps) $(use_with debug) $(use_with python) $(use_with seccomp)
	else
		tc-export CC PKG_CONFIG
	fi
}

src_compile() {
	_emake
}

src_test() {
	_emake check
}

src_install() {
	_emake DESTDIR="${D}" PKGDOCDIR='$(DOCDIR)'/${PF} install
}
