#!/bin/bash
# CREALIB FORMAT Ver. 1.0
# Autor: Charlie Martínez <cmartinez@crealib.net>
# Licencia: GPLv2 https://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
# Detecta discos HDD conectados vía USB y permite formatearlos a bajo nivel

# ---------- DETECCIÓN DE IDIOMA ----------

SYS_LANG="${LANG:-$LC_ALL}"

if [[ "$SYS_LANG" == es* || "$SYS_LANG" == ES* ]]; then
  LANGMODE="ES"
else
  LANGMODE="EN"
fi

if [[ "$LANGMODE" == "ES" ]]; then
  MSG_DEP_TITLE="Dependencia requerida"
  MSG_DEP_TEXT="Se requiere instalar la dependencia:\n\n  dialog\n\n¿Deseas instalarla ahora?"
  MSG_NO_DEP="No se puede ejecutar el programa sin la dependencia dialog."
  MSG_NO_NET="No hay conexión a internet.\nNo se puede instalar la dependencia requerida."
  MSG_NO_USB="No se detectaron discos HDD conectados por USB."
  MSG_MENU_TITLE="CREALIB FORMAT"
  MSG_MENU_TEXT="Seleccione el HDD USB a formatear:"
  MSG_CONFIRM="¿CONFIRMAS el BORRADO TOTAL de:\n\n%s\n\nESTA ACCIÓN ES IRREVERSIBLE?"
  MSG_WORKING="Formateando..."
  MSG_DONE="BORRADO COMPLETO FINALIZADO:\n\n%s"
else
  MSG_DEP_TITLE="Required dependency"
  MSG_DEP_TEXT="The following dependency is required:\n\n  dialog\n\nDo you want to install it now?"
  MSG_NO_DEP="The program cannot run without the dialog dependency."
  MSG_NO_NET="No internet connection.\nCannot install required dependency."
  MSG_NO_USB="No USB connected HDD detected."
  MSG_MENU_TITLE="CREALIB FORMAT v1.0"
  MSG_MENU_TEXT="Select the USB HDD to format:"
  MSG_CONFIRM="DO YOU CONFIRM TOTAL ERASE OF:\n\n%s\n\nTHIS ACTION IS IRREVERSIBLE?"
  MSG_WORKING="Formatting..."
  MSG_DONE="FULL ERASE COMPLETED:\n\n%s"
fi

# ---------- FUNCIONES ----------

check_internet() {
  ping -c 1 -W 2 8.8.8.8 &>/dev/null
}

install_dialog() {
  if command -v apt &>/dev/null; then
    sudo apt update && sudo apt install -y dialog
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y dialog
  elif command -v pacman &>/dev/null; then
    sudo pacman -Sy --noconfirm dialog
  elif command -v zypper &>/dev/null; then
    sudo zypper install -y dialog
  else
    echo "ERROR: Package manager not supported."
    exit 1
  fi
}

# ---------- VERIFICACIÓN DE DIALOG ----------

if ! command -v dialog &>/dev/null; then

  if ! check_internet; then
    echo -e "$MSG_NO_NET"
    exit 1
  fi

  dialog --title "$MSG_DEP_TITLE" \
         --backtitle "CREALIB FORMAT v1.0 - By Charlie Martinez®, GPLv" \
         --yesno "$MSG_DEP_TEXT" 10 55

  RESP=$?
  clear

  if [[ $RESP -ne 0 ]]; then
    dialog --msgbox "$MSG_NO_DEP" 8 60
    clear
    exit 1
  fi

  install_dialog

  if ! command -v dialog &>/dev/null; then
    echo "ERROR: dialog installation failed."
    exit 1
  fi
fi

# ---------- DETECCIÓN DE DISCOS USB REALES (tamaño > 0) ----------

mapfile -t DISKS < <(
  lsblk -ndo NAME,TRAN,TYPE,SIZE | \
  awk '$2=="usb" && $3=="disk" && $4 != "0B" {print "/dev/"$1" "$4}'
)

if [[ ${#DISKS[@]} -eq 0 ]]; then
  dialog --backtitle "CREALIB FORMAT v1.0" \
         --msgbox "$MSG_NO_USB" 7 60
  clear
  exit 1
fi

# ---------- MENÚ DE SELECCIÓN ----------

MENU_ITEMS=()
for DISK in "${DISKS[@]}"; do
  DEV=$(echo "$DISK" | awk '{print $1}')
  SIZE=$(echo "$DISK" | awk '{print $2}')
  MODEL=$(udevadm info --query=property --name="$DEV" | grep -E '^ID_MODEL=' | cut -d= -f2)
  MENU_ITEMS+=("$DEV" "$SIZE${MODEL:+ — $MODEL}")
done

DISK_SELECTED=$(dialog \
  --backtitle "CREALIB FORMAT v1.0" \
  --title "$MSG_MENU_TITLE" \
  --menu "$MSG_MENU_TEXT" 16 70 8 \
  "${MENU_ITEMS[@]}" \
  3>&1 1>&2 2>&3
)

clear
[[ -z "$DISK_SELECTED" ]] && exit 0

# ---------- CONFIRMACIÓN FINAL ----------

CONFIRM_MSG=$(printf "$MSG_CONFIRM" "$DISK_SELECTED")

dialog --backtitle "CREALIB FORMAT v1.0" \
       --yesno "$CONFIRM_MSG" 12 70
RESP=$?

clear
[[ $RESP -ne 0 ]] && exit 0

# ---------- BORRADO ----------

(
  sudo dd if=/dev/zero of="$DISK_SELECTED" bs=4M status=progress conv=fsync
) | dialog --backtitle "CREALIB FORMAT v1.0" \
           --title "$MSG_WORKING" \
           --programbox 16 85

sync

DONE_MSG=$(printf "$MSG_DONE" "$DISK_SELECTED")
dialog --backtitle "CREALIB FORMAT v1.0" \
       --msgbox "$DONE_MSG" 8 55
clear
