# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/setuptools/setuptools-0.6_rc6.ebuild,v 1.5 2007/08/24 20:10:39 armin76 Exp $

EAPI="prefix"

inherit distutils

MY_P=${P/_rc/c}
S="${WORKDIR}/${MY_P}"

DESCRIPTION="A collection of enhancements to the Python distutils including easy install"
HOMEPAGE="http://peak.telecommunity.com/DevCenter/setuptools"
SRC_URI="http://cheeseshop.python.org/packages/source/s/setuptools/${MY_P}.tar.gz"

LICENSE="PSF-2.2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""

RDEPEND=">=dev-lang/python-2.4.2"
DEPEND="${RDEPEND}"

DOCS="EasyInstall.txt api_tests.txt pkg_resources.txt setuptools.txt"

src_test() {
	"${python}" setup.py test || die "tests failed"
}
