ARG PYTHON_VERSION=3.13-slim
FROM python:${PYTHON_VERSION} AS pyspf-milter-build

ARG DEBIAN_FRONTEND=noninteractive
ARG SPF_ENGINE_VERSION=3.1.0
ARG DEPENDENCIES="py3dns pymilter"

RUN set -eux; \
    apt-get update; \
    apt-get install --yes --no-install-recommends gcc build-essential libmilter-dev; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    pip install --no-cache-dir --root-user-action=ignore spf-engine==${SPF_ENGINE_VERSION} ${DEPENDENCIES}

FROM python:${PYTHON_VERSION} AS pyspf-milter

ARG DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    apt-get update; \
    apt-get install --yes --no-install-recommends libmilter1.0.1; \
    rm -rf /var/lib/apt/lists/*

COPY --from=pyspf-milter-build /usr/local /usr/local
COPY pyspf-milter.conf /usr/local/etc/pyspf-milter.conf

ARG PYSPF_MILTER_UID=1000

RUN set -eux; \
    useradd -u ${PYSPF_MILTER_UID} -g 0 -d /run/pyspf-milter pyspf-milter; \
    mkdir -p /run/pyspf-milter; \
    chown pyspf-milter:root /run/pyspf-milter; \
    chmod g=u /run/pyspf-milter

USER pyspf-milter

EXPOSE 8893

CMD [ "/usr/local/bin/pyspf-milter", "/usr/local/etc/pyspf-milter.conf" ]
