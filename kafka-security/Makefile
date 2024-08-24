# Makefile for Kafka DEV SSL/TLS setup

# Include environment variables from .env file
include .env
export

# Targets
.PHONY: all clean

all: kafka.server.keystore.p12 kafka.server.truststore.p12 kafka-ui.keystore.p12

clean:
	rm -f ca-cert ca-key *.p12 *.csr *.crt ca-cert.srl

ca-cert ca-key:
	openssl req -new -x509 -keyout ca-key -out ca-cert -days 365 -subj "/CN=ca.roadrunner.com" -nodes

kafka.server.keystore.p12: ca-cert ca-key
	keytool -keystore kafka.server.keystore.p12 -alias localhost -validity 365 -genkey -keyalg RSA -storetype PKCS12 -storepass "$(KAFKA_SSL_KEYSTORE_PASSWORD)" -keypass "$(KAFKA_SSL_KEY_PASSWORD)" -dname "CN=kafka.roadrunner.com"
	keytool -certreq -file kafka.server.csr -keystore kafka.server.keystore.p12 -alias localhost -storepass "$(KAFKA_SSL_KEYSTORE_PASSWORD)" -keypass "$(KAFKA_SSL_KEY_PASSWORD)" -storetype PKCS12
	openssl x509 -req -CA ca-cert -CAkey ca-key -in kafka.server.csr -out kafka.server.signed.crt -days 365 -CAcreateserial
	keytool -keystore kafka.server.keystore.p12 -alias CARoot -import -file ca-cert -storepass "$(KAFKA_SSL_KEYSTORE_PASSWORD)" -noprompt -storetype PKCS12
	keytool -keystore kafka.server.keystore.p12 -alias localhost -import -file kafka.server.signed.crt -storepass "$(KAFKA_SSL_KEYSTORE_PASSWORD)" -keypass "$(KAFKA_SSL_KEY_PASSWORD)" -noprompt -storetype PKCS12

kafka.server.truststore.p12: ca-cert
	keytool -keystore kafka.server.truststore.p12 -alias CARoot -import -file ca-cert -storepass "$(KAFKA_SSL_TRUSTSTORE_PASSWORD)" -noprompt -storetype PKCS12

kafka-ui.keystore.p12: ca-cert ca-key
	keytool -keystore kafka-ui.keystore.p12 -alias kafka-ui -validity 365 -genkey -keyalg RSA -storetype PKCS12 -storepass "$(KAFKA_SSL_KEYSTORE_PASSWORD)" -keypass "$(KAFKA_SSL_KEY_PASSWORD)" -dname "CN=kafka-ui"
	keytool -certreq -file kafka-ui.csr -keystore kafka-ui.keystore.p12 -alias kafka-ui -storepass "$(KAFKA_SSL_KEYSTORE_PASSWORD)" -keypass "$(KAFKA_SSL_KEY_PASSWORD)" -storetype PKCS12
	openssl x509 -req -CA ca-cert -CAkey ca-key -in kafka-ui.csr -out kafka-ui.signed.crt -days 365 -CAcreateserial
	keytool -keystore kafka-ui.keystore.p12 -alias CARoot -import -file ca-cert -storepass "$(KAFKA_SSL_KEYSTORE_PASSWORD)" -noprompt -storetype PKCS12
	keytool -keystore kafka-ui.keystore.p12 -alias kafka-ui -import -file kafka-ui.signed.crt -storepass "$(KAFKA_SSL_KEYSTORE_PASSWORD)" -keypass "$(KAFKA_SSL_KEY_PASSWORD)" -noprompt -storetype PKCS12