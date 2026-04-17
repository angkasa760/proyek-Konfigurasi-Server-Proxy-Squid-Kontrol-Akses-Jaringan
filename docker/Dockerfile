FROM centos:7

LABEL maintainer="angkasa760"
LABEL description="Squid Proxy Server Container - Lab Environment"
LABEL version="1.1"

# Install Squid dan dependencies
RUN yum update -y -q && \
    yum install -y squid openssl && \
    yum clean all && \
    rm -rf /var/cache/yum

# Buat direktori yang diperlukan
RUN mkdir -p /etc/squid/ssl_cert \
             /var/spool/squid \
             /var/log/squid

# Copy konfigurasi dari repo
COPY configs/squid/squid.conf /etc/squid/squid.conf
COPY configs/squid/blocked_sites.txt /etc/squid/blocked_sites.txt
COPY configs/squid/whitelist.txt /etc/squid/whitelist.txt

# Set permission
RUN chown -R squid:squid /var/spool/squid /var/log/squid /etc/squid && \
    chmod 755 /var/spool/squid

# Inisialisasi cache Squid
RUN squid -z --foreground 2>/dev/null || true

# Expose port proxy
EXPOSE 3128
EXPOSE 3129

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD squid -k check || exit 1

# Jalankan Squid di foreground
CMD ["squid", "-N", "-d", "1"]
