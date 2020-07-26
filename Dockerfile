FROM kong:2.0.3

# Set timezone.
USER root
RUN apk add --update tzdata
RUN cp /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
RUN echo "Asia/Kolkata" >  /etc/timezone

# Copies plugins dir and conf file.
RUN mkdir -p /usr/local/kong/kong-plugins
WORKDIR /usr/local/kong/kong-plugins
ADD kong-plugins /usr/local/kong/kong-plugins
ADD kong.conf /etc/kong/kong.conf
