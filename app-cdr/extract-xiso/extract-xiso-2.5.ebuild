# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-cdr/extract-xiso/extract-xiso-2.5.ebuild,v 1.4 2008/10/25 20:55:24 vapier Exp $

inherit toolchain-funcs

MY_PV=${PV/_beta/b}

DESCRIPTION="Tool for extracting and creating optimised Xbox ISO images"
HOMEPAGE="http://sourceforge.net/projects/extract-xiso"
SRC_URI="mirror://sourceforge/extract-xiso/${PN}_v${MY_PV}_src.tgz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i \
		-e 's:__LINUX__:__linux__:' \
		*.[ch] */*.[ch] || die
	epatch "${FILESDIR}"/${P}-darwin.patch
	epatch "${FILESDIR}"/${P}-interix.patch
	# older interix versions need some help...
	[[ ${CHOST} == *-interix[35]* ]] && epatch "${FILESDIR}"/${P}-interix5.patch
}

doit() { echo "$@"; "$@"; }

src_compile() {
	doit $(tc-getCC) ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} \
		extract-xiso.c libftp-*/*.c -o extract-xiso || die
}

src_install() {
	dobin extract-xiso || die
	dodoc README.TXT
}
