FROM alpine

COPY Makefile /usr/src/

WORKDIR /usr/src

RUN set -ex; \
	apk add --no-cache \
		build-base \
		git \
		linux-headers \
	; \
	git clone --recursive https://github.com/wangyu-/tinyfecVPN.git; \
	cd tinyfecVPN; \
	cat /usr/src/Makefile >> makefile; \
	make -j$(nproc) docker; \
	strip -s tinyvpn; \
	chmod +x tinyvpn;


FROM alpine

COPY --from=0 /usr/src/tinyfecVPN/tinyvpn /usr/local/bin/
COPY entrypoint.sh /usr/local/bin/

RUN set -ex; \
	apk add --no-cache \
		execline \
		iproute2 \
		iptables \
		libstdc++ \
	; \
	chmod +x /usr/local/bin/entrypoint.sh;

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
