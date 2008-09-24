# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-terms/rxvt-unicode/rxvt-unicode-9.05-r1.ebuild,v 1.2 2008/09/24 00:54:46 yngwin Exp $

EAPI="prefix"

inherit autotools flag-o-matic

DESCRIPTION="rxvt clone with xft and unicode support"
HOMEPAGE="http://software.schmorp.de/"
SRC_URI="http://dist.schmorp.de/rxvt-unicode/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE="truetype perl iso14755 afterimage vanilla"

# see bug #115992 for modular x deps
RDEPEND="x11-libs/libX11
	x11-libs/libXft
	afterimage? ( media-libs/libafterimage )
	x11-libs/libXrender
	perl? ( dev-lang/perl )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	x11-proto/xproto"

src_unpack() {
	unpack ${A}
	cd "${S}"

	if ! use vanilla ; then
		epatch doc/urxvt-8.2-256color.patch
		epatch doc/wcwidth.patch
	fi

	local tdir=/usr/share/terminfo
	sed -i -e \
		"s~@TIC@ \(\$(srcdir)/etc/rxvt\)~@TIC@ -o ${ED}/${tdir} \1~" \
		doc/Makefile.in

	eautoreconf
}

src_compile() {
	myconf=''

	use iso14755 || myconf='--disable-iso14755'
	use vanilla || myconf="$myconf --enable-xterm-colors=256"

	econf --enable-everything \
		$(use_enable truetype xft) \
		$(use_enable afterimage) \
		$(use_enable perl) \
		--disable-text-blink \
		--with-xpm-includes="${EPREFIX}"/usr/include \
		--with-xpm-library="${EPREFIX}"/usr/lib \
		${myconf} || die

	emake || die

	sed -i \
		-e 's/RXVT_BASENAME = "rxvt"/RXVT_BASENAME = "urxvt"/' \
		"${S}"/doc/rxvt-tabbed || die "tabs sed failed"
}

src_install() {
	make DESTDIR="${D}" install || die

	dodoc README.FAQ Changes
	cd "${S}"/doc
	dodoc README* changes.txt etc/* rxvt-tabbed
}

pkg_postinst() {
	einfo "urxvt now always uses TERM=rxvt-unicode so that the"
	einfo "upstream-supplied terminfo files can be used."
}
