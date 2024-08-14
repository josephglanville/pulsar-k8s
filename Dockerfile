FROM apachepulsar/pulsar:3.3.1

USER 0
RUN apk add --no-cache openssl
RUN chown pulsar:root -R /pulsar
USER 10000
