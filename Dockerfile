FROM python:3.12-slim-bookworm

# Evitar prompts y configurar locale
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8

# Dependencias de sistema para Odoo 19 Enterprise
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    dirmngr \
    fonts-noto-cjk \
    gnupg \
    libssl-dev \
    node-less \
    npm \
    python3-magic \
    xz-utils \
    libxml2-dev \
    libxslt1-dev \
    libldap2-dev \
    libsasl2-dev \
    libpq-dev \
    libjpeg-dev \
    libwebp-dev \
    libpng-dev \
    libfreetype6-dev \
    build-essential \
    git \
    libxrender1 \
    xfonts-75dpi \
    xfonts-base \
    # wkhtmltopdf para Odoo 19
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_amd64.deb \
    && apt-get install -y ./wkhtmltox.deb \
    && rm wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/*

# Instalación de dependencias globales de Odoo 19
RUN npm install -g rtlcss

# Crear usuario y directorios
RUN useradd -m -U -r -d /opt/odoo -s /bin/bash odoo
WORKDIR /opt/odoo

# Copiar requerimientos e instalar (cacheado)
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir gevent  # Necesario para Workers en producción

# Copiar el código fuente del repo
COPY . .

# Configurar permisos
RUN mkdir -p /var/lib/odoo /etc/odoo /var/log/odoo && \
    chown -R odoo:odoo /opt/odoo /var/lib/odoo /etc/odoo /var/log/odoo

# Copiar archivo de configuración
COPY ./odoo.conf /etc/odoo/odoo.conf
RUN chown odoo:odoo /etc/odoo/odoo.conf

USER odoo
ENV ODOO_RC /etc/odoo/odoo.conf

EXPOSE 8069 8072

ENTRYPOINT ["/opt/odoo/odoo-bin"]
CMD ["-c", "/etc/odoo/odoo.conf"]
