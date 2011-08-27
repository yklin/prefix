# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-p2p/rtorrent/rtorrent-0.8.7-r4.ebuild,v 1.1 2011/08/15 19:44:03 sochotnicky Exp $

EAPI=2

inherit eutils

DESCRIPTION="BitTorrent Client using libtorrent"
HOMEPAGE="http://libtorrent.rakshasa.no/"
SRC_URI="http://libtorrent.rakshasa.no/downloads/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris"
IUSE="color daemon debug ipv6 test xmlrpc"

COMMON_DEPEND=">=net-libs/libtorrent-0.12.${PV##*.}
	>=dev-libs/libsigc++-2.2.2:2
	>=net-misc/curl-7.19.1
	sys-libs/ncurses
	xmlrpc? ( dev-libs/xmlrpc-c )"
RDEPEND="${COMMON_DEPEND}
	daemon? ( app-misc/screen )"
DEPEND="${COMMON_DEPEND}
	test? ( dev-util/cppunit )
	dev-util/pkgconfig"

src_prepare() {
	# bug #358271
	epatch "${FILESDIR}"/${PN}-0.8.6-ncurses.patch

	use color && EPATCH_OPTS="-p1" epatch "${FILESDIR}"/${P}-canvas-fix.patch

	epatch "${FILESDIR}"/${PN}-0.8.5-solaris.patch
}

src_configure() {
	# need this, or configure script bombs out on some null shift, bug #291229
	export CONFIG_SHELL=${BASH}
	econf \
		--disable-dependency-tracking \
		$(use_enable debug) \
		$(use_enable ipv6) \
		$(use_with xmlrpc xmlrpc-c)
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS README TODO doc/rtorrent.rc
	doman doc/rtorrent.1

	if use daemon; then
		newinitd "${FILESDIR}/rtorrentd.init" rtorrentd || die "newinitd failed"
		newconfd "${FILESDIR}/rtorrentd.conf" rtorrentd || die "newconfd failed"
	fi
}

pkg_postinst() {
	if use color; then
		elog "rtorrent colors patch"
		elog "Set colors using the options below in .rtorrent.rc:"
		elog "Options: done_fg_color, done_bg_color, active_fg_color, active_bg_color"
		elog "Colors: 0 = black, 1 = red, 2 = green, 3 = yellow, 4 = blue,"
		elog "5 = magenta, 6 = cyan and 7 = white"
		elog "Example: done_fg_color = 1"
	fi
}