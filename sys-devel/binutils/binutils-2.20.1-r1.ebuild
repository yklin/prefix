# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils/binutils-2.20.1-r1.ebuild,v 1.11 2010/08/30 04:16:59 vapier Exp $

PATCHVER="1.1"
ELF2FLT_VER=""
inherit toolchain-binutils

KEYWORDS="~x86-freebsd ~hppa-hpux ~ia64-hpux ~amd64-linux ~ia64-linux ~x86-linux ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

src_compile() {
	if has noinfo "${FEATURES}" \
	|| ! type -p makeinfo >/dev/null
	then
		# binutils >= 2.17 (accidentally?) requires 'makeinfo'
		export EXTRA_EMAKE="MAKEINFO=true"
	fi

	toolchain-binutils_src_compile
}

src_install() {
	toolchain-binutils_src_install

	case "${CTARGET}" in
	*-hpux*)
		ln -s /usr/ccs/bin/ld "${ED}${BINPATH}"/ld || die "Cannot create ld symlink"
		;;
	esac
}
