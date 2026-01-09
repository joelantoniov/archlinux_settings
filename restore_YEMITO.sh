#!/bin/bash

# --- DEFINICIÓN DE RUTAS ---
# Identifica tu USB con 'lsblk'. 
# ASUMIREMOS QUE ES /dev/sdb PARA ESTE SCRIPT. ¡VERIFÍCALO!
USB_DEV="/dev/sdb"
BACKUP_SOURCE="/run/media/joelantonio/TOSHIBA EXT/Yemito"
MOUNT_POINT="/mnt/yemito_recovery"

echo "Iniciando restauración de la USB YEMITO..."

# 1. Limpieza total de la tabla de particiones de Arch
sudo wipefs -a $USB_DEV

# 2. Creación de nueva tabla de particiones (tipo DOS/MBR para máxima compatibilidad con Windows)
echo "Creando tabla de particiones compatible con Windows..."
sudo parted $USB_DEV mklabel msdos
sudo parted -a optimal $USB_DEV mkpart primary fat32 0% 100%

# 3. Formateo (Usaremos FAT32 por ser el estándar más seguro para Windows)
echo "Formateando como FAT32..."
sudo mkfs.vfat -F 32 -n "YEMITO" "${USB_DEV}1"

# 4. Montaje para copia de datos
sudo mkdir -p $MOUNT_POINT
sudo mount "${USB_DEV}1" $MOUNT_POINT

# 5. Restauración de archivos
echo "Copiando archivos de vuelta desde el disco externo..."
if [ -d "$BACKUP_SOURCE" ]; then
    # Usamos cp -a para preservar todo perfectamente
    sudo cp -a "$BACKUP_SOURCE"/. $MOUNT_POINT/
    sync # Forzamos la escritura física en el hardware
    echo "Datos restaurados exitosamente."
else
    echo "ERROR: No se encontró la carpeta de respaldo en $BACKUP_SOURCE"
fi

# 6. Limpieza final
sudo umount $MOUNT_POINT
sudo rm -rf $MOUNT_POINT

echo "Proceso finalizado. La USB está como nueva para tu hermano."
