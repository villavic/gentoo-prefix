# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/mediastreamer/mediastreamer-2.3.0.ebuild,v 1.2 2010/02/23 06:51:31 josejx Exp $

EAPI="3"

inherit eutils autotools multilib

DESCRIPTION="Mediastreaming library for telephony application"
HOMEPAGE="http://www.linphone.org/index.php/eng/code_review/mediastreamer2"
SRC_URI="http://download.savannah.nongnu.org/releases/linphone/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-macos ~x86-macos"
IUSE="+alsa coreaudio debug examples gsm ilbc ipv6 jack oss portaudio +speex theora video x264 X"

RDEPEND=">=net-libs/ortp-0.15.0_p1
	alsa? ( media-libs/alsa-lib )
	gsm? ( media-sound/gsm )
	jack? ( media-libs/libsamplerate
		media-sound/jack-audio-connection-kit )
	portaudio? ( media-libs/portaudio )
	speex? ( >=media-libs/speex-1.2_beta3 )
	video? ( media-libs/libsdl[video,X]
		media-video/ffmpeg
		theora? ( media-libs/libtheora )
		X? ( x11-libs/libX11 ) )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

PDEPEND="ilbc? ( media-plugins/mediastreamer-ilbc )
	video? ( x264? ( media-plugins/mediastreamer-x264 ) )"

# TODO:
# run-time test for ipv6 : does it need ortp[ipv6] ?

# NOTES:
# in some way, v4l support is auto-magic but keeping it like that atm

pkg_setup() {
	if ! use oss && ! use alsa && ! use jack && ! use portaudio && ! use coreaudio;
	then
		eerror "You must enable at least oss, alsa, jack, portaudio or coreaudio"
		eerror "Please, re-emerge ${PN} with one of this USE flag enabled"
		die
	fi

	if ! use video && ( use theora || use X ); then
		ewarn "X and theora support are enabled if video USE flag is enabled"
		ewarn "If you want X or theora support, consider re-emerge with USE=\"video\""
	fi
}

src_prepare() {
	# too hard to have a flexible lib dir in a clean way
	sed -i -e "s:\(/usr/kde/3.5/\)lib:\1$(get_libdir):" configure.ac \
		|| die "patching configure.ac failed"

	# respect user's CFLAGS
	sed -i -e "s:-O2::" configure.ac || die "patching configure.ac failed"

	# change default paths
	sed -i -e "s:\(\${prefix}/\)lib:\1$(get_libdir):" \
		-e "s:\(prefix/share\):\1/${PN}:" configure.ac \
		|| die "patching configure.ac failed"

	# fix html doc installation dir
#	sed -i -e "s:\$(pkgdocdir):\$(docdir):" help/Makefile.am \
#		|| die "patching help/Makefile.am failed"
	sed -i -e "s:\(doc_htmldir=\).*:\1\$(htmldir):" help/Makefile.am \
		|| die "patching help/Makefile.am failed"

	eautoreconf

	# don't build examples in tests/
	sed -i -e "s:\(SUBDIRS = .*\) tests \(.*\):\1 \2:" Makefile.in \
		|| die "patching Makefile.in failed"
}

src_configure() {
	local macaqsnd=
	# Mac OS X Audio Queue is an audio recording facility, available on
	# 10.5 (Leopard, Darwin9) and onward
	if use coreaudio && [[ ${CHOST} == *-darwin* && ${CHOST##*-darwin} -ge 9 ]];
	then
		macaqsnd="--enable-macaqsnd"
	else
		macaqsnd="--disable-macaqsnd"
	fi
	# strict: don't want -Werror
	# external-ortp: don't use bundled libs
	# arts: arts is deprecated
	econf \
		--htmldir="${EPREFIX}"/usr/share/doc/${PF}/html \
		--datadir="${EPREFIX}"/usr/share/${PN} \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		--disable-strict \
		--enable-external-ortp \
		--disable-dependency-tracking \
		--disable-artsc \
		$(use_enable alsa) \
		$(use_enable coreaudio macsnd) ${macaqsnd} \
		$(use_enable debug) \
		$(use_enable gsm) \
		$(use_enable ipv6) \
		$(use_enable jack) \
		$(use_enable oss) \
		$(use_enable portaudio) \
		$(use_enable speex) \
		$(use_enable theora) \
		$(use_enable video) \
		$(use_enable X x11)
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc AUTHORS ChangeLog NEWS README || die "dodoc failed"

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins tests/*.c || die "doins failed"
	fi
}
