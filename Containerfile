# Use official Dev Spaces base 
#FROM registry.redhat.io/devspaces/udi-rhel9:3.18-2.1741779985
FROM quay.io/devfile/universal-developer-image:ubi9-latest

USER root

# Avoid flaky mirrors, timeouts, or zchunk checksum mismatches
RUN echo "fastestmirror=True" >> /etc/dnf/dnf.conf && \
    echo "skip_if_unavailable=True" >> /etc/dnf/dnf.conf && \
    echo "zchunk=False" >> /etc/dnf/dnf.conf

# Install dependencies required by Konveyor AI + typical tools
RUN dnf clean all && \
    dnf install -y --nobest --allowerasing \
        python3.11 python3.11-devel \
        java-17-openjdk-devel \
        nodejs maven \
        unzip git curl zsh \
        gcc make glibc-devel libffi-devel openssl-devel \
    && dnf clean all

# Add Kai extension from GitHub release
RUN curl -L -o /konveyor.vsix https://github.com/konveyor/editor-extensions/releases/download/v0.2.0-pre.2-1/konveyor-v0.2.0-pre.2-1.vsix

ENV DEFAULT_EXTENSIONS=/konveyor.vsix   

USER user
