FROM alpine:3.17.2
LABEL maintaner="Igor Cherniienko https://github.com/chernienkoii"
# Install postfix and supervisor
RUN true && \
    apk add --no-cache --upgrade cyrus-sasl cyrus-sasl-login && \
    apk add --no-cache postfix \
    rsyslog \
	libsasl \
	ca-certificates \
    supervisor \
    opendkim \
    musl \
    musl-utils \
    opendkim-utils && \
    /usr/bin/newaliases

# Copy files into container
COPY . /
RUN chmod +x /opendkim.sh && \
    mkdir -p /etc/opendkim/keys && \
    mkdir -p /run/opendkim
# SMTP port
EXPOSE 25

ENTRYPOINT [ "/entrypoint.sh" ]
