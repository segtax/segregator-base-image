FROM amazoncorretto:21.0.8-al2023

LABEL org.opencontainers.image.title="segregator-base-image" \
      org.opencontainers.image.description="Shared base for CI and production: Corretto 21 + LaTeX" \
      org.opencontainers.image.source="https://github.com/segtax/segregator-base-image"

RUN dnf install -y \
    --setopt=metadata_expire=86400 \
    --setopt=fastestmirror=true \
    --setopt=max_parallel_downloads=10 \
    findutils \
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
    && dnf clean all \
    && rm -rf /var/cache/dnf \
    && kpsewhich fontspec.sty >/dev/null \
    && kpsewhich tcolorbox.sty >/dev/null \
    && kpsewhich extarticle.cls >/dev/null \
    && kpsewhich fontawesome5.sty >/dev/null \
    && kpsewhich tikz.sty >/dev/null \
    && kpsewhich microtype.sty >/dev/null \
    && kpsewhich everysel.sty >/dev/null \
    && kpsewhich lastpage.sty >/dev/null

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
