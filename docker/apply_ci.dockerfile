FROM cimg/ruby:3.4.7-browsers
LABEL org.opencontainers.image.authors="apply for legal aid team"

LABEL org.opencontainers.image.vendor="Ministry of Justice" \
      org.opencontainers.image.authors="Apply for civil legal aid team (apply-for-civil-legal-aid@justice.gov.uk)" \
      org.opencontainers.image.title="Apply for civil legal aid - CI image" \
      org.opencontainers.image.description="Minimal apply for civl legal aid image used as test executor in CI pipeline" \
      org.opencontainers.image.url="https://github.com/ministryofjustice/laa-apply-for-legal-aid"

RUN wget https://mirrors.kernel.org/ubuntu/pool/main/libf/libffi/libffi6_3.2.1-8_amd64.deb -O /tmp/libffi6_3.2.1-8_amd64.deb
RUN sudo apt-get update
RUN sudo apt install --no-install-recommends /tmp/libffi6_3.2.1-8_amd64.deb
RUN sudo apt-get install -y --no-install-recommends \
                            postgresql18-client \
                            clamav-daemon \
                            clamav \
                            clamdscan
