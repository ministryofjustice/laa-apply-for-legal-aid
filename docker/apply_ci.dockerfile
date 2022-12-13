FROM cimg/ruby:3.1.2-browsers
MAINTAINER apply for legal aid team

RUN wget http://mirrors.kernel.org/ubuntu/pool/main/libf/libffi/libffi6_3.2.1-8_amd64.deb -O /tmp/libffi6_3.2.1-8_amd64.deb
RUN sudo apt-get update
RUN sudo apt install /tmp/libffi6_3.2.1-8_amd64.deb
RUN sudo apt-get install -y postgresql-client \
                            clamav-daemon \
                            git-crypt
