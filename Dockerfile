FROM amazoncorretto:25.0.4-al2023

LABEL org.opencontainers.image.title="segregator-base-image" \
      org.opencontainers.image.description="Shared base for CI and production: Corretto 25 + Typst" \
      org.opencontainers.image.source="https://github.com/segtax/segregator-base-image"

ARG TYPST_VERSION=0.15.1

RUN java -XshowSettings:properties -version 2>&1 \
    | grep -q "java.specification.version = 25"

RUN dnf install -y \
    --setopt=metadata_expire=86400 \
    --setopt=fastestmirror=true \
    --setopt=max_parallel_downloads=10 \
    findutils \
    tar \
    xz \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# Typst's release binary is static, so one pinned download supports both CI and production.
RUN case "$(uname -m)" in \
      x86_64) TYPST_ARCH=x86_64; TYPST_SHA256=a6d077d0a95eed5a2eba715b2dae06be954f624ccbf85758a03f389ded33118c ;; \
      aarch64|arm64) TYPST_ARCH=aarch64; TYPST_SHA256=5aa8d74a3d906e60ea12a66ac2f37f8eef1b14cbad7182a745e393a10c23dcee ;; \
      *) echo "unsupported Typst architecture: $(uname -m)" >&2; exit 1 ;; \
    esac \
    && curl -fsSL \
       "https://github.com/typst/typst/releases/download/v${TYPST_VERSION}/typst-${TYPST_ARCH}-unknown-linux-musl.tar.xz" \
       -o /tmp/typst.tar.xz \
    && echo "${TYPST_SHA256}  /tmp/typst.tar.xz" | sha256sum -c - \
    && tar -xJf /tmp/typst.tar.xz -C /tmp \
    && install -m 0755 "/tmp/typst-${TYPST_ARCH}-unknown-linux-musl/typst" /usr/local/bin/typst \
    && typst --version | grep -q "^typst ${TYPST_VERSION}" \
    && rm -rf /tmp/typst.tar.xz "/tmp/typst-${TYPST_ARCH}-unknown-linux-musl"
