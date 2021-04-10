FROM alpine:latest

ENV IRCD_HYBRID_VERSION="8.2.38"

RUN apk add --no-cache \
	bash \
	bash-completion \
	ca-certificates \
	curl \
	libgcc \
	libstdc++ \
	libssl1.1 \
	libcrypto1.1 \
	gcc \
	libc-dev \
	make \
	openssl-dev \
	su-exec \
	tar

# Simple conveniences for debugging
RUN set -ex \
	&& echo "alias ll='ls -lAh'" > /etc/profile.d/aliases.sh \
	&& echo "source /etc/profile" > /root/.profile \
	&& echo "source ~/.profile" > /root/.bashrc

RUN adduser -D -s /sbin/nologin ircd ircd
WORKDIR /home/ircd

# build & install
RUN set -ex \
	&& curl -sL "https://github.com/ircd-hybrid/ircd-hybrid/archive/${IRCD_HYBRID_VERSION}.tar.gz" | tar xzf - \
	&& cd "ircd-hybrid-${IRCD_HYBRID_VERSION}" \
		&& { ./configure --prefix /home/ircd/ ; cat config.log ; } \
		&& make \
		&& make install \
	&& cd /home/ircd \
	&& rm -rf "ircd-hybrid-${IRCD_HYBRID_VERSION}" \
	&& chown -R ircd:ircd *

RUN apk del --no-cache \
	gcc \
	libc-dev \
	openssl-dev \
	make

EXPOSE 6665 6666 6667 6668 6669
CMD ["su-exec", "ircd:ircd", "/home/ircd/bin/ircd", "-foreground"]
