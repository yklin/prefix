# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/Time-HiRes/Time-HiRes-1.97.16.ebuild,v 1.1 2008/12/30 16:58:57 tove Exp $

EAPI="prefix"

inherit versionator
MODULE_AUTHOR=JHI
MY_P="${PN}-$(delete_version_separator 2)"
S=${WORKDIR}/${MY_P}
inherit perl-module

DESCRIPTION="Perl Time::HiRes. High resolution alarm, sleep, gettimeofday, interval timers"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND="dev-lang/perl"

mydoc="TODO"

SRC_TEST="do"
