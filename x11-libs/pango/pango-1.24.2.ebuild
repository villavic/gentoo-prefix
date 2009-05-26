# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/pango/pango-1.24.2.ebuild,v 1.3 2009/05/25 22:49:50 jer Exp $

EAPI="2"

inherit eutils gnome2 multilib libtool

DESCRIPTION="Text rendering and layout library"
HOMEPAGE="http://www.pango.org/"

LICENSE="LGPL-2 FTL"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="X debug doc"

# FIXME: add gobject-introspection dependency when it is available
RDEPEND=">=dev-libs/glib-2.17.3
	>=media-libs/fontconfig-2.5.0
	>=media-libs/freetype-2
	>=x11-libs/cairo-1.7.6[X?,svg]
	X? (
		x11-libs/libXrender
		x11-libs/libX11
		x11-libs/libXft )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9
	doc? (
		>=dev-util/gtk-doc-1
		~app-text/docbook-xml-dtd-4.1.2 )
	X? ( x11-proto/xproto )"

DOCS="AUTHORS ChangeLog* NEWS README THANKS"

function multilib_enabled() {
	has_multilib_profile || ( use x86 && [ "$(get_libdir)" = "lib32" ] )
}

pkg_setup() {
	G2CONF="${G2CONF} $(use_with X x) $(use_enable debug)"
	if use X ; then
		G2CONF="${G2CONF} \
			--x-includes=${EPREFIX}/usr/include \
			--x-libraries=${EPREFIX}/usr/lib"
	fi
}

src_prepare() {
	gnome2_src_prepare

	# make config file location host specific so that a 32bit and 64bit pango
	# wont fight with each other on a multilib system.  Fix building for
	# emul-linux-x86-gtklibs
	if multilib_enabled ; then
		epatch "${FILESDIR}/${PN}-1.2.5-lib64.patch"
	fi

	# gtk-doc checks do not pass, upstream bug #578944
	sed 's:TESTS = check.docs: TESTS = :g'\
		-i docs/Makefile.am docs/Makefile.in || die "sed failed"
	
	elibtoolize # for Darwin bundles
}

src_install() {
	gnome2_src_install
	rm "${ED}/etc/pango/pango.modules"
}

pkg_postinst() {
	if [ "${ROOT}" = "/" ] ; then
		einfo "Generating modules listing..."

		local PANGO_CONFDIR=

		if multilib_enabled ; then
			PANGO_CONFDIR="${EPREFIX}/etc/pango/${CHOST}"
		else
			PANGO_CONFDIR="${EPREFIX}/etc/pango"
		fi

		mkdir -p ${PANGO_CONFDIR}

		pango-querymodules > ${PANGO_CONFDIR}/pango.modules
	fi
}
