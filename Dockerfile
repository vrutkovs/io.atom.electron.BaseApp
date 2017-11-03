# Container to test Flatpak builds
FROM fedora:26

MAINTAINER vrutkovs@redhat.com

# Install Flatpak and dependencies
RUN dnf install flatpak flatpak-builder wget git bzip2 elfutils make ostree -y && \
    dnf clean all
