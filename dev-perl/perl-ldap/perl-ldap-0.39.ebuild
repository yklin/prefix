# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/perl-ldap/perl-ldap-0.39.ebuild,v 1.3 2009/04/05 12:54:08 maekke Exp $

EAPI="prefix"

MODULE_AUTHOR=GBARR
inherit perl-module

DESCRIPTION="A collection of perl modules which provide an object-oriented interface to LDAP servers."

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
#KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sparc ~x86"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE="sasl xml ssl"

DEPEND="dev-perl/Convert-ASN1
	dev-perl/URI
	sasl? ( virtual/perl-Digest-MD5 dev-perl/Authen-SASL )
	xml? ( dev-perl/XML-Parser
			dev-perl/XML-SAX
			dev-perl/XML-SAX-Writer )
	ssl? ( >=dev-perl/IO-Socket-SSL-0.81 )
	dev-lang/perl"
