FROM kong:3.4.0

# Set timezone.
USER root
RUN apt-get update
RUN ln -fs /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
RUN dpkg-reconfigure --frontend noninteractive tzdata

# Copies plugins dir and conf file.
RUN mkdir -p /usr/local/kong/kong-plugins
WORKDIR /usr/local/kong/kong-plugins
ADD kong-plugins /usr/local/kong/kong-plugins

# Install the plugins
RUN cd /usr/local/kong/kong-plugins
RUN for dir in `ls`; do if [ -d $dir ]; then cd $dir; luarocks make; cd ../; fi done
