ARG  MYSQL_VER=8.4.4
FROM mysql:${MYSQL_VER}

LABEL maintainerName="Lars B. Rollik" \
      maintainerEmail="L.B.Rollik@protonmail.com" \

RUN \
    mkdir /mysql_keys && \
    chown mysql:mysql /mysql_keys

USER mysql
RUN \
    cd /mysql_keys;\
    # Create a stronger CA certificate (with RSA 4096-bit key)
    openssl genrsa 4096 > ca-key.pem;\
    openssl req -subj '/CN=CA/O=MySQL/C=US' -new -x509 -nodes -days 3650 -key ca-key.pem -out ca.pem;\
    # Create server certificate with ECC (P-256)
    openssl ecparam -name prime256v1 -genkey -noout -out server-key.pem;\
    openssl req -new -key server-key.pem -out server-req.pem -subj '/CN=SV/O=MySQL/C=US';\
    openssl x509 -req -in server-req.pem -CA ca.pem -CAkey ca-key.pem -set_serial 01 -out server-cert.pem -days 3650 -sha256;\
    # Create client certificate with ECC (P-256)
    openssl ecparam -name prime256v1 -genkey -noout -out client-key.pem;\
    openssl req -new -key client-key.pem -out client-req.pem -subj '/CN=CL/O=MySQL/C=US';\
    openssl x509 -req -in client-req.pem -CA ca.pem -CAkey ca-key.pem -set_serial 01 -out client-cert.pem -days 3650 -sha256;\

    # Create CA certificate
#    openssl genrsa 2048 > ca-key.pem;\
#    openssl req -subj '/CN=CA/O=MySQL/C=US' -new -x509 -nodes -days 3600 \
#            -key ca-key.pem -out ca.pem;\
    # Create server certificate, remove passphrase, and sign it
    # server-cert.pem = public key, server-key.pem = private key
#    openssl req -subj '/CN=SV/O=MySQL/C=US' -newkey rsa:2048 -days 3600 \
#            -nodes -keyout server-key.pem -out server-req.pem;\
#    openssl rsa -in server-key.pem -out server-key.pem;\
#    openssl x509 -req -in server-req.pem -days 3600 \
#            -CA ca.pem -CAkey ca-key.pem -set_serial 01 -out server-cert.pem;\
    # Create client certificate, remove passphrase, and sign it
    # client-cert.pem = public key, client-key.pem = private key
#    openssl req -subj '/CN=CL/O=MySQL/C=US' -newkey rsa:2048 -days 3600 \
#            -nodes -keyout client-key.pem -out client-req.pem;\
#    openssl rsa -in client-key.pem -out client-key.pem;\
#    openssl x509 -req -in client-req.pem -days 3600 \
#            -CA ca.pem -CAkey ca-key.pem -set_serial 01 -out client-cert.pem

USER root   

ADD ./config/entrypoint-monitor-config.sh entrypoint-monitor-config.sh
COPY --chown=mysql:mysql ./config/my.cnf /etc/mysql/my.cnf
RUN chmod g+w /etc/mysql/my.cnf
ENTRYPOINT ["/entrypoint-monitor-config.sh"]
CMD ["mysqld"]
HEALTHCHECK       \
    --timeout=30s \
    --retries=5  \
    --interval=15s \
    CMD           \
        mysql --protocol TCP -u"root" -p"$MYSQL_ROOT_PASSWORD" -e "SELECT 1;"

ENV DB_CONFIG_AUTO_RELOAD FALSE
