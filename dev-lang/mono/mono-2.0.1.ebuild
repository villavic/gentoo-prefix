# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/mono/mono-2.0.1.ebuild,v 1.2 2008/11/23 16:52:37 loki_val Exp $

EAPI="prefix"

inherit base eutils flag-o-matic multilib autotools

DESCRIPTION="Mono runtime and class libraries, a C# compiler/interpreter"
HOMEPAGE="http://www.go-mono.com"
SRC_URI="ftp://ftp.novell.com/pub/mono/sources/mono/${P}.tar.bz2"

LICENSE="|| ( GPL-2 LGPL-2 X11 )"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

RDEPEND="!<dev-dotnet/pnet-0.6.12
		>=dev-libs/glib-2.6
		=dev-dotnet/libgdiplus-${PV%%.*}*"
DEPEND="${RDEPEND}
		sys-devel/bc
		>=dev-util/pkgconfig-0.19"
PDEPEND="dev-dotnet/pe-format"

RESTRICT="test"

#Threading and mimeicon patches from Fedora CVS. Muine patch from Novell.

PATCHES=(	"${FILESDIR}/${PN}-biginteger_overflow.diff"
		"${FILESDIR}/${PN}-2.0-ppc-threading.patch"
		"${FILESDIR}/${PN}-2.0-mimeicon.patch"
		"${FILESDIR}/${P}-fix-wsdl-troubles-with-muine.patch" )


function get-memory-total() {
	cat /proc/meminfo | grep MemTotal | sed -r "s/[^0-9]*([[0-9]+).*/\1/"
}

src_compile() {
	# mono's build system is finiky, strip the flags
	strip-flags

	#Remove this at your own peril. Mono will barf in unexpected ways.
	append-flags -fno-strict-aliasing

	# Enable large heaps if memory is more than >=3GB
	if [[ $(get-memory-total) -ge 3145728 ]] ; then
		myconf="${myconf} --with-large-heap=yes"
	fi

	# Force the use of monolite mcs to prevent issues with classlibs (bug #118062)
	touch "${S}"/mcs/build/deps/use-monolite

	econf	--without-moonlight \
		--with-preview=yes \
		--with-glib=system \
		--with-gc=included \
		--with-libgdiplus=installed \
		--with-tls=__thread \
		--with-ikvm=yes \
		--with-jit=yes
	emake EXTERNAL_MCS=false EXTERNAL_MONO=false

	if [[ "$?" -ne "0" ]]; then
		ewarn "If you are using any hardening features such as"
		ewarn "PIE+SSP/SELinux/grsec/PAX then most probably this is the reason"
		ewarn "why build has failed. In this case turn any active security"
		ewarn "enhancements off and try emerging the package again"
		die
	fi
}

src_test() {
	vecho ">>> Test phase [check]: ${CATEGORY}/${PF}"

	mkdir -p "${T}/home/mono" || die "mkdir home failed"

	export HOME="${T}/home/mono"
	export XDG_CONFIG_HOME="${T}/home/mono"
	export XDG_DATA_HOME="${T}/home/mono"

	if ! LC_ALL=C emake -j1 check; then
		hasq test $FEATURES && die "Make check failed. See above for details."
		hasq test $FEATURES || eerror "Make check failed. See above for details."
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"

	dodoc AUTHORS ChangeLog NEWS README

	docinto docs
	dodoc docs/*

	docinto libgc
	dodoc libgc/ChangeLog
}
