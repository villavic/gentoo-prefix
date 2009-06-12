# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-base/libxfce4menu/libxfce4menu-4.6.1.ebuild,v 1.5 2009/06/10 07:28:33 fauli Exp $

EAPI="1"

RESTRICT="test"
inherit xfce4

xfce4_core

DESCRIPTION="Desktop menu library"
HOMEPAGE="http://www.xfce.org/projects/libraries"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
LICENSE="LGPL-2 FDL-1.1"
IUSE="debug doc"

RDEPEND=">=dev-libs/glib-2.6:2
	>=x11-libs/gtk+-2.6:2
	>=xfce-base/libxfce4util-${XFCE_VERSION}"
DEPEND="${RDEPEND}
	dev-util/intltool
	doc? ( dev-util/gtk-doc )"

pkg_setup() {
	XFCE_CONFIG+=" $(use_enable doc gtk-doc)"
}

DOCS="AUTHORS ChangeLog NEWS README THANKS TODO"
