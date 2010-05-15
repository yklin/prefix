# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/util-linux/util-linux-2.17.1.ebuild,v 1.2 2010/03/09 00:58:33 vapier Exp $

EAPI="2"

EGIT_REPO_URI="git://git.kernel.org/pub/scm/utils/util-linux-ng/util-linux-ng.git"
inherit eutils toolchain-funcs libtool autotools
[[ ${PV} == "9999" ]] && inherit git autotools

MY_PV=${PV/_/-}
MY_P=${PN}-ng-${MY_PV}
S=${WORKDIR}/${MY_P}

DESCRIPTION="Various useful Linux utilities"
HOMEPAGE="http://www.kernel.org/pub/linux/utils/util-linux-ng/"
if [[ ${PV} == "9999" ]] ; then
	SRC_URI=""
	#KEYWORDS=""
else
	SRC_URI="mirror://kernel/linux/utils/util-linux-ng/v${PV:0:4}/${MY_P}.tar.bz2
		loop-aes? ( http://loop-aes.sourceforge.net/updates/util-linux-ng-2.17.1-20100308.diff.bz2 )"
# this works on OSX, but cannot be right at this moment
#	KEYWORDS="~amd64-linux ~x86-linux"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE="crypt loop-aes nls old-linux perl selinux slang uclibc unicode"

RDEPEND="!sys-process/schedutils
	!sys-apps/setarch
	>=sys-libs/ncurses-5.2-r2
	!<sys-libs/e2fsprogs-libs-1.41.8
	!<sys-fs/e2fsprogs-1.41.8
	perl? ( dev-lang/perl )
	selinux? ( sys-libs/libselinux )
	slang? ( sys-libs/slang )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )
	virtual/os-headers"

src_prepare() {
	if [[ ${PV} == "9999" ]] ; then
		autopoint --force
		eautoreconf
	else
		use loop-aes && epatch "${WORKDIR}"/util-linux-ng-*.diff
	fi
	use uclibc && sed -i -e s/versionsort/alphasort/g -e s/strverscmp.h/dirent.h/g mount/lomount.c
	if use prefix ; then
		epatch "${FILESDIR}"/${P}-non-linux-shlibs.patch
		eautoreconf
	fi
	elibtoolize
}

src_configure() {
	local myconf=
	if use prefix ; then
		myconf="
			--disable-mount
			--disable-fsck
			--enable-libuuid
			--disable-uuidd
			--enable-libblkid
			--disable-arch
			--disable-agetty
			--disable-cramfs
			--disable-switch_root
			--disable-pivot_root
			--disable-fallocate
			--disable-unshare
			--disable-elvtune
			--disable-init
			--disable-kill
			--disable-last
			--disable-mesg
			--disable-partx
			--disable-raw
			--disable-rdev
			--disable-rename
			--disable-reset
			--disable-login-utils
			--disable-schedutils
			--disable-wall
			--disable-write
			--disable-login-chown-vcs
			--disable-login-stat-mail
			--disable-pg-bell
			--disable-use-tty-group
			--disable-makeinstall-chown
			--disable-makeinstall-setuid
		"
	else
		myconf="
			--enable-agetty
			--enable-cramfs
			$(use_enable old-linux elvtune)
			--disable-init
			--disable-kill
			--disable-last
			--disable-mesg
			--enable-partx
			--enable-raw
			--enable-rdev
			--enable-rename
			--disable-reset
			--disable-login-utils
			--enable-schedutils
			--disable-wall
			--enable-write
			--without-pam
			$(use_with selinux)
		"
	fi

	#	--with-fsprobe=blkid \
	econf \
		$(use_enable nls) \
		$(use unicode || echo --with-ncurses) \
		$(use_with slang) \
		$(tc-has-tls || echo --disable-tls) \
		${myconf}
}

src_compile() {
	if use prefix; then
		emake -C shlibs || die
	else
		emake || die
	fi
}

src_install() {
	if use prefix ; then
		emake -C shlibs install DESTDIR="${D}" || die "install failed"
	else
		emake install DESTDIR="${D}" || die "install failed"

		if ! use perl ; then #284093
			rm "${ED}"/usr/bin/chkdupexe || die
			rm "${ED}"/usr/share/man/man1/chkdupexe.1 || die
		fi

		if use crypt ; then
			newinitd "${FILESDIR}"/crypto-loop.initd crypto-loop || die
			newconfd "${FILESDIR}"/crypto-loop.confd crypto-loop || die
		fi
	fi
	dodoc AUTHORS NEWS README* TODO docs/*

	# need the libs in /
	gen_usr_ldscript -a blkid uuid
	# e2fsprogs-libs didnt install .la files, and .pc work fine
	rm -f "${ED}"/usr/$(get_libdir)/*.la
}

pkg_postinst() {
	ewarn "The loop-aes code has been split out of USE=crypt and into USE=loop-aes."
	ewarn "If you need support for it, make sure to update your USE accordingly."
}