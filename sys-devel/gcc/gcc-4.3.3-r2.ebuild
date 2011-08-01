# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gcc/gcc-4.3.3-r2.ebuild,v 1.11 2011/07/20 08:58:35 dirtyepic Exp $

GENTOO_PATCH_EXCLUDE="69_all_gcc43-pr39013.patch" #262567

PATCH_VER="1.2"
UCLIBC_VER="1.1"

ETYPE="gcc-compiler"

# Hardened gcc 4 stuff
PIE_VER="10.1.5"
SPECS_VER="0.9.4"

# arch/libc configurations known to be stable or untested with {PIE,SSP,FORTIFY}-by-default
PIE_GLIBC_STABLE="x86 amd64 ~ppc ~ppc64 ~arm ~sparc"
PIE_UCLIBC_STABLE="x86 arm"
#SSP_STABLE="amd64 x86 ppc ppc64 ~arm ~sparc"
#SSP_UCLIBC_STABLE=""

# whether we should split out specs files for multiple {PIE,SSP}-by-default
# and vanilla configurations.
SPLIT_SPECS=no #${SPLIT_SPECS-true} hard disable until #106690 is fixed

inherit toolchain flag-o-matic prefix

DESCRIPTION="The GNU Compiler Collection"

LICENSE="GPL-3 LGPL-3 || ( GPL-3 libgcc libstdc++ ) FDL-1.2"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND=">=sys-libs/zlib-1.1.4
	>=sys-devel/gcc-config-1.4
	virtual/libiconv
	>=dev-libs/gmp-4.2.1
	>=dev-libs/mpfr-2.3
	!build? (
		gcj? (
			gtk? (
				x11-libs/libXt
				x11-libs/libX11
				x11-libs/libXtst
				x11-proto/xproto
				x11-proto/xextproto
				=x11-libs/gtk+-2*
				x11-libs/pango
			)
			>=media-libs/libart_lgpl-2.1
			app-arch/zip
			app-arch/unzip
		)
		>=sys-libs/ncurses-5.2-r2
		nls? ( sys-devel/gettext )
	)"
DEPEND="${RDEPEND}
	test? ( sys-devel/autogen dev-util/dejagnu )
	>=sys-apps/texinfo-4.2-r4
	>=sys-devel/bison-1.875
	sys-devel/flex
	!prefix? ( elibc_glibc? ( >=sys-libs/glibc-2.8 ) )
	kernel_Darwin? ( ${CATEGORY}/binutils-apple )
	kernel_AIX? ( ${CATEGORY}/native-cctools )
	amd64? ( multilib? ( gcj? ( app-emulation/emul-linux-x86-xlibs ) ) )
	!kernel_Darwin? ( !kernel_AIX? (
		ppc? ( >=${CATEGORY}/binutils-2.17 )
		ppc64? ( >=${CATEGORY}/binutils-2.17 )
		>=${CATEGORY}/binutils-2.15.94
	) )"
PDEPEND=">=sys-devel/gcc-config-1.4"
if [[ ${CATEGORY} != cross-* ]] ; then
	PDEPEND="${PDEPEND} !prefix? ( elibc_glibc? ( >=sys-libs/glibc-2.8 ) )"
fi

src_unpack() {
	gcc_src_unpack

	# work around http://gcc.gnu.org/bugzilla/show_bug.cgi?id=33637
	epatch "${FILESDIR}"/4.3.0/targettools-checks.patch

	# http://bugs.gentoo.org/show_bug.cgi?id=201490
	epatch "${FILESDIR}"/4.2.2/gentoo-fixincludes.patch

	# http://gcc.gnu.org/bugzilla/show_bug.cgi?id=27516
	epatch "${FILESDIR}"/4.3.0/treelang-nomakeinfo.patch

	# add support for 64-bits native target on Solaris
	epatch "${FILESDIR}"/4.3.3/solarisx86_64.patch

	# make sure 64-bits native targets don't screw up the linker paths
	epatch "${FILESDIR}"/solaris-searchpath.patch
	epatch "${FILESDIR}"/no-libs-for-startfile.patch
	# replace nasty multilib dirs like ../lib64 that occur on --disable-multilib
	if use prefix; then
		epatch "${FILESDIR}"/4.3.3/prefix-search-dirs.patch
		eprefixify "${S}"/gcc/gcc.c
	fi

	# gcc sources are polluted with old stuff for interix 3.5 not needed here
	epatch "${FILESDIR}"/4.2.2/interix-3.5-x86.patch

	# make it have correct install_names on Darwin
	epatch "${FILESDIR}"/4.3.3/darwin-libgcc_s-installname.patch
	# and that it compiles as well, bug #318283
	epatch "${FILESDIR}"/4.3.3/gcc-4.3.3-redundant-linkage.patch

	if [[ ${CHOST} == *-mint* ]] ; then
		epatch "${FILESDIR}"/4.3.2/${PN}-4.3.2-mint1.patch
		epatch "${FILESDIR}"/4.3.2/${PN}-4.3.2-mint2.patch
		epatch "${FILESDIR}"/4.3.2/${PN}-4.3.2-mint3.patch
	fi

	# Always behave as if -pthread were passed on AIX (#266548)
	epatch "${FILESDIR}"/4.3.3/aix-force-pthread.patch

	epatch "${FILESDIR}"/gcj-4.3.1-iconvlink.patch

	epatch "${FILESDIR}"/${PN}-4.2-pa-hpux-libgcc_s-soname.patch
	epatch "${FILESDIR}"/${PN}-4.2-ia64-hpux-always-pthread.patch

	use vanilla && return 0

	sed -i 's/use_fixproto=yes/:/' gcc/config.gcc #PR33200

	[[ ${CHOST} == ${CTARGET} ]] && epatch "${FILESDIR}"/gcc-spec-env.patch

	[[ ${CTARGET} == *-softfloat-* ]] && epatch "${FILESDIR}"/4.3.2/gcc-4.3.2-softfloat.patch
}

src_compile() {
	case ${CTARGET} in
		*-solaris*)
			# todo: some magic for native vs. GNU linking?
			EXTRA_ECONF="${EXTRA_ECONF} --with-gnu-ld --with-gnu-as"
		;;
		*-aix*)
			# AIX doesn't use GNU binutils, because it doesn't produce usable
			# code
			EXTRA_ECONF="${EXTRA_ECONF} --without-gnu-ld --without-gnu-as"
			# The linker finding libs isn't enough, collect2 also has to:
			EXTRA_ECONF="${EXTRA_ECONF} --with-mpfr=${EPREFIX}/usr"
			EXTRA_ECONF="${EXTRA_ECONF} --with-gmp=${EPREFIX}/usr"
			append-ldflags -Wl,-bbigtoc,-bmaxdata:0x10000000 # bug#194635
		;;
		*-darwin7)
			# libintl triggers inclusion of -lc which results in multiply
			# defined symbols, so disable nls
			EXTRA_ECONF="${EXTRA_ECONF} --disable-nls"
		;;
	esac

	# http://gcc.gnu.org/bugzilla/show_bug.cgi?id=25127
	[[ ${CHOST} == powerpc*-darwin* ]] && filter-flags "-mcpu=*" "-mabi=*"

	# Since GCC 4.1.2 some non-posix (?) /bin/sh compatible code is used, at
	# least on Solaris, and AIX /bin/sh is ways too slow,
	# so force it to use $BASH (that portage uses) - it can't be EPREFIX
	# in case that doesn't exist yet
	export CONFIG_SHELL="${BASH}"
	gcc_src_compile
}

src_install() {
	toolchain_src_install

	case ${CTARGET} in
		*-interix*)
			# interix delivers libdl and dlfcn.h with gcc-3.3.
			# Since those parts are perfectly usable by this gcc (and
			# required for example by perl), we simply can reuse them.
			# As libdl is in /usr/lib, we only need to copy dlfcn.h.
			cp /opt/gcc.3.3/include/dlfcn.h "${ED}${INCLUDEPATH}" \
				|| die "Cannot copy /opt/gcc.3.3/include/dlfcn.h"
		;;
	esac
}

