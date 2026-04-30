FROM python:3.12-slim-bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl dirmngr fonts-noto-cjk gnupg libssl-dev \
    node-less npm xz-utils libxml2-dev libxslt1-dev libldap2-dev \
    libsasl2-dev libpq-dev libjpeg-dev libwebp-dev libpng-dev \
    libfreetype6-dev build-essential git libxrender1 xfonts-75dpi \
    xfonts-base libasound2 \
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_amd64.deb \
    && apt-get install -y ./wkhtmltox.deb \
    && rm wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g rtlcss

RUN useradd -m -U -r -d /opt/odoo -s /bin/bash odoo
WORKDIR /opt/odoo

# --- CAMBIO CLAVE AQUÍ ---
# Copiamos el archivo desde la carpeta odoo/ que es donde está en ese repo
COPY odoo/requirements.txt ./requirements.txt

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir gevent

# Copiar el resto del código
COPY . .

RUN mkdir -p /var/lib/odoo /etc/odoo /var/log/odoo && \
    chown -R odoo:odoo /opt/odoo /var/lib/odoo /etc/odoo /var/log/odoo

# Si no tienes el archivo odoo.conf en el repo, el siguiente paso fallará. 
# Asegúrate de crearlo o usar parámetros por comandos.
COPY odoo.conf /etc/odoo/odoo.conf
RUN chown odoo:odoo /etc/odoo/odoo.conf

USER odoo
ENV ODOO_RC=/etc/odoo/odoo.conf

EXPOSE 8069 8072

ENTRYPOINT ["/opt/odoo/odoo-bin"]
CMD ["-c", "/etc/odoo/odoo.conf"]
