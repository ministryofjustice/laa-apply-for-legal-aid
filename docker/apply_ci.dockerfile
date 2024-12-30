FROM cimg/ruby:3.4.1-browsers
LABEL org.opencontainers.image.authors="apply for legal aid team"

RUN wget https://mirrors.kernel.org/ubuntu/pool/main/libf/libffi/libffi6_3.2.1-8_amd64.deb -O /tmp/libffi6_3.2.1-8_amd64.deb
RUN sudo apt-get update
RUN sudo apt install --no-install-recommends /tmp/libffi6_3.2.1-8_amd64.deb
RUN sudo apt-get install -y --no-install-recommends \
                            postgresql-client \
                            clamav-daemon \
                            clamav \
                            clamdscan
