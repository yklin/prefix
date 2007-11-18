# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/ed/ed-0.8.ebuild,v 1.8 2007/09/28 17:07:36 nixnut Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

DESCRIPTION="Your basic line editor"
HOMEPAGE="http://www.gnu.org/software/ed/"
SRC_URI="mirror://gnu/ed/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~x86 ~x86-fbsd ~x86-macos ~x86-solaris"
IUSE=""

DEPEND="sys-apps/texinfo"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-0.5-build.patch
}

src_compile() {
	tc-export CC CXX
	# custom configure script ... econf wont work
	./configure \
		--prefix="${EPREFIX}"/ \
		--datadir="${EPREFIX}"/usr/share \
		${EXTRA_ECONF} \
		|| die
	emake || die
}

src_install() {
	emake install DESTDIR="${D}" || die
	doman doc/ed.1
	dosym ed.1 /usr/share/man/man1/red.1
	dodoc AUTHORS ChangeLog NEWS README TODO
}
