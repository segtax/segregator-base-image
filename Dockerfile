FROM amazoncorretto:25.0.4-al2023

LABEL org.opencontainers.image.title="segregator-base-image" \
      org.opencontainers.image.description="Shared base for CI and production: Corretto Java 25" \
      org.opencontainers.image.source="https://github.com/segtax/segregator-base-image"

RUN java -XshowSettings:properties -version 2>&1 \
    | grep -q "java.specification.version = 25"

RUN dnf install -y \
    --setopt=metadata_expire=86400 \
    --setopt=fastestmirror=true \
    --setopt=max_parallel_downloads=10 \
    findutils \
    git \
    gzip \
    tar \
    && dnf clean all \
    && rm -rf /var/cache/dnf \
    && command -v git >/dev/null \
    && command -v gzip >/dev/null \
    && command -v tar >/dev/null
