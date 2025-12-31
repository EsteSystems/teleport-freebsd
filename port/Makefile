# $FreeBSD$

PORTNAME=	teleport-tsh
PORTVERSION=	13.4.26
CATEGORIES=	security
MASTER_SITES=	https://github.com/gravitational/teleport/archive/refs/tags/
DISTNAME=	v${PORTVERSION}
DIST_SUBDIR=	teleport

MAINTAINER= daniel@este.systems	
COMMENT=	Teleport tsh CLI client for secure infrastructure access
WWW=		https://goteleport.com/

LICENSE=	AGPLv3
LICENSE_FILE=	${WRKSRC}/LICENSE

BUILD_DEPENDS=	go124>=1.24:lang/go124

USES=		pkgconfig
USE_GITHUB=	yes
GH_ACCOUNT=	gravitational
GH_PROJECT=	teleport

WRKSRC=		${WRKDIR}/teleport-${PORTVERSION}

# Optional libfido2 support for hardware MFA tokens
OPTIONS_DEFINE=	FIDO2
OPTIONS_DEFAULT=	FIDO2

FIDO2_DESC=	Hardware MFA token support (libfido2)
FIDO2_LIB_DEPENDS=	libfido2.so:security/libfido2
FIDO2_VARS=	BUILD_TAGS+=libfido2

PLIST_FILES=	bin/tsh

.include <bsd.port.options.mk>

.if ${PORT_OPTIONS:MFIDO2}
CGO_ENABLED=	1
.else
CGO_ENABLED=	1
.endif

do-build:
	@${ECHO_MSG} "===> Applying FreeBSD patches"
	@${CP} ${FILESDIR}/disk_freebsd.go ${WRKSRC}/lib/utils/
	@${CP} ${FILESDIR}/stat_freebsd.go ${WRKSRC}/lib/sshutils/scp/
	@${SED} -i '' 's|//go:build !windows|//go:build linux || darwin|' ${WRKSRC}/lib/utils/disk.go
	@${MKDIR} ${WRKSRC}/freebsd-hid-stub
	@${CP} ${FILESDIR}/hid-stub/* ${WRKSRC}/freebsd-hid-stub/
	@${ECHO} "" >> ${WRKSRC}/go.mod
	@${ECHO} "replace github.com/flynn/hid => ./freebsd-hid-stub" >> ${WRKSRC}/go.mod
.if exists(${WRKSRC}/lib/client/reexec)
	@${CP} ${FILESDIR}/reexec_freebsd.go ${WRKSRC}/lib/client/reexec/
.endif
	@${ECHO_MSG} "===> Building tsh"
	cd ${WRKSRC} && \
		${SETENV} ${MAKE_ENV} CGO_ENABLED=${CGO_ENABLED} \
		go124 build -tags "${BUILD_TAGS}" -o tsh ./tool/tsh

do-install:
	${INSTALL_PROGRAM} ${WRKSRC}/tsh ${STAGEDIR}${PREFIX}/bin/tsh

.include <bsd.port.mk>
