# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libffi/libffi-3.0.9_rc9.ebuild,v 1.2 2009/12/26 17:56:48 jer Exp $

inherit libtool eutils

DESCRIPTION="a portable, high level programming interface to various calling conventions."
HOMEPAGE="http://sourceware.org/libffi"
SRC_URI="ftp://sources.redhat.com/pub/${PN}/${P/_}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~ppc-aix ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="debug static-libs test"

RDEPEND=""
DEPEND="test? ( dev-util/dejagnu )"

S=${WORKDIR}/${P/_}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-3.0.8-interix.patch
	epatch "${FILESDIR}"/${PN}-3.0.9-irix.patch
	elibtoolize
}

src_compile() {
	econf \
		--disable-dependency-tracking \
		$(use_enable static-libs static) \
		$(use_enable debug)
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc ChangeLog* README
}