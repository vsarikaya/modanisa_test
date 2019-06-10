FROM alpine
RUN apk update
RUN apk upgrade
RUN apk add gcc make g++ zlib-dev libffi-dev openssl-dev openssh-keygen groff
RUN apk add bash curl git python py2-pip 
RUN git clone https://github.com/aws/aws-elastic-beanstalk-cli-setup.git
RUN ./aws-elastic-beanstalk-cli-setup/scripts/bundled_installer
COPY . /var/www/site/