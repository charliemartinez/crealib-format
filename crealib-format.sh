#!/bin/bash
# ===============================================================================
# Nombre:            CREALIB FORMAT Ver. 1.3.0
# Autor:             Charlie Martinez® <cmartinez@quirinux.org>
# Licencia:          https://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
# Utilidad:          Recuperación y formateo de discos
# Distro:            Debian, Devuan y derivadas
# ===============================================================================
# Ejecutar con permisos de administrador
# ===============================================================================

LOG_FILE="/var/log/crealib-format.log"
AUTO_MODE=0

[[ "$1" == "--auto" ]] && AUTO_MODE=1

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# =========================================================
# IDIOMA
# =========================================================

SYS_LANG="${LANG:-${LC_ALL:-en_US}}"

case "$SYS_LANG" in
  es*|ES*) LANGMODE="ES" ;;
  pt*|PT*) LANGMODE="PT" ;;
  gl*|GL*) LANGMODE="GL" ;;
  fr*|FR*) LANGMODE="FR" ;;
  it*|IT*) LANGMODE="IT" ;;
  de*|DE*) LANGMODE="DE" ;;
  *)       LANGMODE="EN" ;;
esac

# =========================================================
# MENSAJES ROOT
# =========================================================

case "$LANGMODE" in
ES)
MSG_ROOT_ERROR="ERROR: Este programa debe ejecutarse como root."
MSG_ROOT_USE="Use: sudo $0"
;;
PT)
MSG_ROOT_ERROR="ERRO: Este programa deve ser executado como root."
MSG_ROOT_USE="Use: sudo $0"
;;
GL)
MSG_ROOT_ERROR="ERRO: Este programa debe executarse como root."
MSG_ROOT_USE="Use: sudo $0"
;;
FR)
MSG_ROOT_ERROR="ERREUR: Ce programme doit être exécuté en tant que root."
MSG_ROOT_USE="Utilisez : sudo $0"
;;
IT)
MSG_ROOT_ERROR="ERRORE: Questo programma deve essere eseguito come root."
MSG_ROOT_USE="Usa: sudo $0"
;;
DE)
MSG_ROOT_ERROR="FEHLER: Dieses Programm muss als Root ausgeführt werden."
MSG_ROOT_USE="Verwendung: sudo $0"
;;
*)
MSG_ROOT_ERROR="ERROR: This program must be run as root."
MSG_ROOT_USE="Use: sudo $0"
;;
esac

# =========================================================
# REQUIRIR ROOT
# =========================================================

if [[ "$EUID" -ne 0 ]]; then
  clear
  echo "$MSG_ROOT_ERROR"
  echo "$MSG_ROOT_USE"
  exit 1
fi

log "Inicio del programa"

# =========================================================
# MENSAJES GENERALES
# =========================================================

case "$LANGMODE" in
ES)
MSG_MENU_TITLE="CREALIB FORMAT"
MSG_MENU_TEXT="Seleccione el HDD USB:"
MSG_CONFIRM_ZERO="¿CONFIRMAS el BORRADO TOTAL de:\n\n%s\n\nESTA ACCIÓN ES IRREVERSIBLE?"
MSG_WORKING="Formateando..."
MSG_NO_USB="No se detectaron discos HDD por USB."
MSG_UMOUNT="Se desmontarán automáticamente las particiones activas."
MSG_SMART_BEFORE="Estado SMART ANTES:"
MSG_SMART_AFTER="Estado SMART DESPUÉS:"
MSG_BADBLOCKS="¿Intentar recuperación de sectores (badblocks)?"
MSG_BADBLOCKS_TITLE="badblocks"
MSG_GOOD="DISCO APTO PARA USO"
MSG_BAD="DISCO NO APTO"
MSG_SYS_PROTECT="ERROR: Dispositivo del sistema protegido:"
;;
*)
MSG_MENU_TITLE="CREALIB FORMAT"
MSG_MENU_TEXT="Select USB HDD:"
MSG_CONFIRM_ZERO="CONFIRM TOTAL ERASE OF:\n\n%s\n\nIRREVERSIBLE?"
MSG_WORKING="Formatting..."
MSG_NO_USB="No USB HDD detected."
MSG_UMOUNT="Active partitions will be unmounted."
MSG_SMART_BEFORE="SMART BEFORE:"
MSG_SMART_AFTER="SMART AFTER:"
MSG_BADBLOCKS="Attempt sector recovery?"
MSG_BADBLOCKS_TITLE="badblocks"
MSG_GOOD="DISK HEALTHY"
MSG_BAD="DISK FAILED"
MSG_SYS_PROTECT="ERROR: System disk protected:"
;;
esac

MSG_BACK_TITLE="CREALIB FORMAT v1.3.0 - by Charlie Martinez® GPLv2"

# =========================================================
# FUNCIONES
# =========================================================

get_smart() {
  smartctl -A "$1" | awk '
  /Reallocated_Sector_Ct/ {r=$10}
  /Current_Pending_Sector/ {p=$10}
  /Offline_Uncorrectable/ {u=$10}
  END {printf "Reallocated: %s\nPending: %s\nUncorrectable: %s\n", r,p,u}'
}

disk_ok() {
  smartctl -A "$1" | awk '
  /Pending/ {p=$10}
  /Uncorrectable/ {u=$10}
  END {p+=0; u+=0; exit (p!=0 || u!=0)}'
}

unmount_parts() {
  parts=$(lsblk -ln "$1" | awk '$7!="" {print $1}')
  if [[ -n "$parts" ]]; then
    [[ $AUTO_MODE -eq 0 ]] && dialog --backtitle "$MSG_BACK_TITLE" --msgbox "$MSG_UMOUNT" 8 60
    for p in $parts; do umount "/dev/$p" 2>/dev/null; done
  fi
}

is_system_disk() {
  ROOT_DEV=$(findmnt -n -o SOURCE / | sed 's/[0-9]*$//')
  [[ "$1" == "$ROOT_DEV" ]]
}

# =========================================================
# DETECCIÓN HDD USB
# =========================================================

mapfile -t DISKS < <(
  lsblk -ndo NAME,TRAN,TYPE,SIZE | awk '$2=="usb" && $3=="disk" && $4!="0B" {print "/dev/"$1}'
)

[[ ${#DISKS[@]} -eq 0 ]] && { echo "$MSG_NO_USB"; exit 1; }

# =========================================================
# SELECCIÓN
# =========================================================

if [[ $AUTO_MODE -eq 1 ]]; then
  DISK_SELECTED="${DISKS[0]}"
else
  MENU_ITEMS=()
  for d in "${DISKS[@]}"; do
    s=$(lsblk -ndo SIZE "$d")
    m=$(udevadm info --name="$d" | grep ID_MODEL= | cut -d= -f2)
    MENU_ITEMS+=("$d" "$s ${m:-}")
  done

  DISK_SELECTED=$(dialog --backtitle "$MSG_BACK_TITLE" \
    --title "$MSG_MENU_TITLE" \
    --menu "$MSG_MENU_TEXT" 16 70 8 \
    "${MENU_ITEMS[@]}" 3>&1 1>&2 2>&3)

  clear
fi

[[ -z "$DISK_SELECTED" ]] && exit 0

# =========================================================
# PROTECCIÓN DISCO SISTEMA
# =========================================================

if is_system_disk "$DISK_SELECTED"; then
  echo "$MSG_SYS_PROTECT $DISK_SELECTED"
  log "INTENTO DE BORRADO DE DISCO DEL SISTEMA: $DISK_SELECTED"
  exit 1
fi

log "Disco seleccionado: $DISK_SELECTED"

# =========================================================
# DESMONTAJE
# =========================================================

unmount_parts "$DISK_SELECTED"

# =========================================================
# SMART ANTES
# =========================================================

SB=$(get_smart "$DISK_SELECTED")
[[ $AUTO_MODE -eq 0 ]] && dialog --msgbox "$MSG_SMART_BEFORE\n\n$SB" 12 60
log "SMART BEFORE:\n$SB"

# =========================================================
# BADBLOCKS
# =========================================================

if [[ $AUTO_MODE -eq 0 ]]; then
  dialog --yesno "$MSG_BADBLOCKS" 10 60
  RESP=$?
else
  RESP=1
fi

if [[ $RESP -eq 0 ]]; then
  log "Ejecución badblocks"
  ( badblocks -wsv "$DISK_SELECTED" ) | \
  dialog --title "$MSG_BADBLOCKS_TITLE" --programbox 16 85
fi

# =========================================================
# CONFIRMACIÓN Y BORRADO
# =========================================================

if [[ $AUTO_MODE -eq 0 ]]; then
  CONFIRM=$(printf "$MSG_CONFIRM_ZERO" "$DISK_SELECTED")
  dialog --yesno "$CONFIRM" 12 70
  [[ $? -ne 0 ]] && exit 0
fi

log "Borrado iniciado en $DISK_SELECTED"

dd if=/dev/zero of="$DISK_SELECTED" bs=4M status=progress conv=fsync

sync
log "Borrado finalizado"

# =========================================================
# SMART DESPUÉS
# =========================================================

SA=$(get_smart "$DISK_SELECTED")
log "SMART AFTER:\n$SA"
[[ $AUTO_MODE -eq 0 ]] && dialog --msgbox "$MSG_SMART_AFTER\n\n$SA" 12 60

# =========================================================
# VEREDICTO
# =========================================================

if disk_ok "$DISK_SELECTED"; then
  log "VEREDICTO: OK"
  [[ $AUTO_MODE -eq 0 ]] && dialog --msgbox "$MSG_GOOD" 8 45
else
  log "VEREDICTO: FALLIDO"
  [[ $AUTO_MODE -eq 0 ]] && dialog --msgbox "$MSG_BAD" 8 55
fi

clear
exit 0
