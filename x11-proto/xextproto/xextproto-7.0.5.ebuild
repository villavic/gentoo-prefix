# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-proto/xextproto/xextproto-7.0.5.ebuild,v 1.6 2009/10/26 20:46:02 jer Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org XExt protocol headers"
KEYWORDS="~ppc-aix ~x64-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

DEPEND="x11-proto/inputproto"
RDEPEND="${DEPEND}"

PATCHES=( "${FILESDIR}/${PV}-dont-pull-in-Xmd-h-in-Xge-h.patch" )
