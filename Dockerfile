FROM odoo:19.0

USER root

# Elimina el directorio de addons por defecto y créalo de nuevo
RUN rm -rf /mnt/extra-addons && mkdir -p /mnt/extra-addons

# Copia TODO tu repositorio (todos los módulos) dentro del contenedor
COPY ./ /mnt/extra-addons/

# Da permisos para que Odoo pueda leer y ejecutar los archivos
RUN chown -R odoo:odoo /mnt/extra-addons

USER odoo
