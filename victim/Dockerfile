FROM php:7.4-cli

WORKDIR /app

RUN apt-get update && apt-get install -y sudo

RUN mkdir /run/secrets && chown root:root /run/secrets && chmod 0700 /run/secrets

COPY index.php /app/
COPY init /usr/local/bin/init

RUN chmod +x /usr/local/bin/init

ENTRYPOINT ["init"]
CMD ["php", "-S", "0.0.0.0:8080"]
