# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/pdfjam/pdfjam-1.21.ebuild,v 1.1 2009/01/20 07:52:13 aballier Exp $

DESCRIPTION="pdfnup, pdfjoin and pdf90"
HOMEPAGE="http://www.warwick.ac.uk/go/pdfjam"
SRC_URI="http://www.warwick.ac.uk/go/pdfjam/${P/-/_}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""
S=${WORKDIR}/${PN}

DEPEND="virtual/latex-base"
RDEPEND="${DEPEND}"

## grobian: do we still need to prefix this stuff?
#src_compile() {
#	for i in pdf90 pdfjoin pdfnup; do
#		cp scripts/$i scripts/$i.orig
#		sed -e 's,^pdflatex="/usr/local/bin/pdflatex",pdflatex="'"${EPREFIX}"'/usr/bin/pdflatex",' \
#			-e '1c\#!/usr/bin/env sh' \
#			-e 's:for d in /etc /usr/share/etc /usr/local/share /usr/local/etc:for d in "'"${EPREFIX}"'"/etc:' \
#			scripts/$i.orig > scripts/$i
#	done
#}

src_install() {
	dobin scripts/pdf90 scripts/pdfjoin scripts/pdfnup || die
	dodoc PDFjam-README.html || die
	doman man1/pdf90.1 man1/pdfjoin.1 man1/pdfnup.1 || die
}
