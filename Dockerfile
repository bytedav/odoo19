FROM python:3.12-slim-bookworm

# Evitar prompts de frontend
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias de sistema críticas para Odoo 19
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
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.bullseye_amd64.deb \
    && apt-get install -y ./wkhtmltox.deb \
    && rm wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/*

# Crear usuario de sistema para Odoo
RUN useradd -m -U -r -d /opt/odoo -s /bin/bash odoo

# Configurar directorio de trabajo
WORKDIR /opt/odoo

# Copiar el código del repositorio bytedav-ltd/odoo19
COPY . .

# Instalar requerimientos de Python (específicos de Odoo 19)
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Crear directorios para datos y logs con permisos correctos
RUN mkdir -p /var/lib/odoo /etc/odoo /var/log/odoo && \
    chown -R odoo:odoo /opt/odoo /var/lib/odoo /etc/odoo /var/log/odoo

# Copiar configuración (archivo que crearemos abajo)
COPY ./odoo.conf /etc/odoo/odoo.conf
RUN chown odoo:odoo /etc/odoo/odoo.conf

USER odoo

# Exponer el puerto de Odoo
EXPOSE 8069 8072

ENTRYPOINT ["/opt/odoo/odoo-bin"]
CMD ["-c", "/etc/odoo/odoo.conf"]
