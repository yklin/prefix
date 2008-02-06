# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/dbus/dbus-1.1.4.ebuild,v 1.4 2008/02/06 00:26:11 steev Exp $

EAPI="prefix"

inherit eutils multilib autotools flag-o-matic

DESCRIPTION="A message bus system, a simple way for applications to talk to each other"
HOMEPAGE="http://dbus.freedesktop.org/"
SRC_URI="http://dbus.freedesktop.org/releases/dbus/${P}.tar.gz"

LICENSE="|| ( GPL-2 AFL-2.1 )"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE="debug doc selinux X"

RDEPEND="X? ( x11-libs/libXt x11-libs/libX11 )
	selinux? ( sys-libs/libselinux
				sec-policy/selinux-dbus )
	>=dev-libs/expat-1.95.8
	!<sys-apps/dbus-0.91"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	doc? (	app-doc/doxygen
		app-text/xmlto )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	# Patch that *should* fix dbus-launch hanging around after exiting X
	epatch "${FILESDIR}/${PN}-1.1.4-xdisplay_null.patch"
	epatch "${FILESDIR}"/${PN}-1.1.3-darwin.patch
	eautoreconf
}

src_compile() {
	# so we can get backtraces from apps
	append-flags -rdynamic

	local myconf=""

	hasq test ${FEATURES} && myconf="${myconf} --enable-tests=yes"

	econf \
		$(use_with X x) \
		$(use_enable kernel_linux inotify) \
		$(use_enable kernel_FreeBSD kqueue) \
		$(use_enable selinux) \
		$(use_enable debug verbose-mode) \
		$(use_enable debug asserts) \
		--with-xml=expat \
		--with-system-pid-file="${EPREFIX}"/var/run/dbus.pid \
		--with-system-socket="${EPREFIX}"/var/run/dbus/system_bus_socket \
		--with-session-socket-dir="${EPREFIX}"/tmp \
		--with-dbus-user=messagebus \
		--localstatedir="${EPREFIX}"/var \
		$(use_enable doc doxygen-docs) \
		--disable-xml-docs \
		${myconf} \
		|| die "econf failed"

	# after the compile, it uses a selinuxfs interface to
	# check if the SELinux policy has the right support
	use selinux && addwrite /selinux/access

	emake || die "make failed"
}

src_test() {
	DBUS_VERBOSE=1 make check || die "make check failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	# initscript
	newinitd "${FILESDIR}"/dbus.init-1.0 dbus

	# dbus X session script (#77504)
	# turns out to only work for GDM. has been merged into other desktop
	# (kdm and such scripts)
	exeinto /etc/X11/xinit/xinitrc.d/
	doexe "${FILESDIR}"/30-dbus

	# needs to exist for the system socket
	keepdir /var/run/dbus
	# needs to exist for machine id
	keepdir /var/lib/dbus
	# needs to exist for dbus sessions to launch

	keepdir /usr/lib/dbus-1.0/services
	keepdir /usr/share/dbus-1/services
	keepdir /etc/dbus-1/system.d/
	keepdir /etc/dbus-1/session.d/

	dodoc AUTHORS ChangeLog HACKING NEWS README doc/TODO
	if use doc; then
		dohtml doc/*html
	fi
}

pkg_preinst() {
	enewgroup messagebus || die "Problem adding messagebus group"
	enewuser messagebus -1 "-1" -1 messagebus || die "Problem adding messagebus user"
}

pkg_postinst() {
	elog "To start the D-Bus system-wide messagebus by default"
	elog "you should add it to the default runlevel :"
	elog "\`rc-update add dbus default\`"
	elog
	elog "Some applications require a session bus in addition to the system"
	elog "bus. Please see \`man dbus-launch\` for more information."
	elog
	ewarn
	ewarn "You MUST run 'revdep-rebuild' after emerging this package"
	elog  "If you notice any issues, please rebuild sys-apps/hal"
	ewarn
	ewarn "If you are currently running X with the hal useflag enabled"
	ewarn "restarting the dbus service WILL restart X as well"
	ebeep 5
	ewarn
}
