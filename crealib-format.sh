#!/bin/bash
# CREALIB FORMAT Ver. 1.0.0
# Autor: Charlie Martínez <cmartinez@crealib.net>
# Licencia: GPLv2 https://www.gnu.org/licenses/old-licenses/gpl-2.0.txt

# =========================================================
# REQUERIR ROOT
# =========================================================

if [[ "$EUID" -ne 0 ]]; then
  clear
  echo "ERROR: This program must be run as root."
  echo "Use: sudo $0"
  exit 1
fi

# =========================================================
# IDIOMA
# =========================================================

SYS_LANG="${LANG:-$LC_ALL}"

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
# MENSAJES
# =========================================================

case "$LANGMODE" in
ES)
MSG_MENU_TITLE="CREALIB FORMAT"
MSG_MENU_TEXT="Seleccione el HDD USB:"
MSG_CONFIRM_ZERO="¿CONFIRMAS el BORRADO TOTAL de:\n\n%s\n\nESTA ACCIÓN ES IRREVERSIBLE?"
MSG_WORKING="Formateando..."
MSG_DONE="BORRADO COMPLETO FINALIZADO:\n\n%s"
MSG_NO_USB="No se detectaron discos HDD por USB."
MSG_UMOUNT="Se desmontarán automáticamente las particiones activas."
MSG_SMART_BEFORE="Estado SMART ANTES:"
MSG_SMART_AFTER="Estado SMART DESPUÉS:"
MSG_BADBLOCKS="¿Intentar recuperación de sectores (badblocks)?"
MSG_GOOD="DISCO APTO PARA USO"
MSG_BAD="DISCO NO APTO"
;;
PT)
MSG_MENU_TITLE="CREALIB FORMAT"
MSG_MENU_TEXT="Selecione o HDD USB:"
MSG_CONFIRM_ZERO="CONFIRMAR APAGAMENTO TOTAL DE:\n\n%s\n\nAÇÃO IRREVERSÍVEL?"
MSG_WORKING="Formatando..."
MSG_DONE="APAGAMENTO CONCLUÍDO:\n\n%s"
MSG_NO_USB="Nenhum HDD USB detectado."
MSG_UMOUNT="Partições ativas serão desmontadas."
MSG_SMART_BEFORE="Estado SMART ANTES:"
MSG_SMART_AFTER="Estado SMART DEPOIS:"
MSG_BADBLOCKS="Tentar recuperação de setores?"
MSG_GOOD="DISCO APTO"
MSG_BAD="DISCO DEFEITUOSO"
;;
GL)
MSG_MENU_TITLE="CREALIB FORMAT"
MSG_MENU_TEXT="Seleccione o HDD USB:"
MSG_CONFIRM_ZERO="CONFIRMA O BORRADO TOTAL DE:\n\n%s\n\nIRREVERSIBLE?"
MSG_WORKING="Formatando..."
MSG_DONE="BORRADO FINALIZADO:\n\n%s"
MSG_NO_USB="Non se detectaron discos USB."
MSG_UMOUNT="Desmontaranse particións activas."
MSG_SMART_BEFORE="Estado SMART ANTES:"
MSG_SMART_AFTER="Estado SMART DESPOIS:"
MSG_BADBLOCKS="Intentar recuperación de sectores?"
MSG_GOOD="DISCO APTO"
MSG_BAD="DISCO DEFECTUOSO"
;;
FR)
MSG_MENU_TITLE="CREALIB FORMAT"
MSG_MENU_TEXT="Sélectionnez le disque USB:"
MSG_CONFIRM_ZERO="CONFIRMER L'EFFACEMENT TOTAL DE:\n\n%s\n\nIRRÉVERSIBLE?"
MSG_WORKING="Formatage..."
MSG_DONE="EFFACEMENT TERMINÉ:\n\n%s"
MSG_NO_USB="Aucun disque USB détecté."
MSG_UMOUNT="Les partitions actives seront démontées."
MSG_SMART_BEFORE="État SMART AVANT:"
MSG_SMART_AFTER="État SMART APRÈS:"
MSG_BADBLOCKS="Tenter la récupération?"
MSG_GOOD="DISQUE UTILISABLE"
MSG_BAD="DISQUE DÉFECTUEUX"
;;
IT)
MSG_MENU_TITLE="CREALIB FORMAT"
MSG_MENU_TEXT="Seleziona HDD USB:"
MSG_CONFIRM_ZERO="CONFERMARE CANCELLAZIONE TOTALE DI:\n\n%s\n\nIRREVERSIBILE?"
MSG_WORKING="Formattazione..."
MSG_DONE="CANCELLAZIONE COMPLETATA:\n\n%s"
MSG_NO_USB="Nessun disco USB rilevato."
MSG_UMOUNT="Le partizioni verranno smontate."
MSG_SMART_BEFORE="Stato SMART PRIMA:"
MSG_SMART_AFTER="Stato SMART DOPO:"
MSG_BADBLOCKS="Tentare recupero settori?"
MSG_GOOD="DISCO IDONEO"
MSG_BAD="DISCO DIFETTOSO"
;;
DE)
MSG_MENU_TITLE="CREALIB FORMAT"
MSG_MENU_TEXT="USB-Festplatte auswählen:"
MSG_CONFIRM_ZERO="VOLLSTÄNDIGE LÖSCHUNG VON:\n\n%s\n\nBESTÄTIGEN?"
MSG_WORKING="Formatierung..."
MSG_DONE="LÖSCHUNG ABGESCHLOSSEN:\n\n%s"
MSG_NO_USB="Keine USB-Festplatte erkannt."
MSG_UMOUNT="Aktive Partitionen werden ausgehängt."
MSG_SMART_BEFORE="SMART-Status VORHER:"
MSG_SMART_AFTER="SMART-Status NACHHER:"
MSG_BADBLOCKS="Sektorwiederherstellung starten?"
MSG_GOOD="FESTPLATTE OK"
MSG_BAD="FESTPLATTE DEFEKT"
;;
*)
MSG_MENU_TITLE="CREALIB FORMAT"
MSG_MENU_TEXT="Select USB HDD:"
MSG_CONFIRM_ZERO="CONFIRM TOTAL ERASE OF:\n\n%s\n\nIRREVERSIBLE?"
MSG_WORKING="Formatting..."
MSG_DONE="ERASE COMPLETED:\n\n%s"
MSG_NO_USB="No USB HDD detected."
MSG_UMOUNT="Active partitions will be unmounted."
MSG_SMART_BEFORE="SMART BEFORE:"
MSG_SMART_AFTER="SMART AFTER:"
MSG_BADBLOCKS="Attempt sector recovery?"
MSG_GOOD="DISK HEALTHY"
MSG_BAD="DISK FAILED"
;;
esac

MSG_BACK_TITLE="CREALIB FORMAT v1.2.1 - by Charlie Martinez® GPLv2"

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
  END {exit (p!=0 || u!=0)}'
}

unmount_parts() {
  parts=$(lsblk -ln "$1" | awk '$7!="" {print $1}')
  if [[ -n "$parts" ]]; then
    dialog --backtitle "$MSG_BACK_TITLE" --msgbox "$MSG_UMOUNT" 8 60
    clear
    for p in $parts; do umount "/dev/$p" 2>/dev/null; done
  fi
}

# =========================================================
# DETECCIÓN HDD USB REAL
# =========================================================

mapfile -t DISKS < <(
  lsblk -ndo NAME,TRAN,TYPE,SIZE | awk '$2=="usb" && $3=="disk" && $4!="0B" {print "/dev/"$1}'
)

if [[ ${#DISKS[@]} -eq 0 ]]; then
  dialog --backtitle "$MSG_BACK_TITLE" --msgbox "$MSG_NO_USB" 7 60
  clear
  exit 1
fi

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
[[ -z "$DISK_SELECTED" ]] && exit 0

# =========================================================
# DESMONTAJE
# =========================================================

unmount_parts "$DISK_SELECTED"

# =========================================================
# SMART ANTES
# =========================================================

SB=$(get_smart "$DISK_SELECTED")
dialog --backtitle "$MSG_BACK_TITLE" --msgbox "$MSG_SMART_BEFORE\n\n$SB" 12 60
clear

# =========================================================
# BADBLOCKS
# =========================================================

dialog --backtitle "$MSG_BACK_TITLE" --yesno "$MSG_BADBLOCKS" 10 60
RESP=$?
clear

if [[ $RESP -eq 0 ]]; then
  ( badblocks -wsv "$DISK_SELECTED" ) | dialog --backtitle "$MSG_BACK_TITLE" --title "badblocks" --programbox 16 85
  clear
fi

# =========================================================
# CONFIRMACIÓN Y BORRADO
# =========================================================

CONFIRM=$(printf "$MSG_CONFIRM_ZERO" "$DISK_SELECTED")
dialog --backtitle "$MSG_BACK_TITLE" --yesno "$CONFIRM" 12 70
RESP=$?
clear
[[ $RESP -ne 0 ]] && exit 0

( dd if=/dev/zero of="$DISK_SELECTED" bs=4M status=progress conv=fsync ) | \
dialog --backtitle "$MSG_BACK_TITLE" --title "$MSG_WORKING" --programbox 16 85

clear
sync

# =========================================================
# SMART DESPUÉS
# =========================================================

SA=$(get_smart "$DISK_SELECTED")
dialog --backtitle "$MSG_BACK_TITLE" --msgbox "$MSG_SMART_AFTER\n\n$SA" 12 60
clear

# =========================================================
# VEREDICTO FINAL
# =========================================================

if disk_ok "$DISK_SELECTED"; then
  dialog --backtitle "$MSG_BACK_TITLE" --msgbox "$MSG_GOOD" 8 45
else
  dialog --backtitle "$MSG_BACK_TITLE" --msgbox "$MSG_BAD" 8 55
fi

clear
exit 0
