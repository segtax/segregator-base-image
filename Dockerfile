FROM amazoncorretto:21.0.8-al2023

LABEL org.opencontainers.image.title="segregator-base-image" \
      org.opencontainers.image.description="Shared base for CI and production: Corretto 21 + LaTeX + Typst" \
      org.opencontainers.image.source="https://github.com/segtax/segregator-base-image"

ARG TYPST_VERSION=0.15.1

RUN dnf install -y \
    --setopt=metadata_expire=86400 \
    --setopt=fastestmirror=true \
    --setopt=max_parallel_downloads=10 \
    findutils \
    tar \
    texlive-scheme-basic \
    texlive-tools \
    texlive-colortbl \
    texlive-xcolor \
    texlive-tcolorbox \
    texlive-geometry \
    texlive-parskip \
    texlive-booktabs \
    texlive-multirow \
    texlive-graphics \
    texlive-xetex \
    texlive-fontspec \
    texlive-eso-pic \
    texlive-extsizes \
    texlive-enumitem \
    texlive-titlesec \
    texlive-fontawesome5 \
    texlive-pgf \
    texlive-ninecolors \
    texlive-microtype \
    texlive-everysel \
    texlive-lastpage \
    texlive-pdflscape \
    xz \
    && dnf clean all \
    && rm -rf /var/cache/dnf \
    && kpsewhich fontspec.sty >/dev/null \
    && kpsewhich tcolorbox.sty >/dev/null \
    && kpsewhich extarticle.cls >/dev/null \
    && kpsewhich fontawesome5.sty >/dev/null \
    && kpsewhich tikz.sty >/dev/null \
    && kpsewhich microtype.sty >/dev/null \
    && kpsewhich everysel.sty >/dev/null \
    && kpsewhich lastpage.sty >/dev/null \
    && kpsewhich pdflscape.sty >/dev/null

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

# tabularray 2021Q from GitHub (not in AL2023 repos; latest CTAN requires LaTeX 2022+)
# Pinned to commit SHA with SHA-256 verification to prevent supply-chain tampering.
RUN TEXMFLOCAL=$(kpsewhich -var-value TEXMFLOCAL) \
    && mkdir -p "$TEXMFLOCAL/tex/latex/tabularray" \
    && curl -sfL https://raw.githubusercontent.com/lvjr/tabularray/dfc7ff1b517ea1d0fefc6f444c498417138ffd42/tabularray.sty \
       -o "$TEXMFLOCAL/tex/latex/tabularray/tabularray.sty" \
    && echo "86e7f5e76122f765dda17a6fd4ce46c94e927842f0c256953e0c8335d29686bb  $TEXMFLOCAL/tex/latex/tabularray/tabularray.sty" \
       | sha256sum -c - \
    && mktexlsr \
    && kpsewhich tabularray.sty >/dev/null
