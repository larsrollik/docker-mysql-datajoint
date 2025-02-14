ARG  MYSQL_VERSION=8.4.4
FROM mysql:${MYSQL_VERSION}

LABEL maintainerName="Lars B. Rollik" \
      maintainerEmail="L.B.Rollik@protonmail.com"

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
    openssl x509 -req -in client-req.pem -CA ca.pem -CAkey ca-key.pem -set_serial 01 -out client-cert.pem -days 3650 -sha256;

#RUN chown mysql:mysql /mysql_keys/* && \
#    chmod 400 /mysql_keys/server-key.pem && \
#    chmod 444 /mysql_keys/server-cert.pem /mysql_keys/ca-cert.pem

USER root

COPY --chown=mysql:mysql ./config/my.cnf /etc/mysql/my.cnf
RUN chmod g+w /etc/mysql/my.cnf

#COPY ./config/entrypoint-monitor-config.sh entrypoint-monitor-config.sh
#RUN chmod +x entrypoint-monitor-config.sh
#ENTRYPOINT ["entrypoint-monitor-config.sh"]

CMD ["mysqld"]

HEALTHCHECK       \
    --timeout=30s \
    --retries=5  \
    --interval=15s \
    CMD           \
        mysql --protocol TCP -u"root" -p"$MYSQL_ROOT_PASSWORD" -e "SELECT 1;"

#ENV DB_CONFIG_AUTO_RELOAD=FALSE
