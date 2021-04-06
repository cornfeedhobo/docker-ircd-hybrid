FROM ubuntu:latest

RUN set -ex \
	&& apt-get -y update \
	&& apt-get -y install gosu tini \
	&& apt-get -y install ircd-hybrid

RUN set -ex \
	&& mkdir /var/run/ircd \
	touch /var/cache/ircd-hybrid/links.txt \
	&& chown irc:irc /var/run/ircd /var/cache/ircd-hybrid /var/cache/ircd-hybrid/links.txt \
	&& rm -rf /etc/ircd-hybrid/*

COPY ircd-hybrid /etc/ircd-hybrid

RUN set -ex \
	&& chown -R root:irc /etc/ircd-hybrid \
	&& chmod 750 /etc/ircd-hybrid/key \
	&& find /etc/ircd-hybrid -type f -exec chmod 640 {} \;

USER irc:irc

EXPOSE 6665 6666 6667 6668 6669 6697

CMD ["/usr/sbin/ircd-hybrid", "-foreground"]
