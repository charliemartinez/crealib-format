#!/bin/bash
# ----------------------------------------------------------------------
# Nombre:            CREALIB FORMAT Ver. 1.3.4
# Autor:             Charlie Martinez® <cmartinez@quirinux.org>
# Licencia:          https://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
# Utilidad:          Recuperación y formateo de discos MECÁNICOS vía USB.
# Distro:            Debian, Devuan, Ubuntu y derivadas
# ----------------------------------------------------------------------

LOG_FILE="/var/log/crealib-format.log"
DIALOG_STARTED=0

clean_exit() {
  if [[ $DIALOG_STARTED -eq 1 ]]; then
    clear
    stty sane 2>/dev/null
  fi
}

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# ----------------------------------------------------------------------
# Idioma
# ----------------------------------------------------------------------

SYS_LANG="${LANG:-${LC_ALL:-en_US}}"

case "$SYS_LANG" in
  es*|ES*) LANGMODE="ES" ;;
  pt*|PT*) LANGMODE="PT" ;;
  gl*|GL*) LANGMODE="GL" ;;
  fr*|FR*) LANGMODE="FR" ;;
  it*|IT*) LANGMODE="IT" ;;
  de*|DE*) LANGMODE="DE" ;;
  ru*|RU*) LANGMODE="RU" ;;
  hu*|HU*) LANGMODE="HU" ;;
  *)       LANGMODE="EN" ;;
esac

# ----------------------------------------------------------------------
# Traducciones
# ----------------------------------------------------------------------

case "$LANGMODE" in
ES)
BANNER_HDD="⚠️ SOLO DISCOS MECÁNICOS (HDD) ⚠️"
MSG_ROOT_ERROR="ERROR: Este programa debe ejecutarse como root."
MSG_ROOT_USE="Use: sudo $0"
MSG_WELCOME="Utilidad profesional para recuperación y borrado forense de discos HDD USB.\n\n$BANNER_HDD\n\n• SMART\n• badblocks\n• Borrado total\n\nLog:\n$LOG_FILE"
MSG_NOT_HDD="DISPOSITIVO NO ADMITIDO\n\nEste programa SOLO funciona con discos duros MECÁNICOS (HDD) conectados por USB.\n\nPendrives, SSD y memorias flash NO están permitidos."
MSG_MENU_TEXT="Seleccione el HDD USB:"
MSG_CONFIRM_ZERO="¿CONFIRMAS el BORRADO TOTAL de:\n\n%s\n\nESTA ACCIÓN ES IRREVERSIBLE?"
MSG_NO_USB="No se detectaron discos HDD USB."
MSG_UMOUNT="Se desmontarán las particiones activas."
MSG_SMART_BEFORE="Estado SMART ANTES:"
MSG_SMART_AFTER="Estado SMART DESPUÉS:"
MSG_BADBLOCKS="¿Intentar recuperación de sectores (badblocks)?"
MSG_GOOD="DISCO APTO PARA USO"
MSG_BAD="DISCO NO APTO"
MSG_SYS_PROTECT="ERROR: Disco del sistema protegido:"
;;
PT)
BANNER_HDD="⚠️ APENAS DISCOS MECÂNICOS (HDD) ⚠️"
MSG_ROOT_ERROR="ERRO: Deve ser executado como root."
MSG_ROOT_USE="Use: sudo $0"
MSG_WELCOME="Utilitário profissional para HDD USB.\n\n$BANNER_HDD\n\nLog:\n$LOG_FILE"
MSG_NOT_HDD="DISPOSITIVO NÃO SUPORTADO\n\nApenas discos HDD mecânicos via USB."
MSG_MENU_TEXT="Selecione o HDD USB:"
MSG_CONFIRM_ZERO="CONFIRMA A EXCLUSÃO TOTAL DE:\n\n%s\n\nIRREVERSÍVEL?"
MSG_NO_USB="Nenhum HDD USB detectado."
MSG_UMOUNT="As partições ativas serão desmontadas."
MSG_SMART_BEFORE="SMART ANTES:"
MSG_SMART_AFTER="SMART DEPOIS:"
MSG_BADBLOCKS="Executar badblocks?"
MSG_GOOD="DISCO OK"
MSG_BAD="DISCO COM FALHAS"
MSG_SYS_PROTECT="ERRO: Disco do sistema protegido:"
;;
GL)
BANNER_HDD="⚠️ SÓ DISCOS MECÁNICOS (HDD) ⚠️"
MSG_ROOT_ERROR="ERRO: Debe executarse como root."
MSG_ROOT_USE="Use: sudo $0"
MSG_WELCOME="Utilidade profesional para HDD USB.\n\n$BANNER_HDD"
MSG_NOT_HDD="DISPOSITIVO NON ADMITIDO\n\nSó HDD mecánicos vía USB."
MSG_MENU_TEXT="Seleccione o HDD USB:"
MSG_CONFIRM_ZERO="CONFIRMAS O BORRADO TOTAL DE:\n\n%s\n\nIRREVERSIBLE?"
MSG_NO_USB="Non se detectaron HDD USB."
MSG_UMOUNT="Desmontaranse as particións activas."
MSG_SMART_BEFORE="SMART ANTES:"
MSG_SMART_AFTER="SMART DESPOIS:"
MSG_BADBLOCKS="Executar badblocks?"
MSG_GOOD="DISCO APTO"
MSG_BAD="DISCO NON APTO"
MSG_SYS_PROTECT="ERRO: Disco do sistema protexido:"
;;
FR)
BANNER_HDD="⚠️ HDD MÉCANIQUES UNIQUEMENT ⚠️"
MSG_ROOT_ERROR="ERREUR: Doit être exécuté en root."
MSG_ROOT_USE="Utilisez: sudo $0"
MSG_WELCOME="Outil professionnel pour HDD USB.\n\n$BANNER_HDD"
MSG_NOT_HDD="PÉRIPHÉRIQUE NON SUPPORTÉ\n\nUniquement HDD mécaniques USB."
MSG_MENU_TEXT="Sélectionnez le HDD USB:"
MSG_CONFIRM_ZERO="CONFIRMEZ L'EFFACEMENT TOTAL DE:\n\n%s\n\nIRRÉVERSIBLE?"
MSG_NO_USB="Aucun HDD USB détecté."
MSG_UMOUNT="Les partitions actives seront démontées."
MSG_SMART_BEFORE="SMART AVANT:"
MSG_SMART_AFTER="SMART APRÈS:"
MSG_BADBLOCKS="Exécuter badblocks?"
MSG_GOOD="DISQUE OK"
MSG_BAD="DISQUE DÉFECTUEUX"
MSG_SYS_PROTECT="ERREUR: Disque système protégé:"
;;
IT)
BANNER_HDD="⚠️ SOLO HDD MECCANICI ⚠️"
MSG_ROOT_ERROR="ERRORE: Deve essere eseguito come root."
MSG_ROOT_USE="Usa: sudo $0"
MSG_WELCOME="Utility professionale per HDD USB.\n\n$BANNER_HDD"
MSG_NOT_HDD="DISPOSITIVO NON SUPPORTATO\n\nSolo HDD meccanici USB."
MSG_MENU_TEXT="Seleziona HDD USB:"
MSG_CONFIRM_ZERO="CONFERMI LA CANCELLAZIONE TOTALE DI:\n\n%s\n\nIRREVERSIBILE?"
MSG_NO_USB="Nessun HDD USB rilevato."
MSG_UMOUNT="Le partizioni attive verranno smontate."
MSG_SMART_BEFORE="SMART PRIMA:"
MSG_SMART_AFTER="SMART DOPO:"
MSG_BADBLOCKS="Eseguire badblocks?"
MSG_GOOD="DISCO OK"
MSG_BAD="DISCO DIFETTOSO"
MSG_SYS_PROTECT="ERRORE: Disco di sistema protetto:"
;;
DE)
BANNER_HDD="⚠️ NUR MECHANISCHE HDD ⚠️"
MSG_ROOT_ERROR="FEHLER: Muss als root ausgeführt werden."
MSG_ROOT_USE="Verwendung: sudo $0"
MSG_WELCOME="Professionelles Tool für USB-HDD.\n\n$BANNER_HDD"
MSG_NOT_HDD="NICHT UNTERSTÜTZTES GERÄT\n\nNur mechanische USB-HDDs."
MSG_MENU_TEXT="USB-HDD auswählen:"
MSG_CONFIRM_ZERO="BESTÄTIGEN SIE DAS LÖSCHEN VON:\n\n%s\n\nUNUMKEHRBAR?"
MSG_NO_USB="Keine USB-HDD erkannt."
MSG_UMOUNT="Aktive Partitionen werden ausgehängt."
MSG_SMART_BEFORE="SMART VORHER:"
MSG_SMART_AFTER="SMART NACHHER:"
MSG_BADBLOCKS="badblocks ausführen?"
MSG_GOOD="LAUFWERK OK"
MSG_BAD="LAUFWERK FEHLERHAFT"
MSG_SYS_PROTECT="FEHLER: Systemlaufwerk geschützt:"
;;
RU)
BANNER_HDD="⚠️ ТОЛЬКО МЕХАНИЧЕСКИЕ HDD ⚠️"
MSG_ROOT_ERROR="ОШИБКА: Требуются права root."
MSG_ROOT_USE="Используйте: sudo $0"
MSG_WELCOME="Профессиональная утилита для USB HDD.\n\n$BANNER_HDD"
MSG_NOT_HDD="УСТРОЙСТВО НЕ ПОДДЕРЖИВАЕТСЯ\n\nДопускаются только механические HDD по USB."
MSG_MENU_TEXT="Выберите USB HDD:"
MSG_CONFIRM_ZERO="ПОДТВЕРДИТЕ ПОЛНОЕ УДАЛЕНИЕ:\n\n%s\n\nНЕОБРАТИМО?"
MSG_NO_USB="USB HDD не обнаружены."
MSG_UMOUNT="Активные разделы будут отключены."
MSG_SMART_BEFORE="SMART ДО:"
MSG_SMART_AFTER="SMART ПОСЛЕ:"
MSG_BADBLOCKS="Запустить badblocks?"
MSG_GOOD="ДИСК ИСПРАВЕН"
MSG_BAD="ДИСК НЕИСПРАВЕН"
MSG_SYS_PROTECT="ОШИБКА: Системный диск защищён:"
;;
HU)
BANNER_HDD="⚠️ CSAK MECHANIKUS HDD ⚠️"
MSG_ROOT_ERROR="HIBA: Root jogosultság szükséges."
MSG_ROOT_USE="Használat: sudo $0"
MSG_WELCOME="Professzionális USB HDD eszköz.\n\n$BANNER_HDD"
MSG_NOT_HDD="NEM TÁMOGATOTT ESZKÖZ\n\nCsak mechanikus USB HDD engedélyezett."
MSG_MENU_TEXT="USB HDD kiválasztása:"
MSG_CONFIRM_ZERO="MEGERŐSÍTED A TELJES TÖRLÉST:\n\n%s\n\nVISSZAFORDÍTHATATLAN?"
MSG_NO_USB="Nem található USB HDD."
MSG_UMOUNT="Az aktív partíciók leválasztásra kerülnek."
MSG_SMART_BEFORE="SMART ELŐTTE:"
MSG_SMART_AFTER="SMART UTÁNA:"
MSG_BADBLOCKS="badblocks futtatása?"
MSG_GOOD="LEMEZ RENDBEN"
MSG_BAD="LEMEZ HIBÁS"
MSG_SYS_PROTECT="HIBA: Rendszerlemez védett:"
;;
*)
BANNER_HDD="⚠️ MECHANICAL HDD ONLY ⚠️"
MSG_ROOT_ERROR="ERROR: Must be run as root."
MSG_ROOT_USE="Use: sudo $0"
MSG_WELCOME="Professional utility for USB HDD.\n\n$BANNER_HDD"
MSG_NOT_HDD="UNSUPPORTED DEVICE\n\nOnly mechanical USB HDDs are allowed."
MSG_MENU_TEXT="Select USB HDD:"
MSG_CONFIRM_ZERO="CONFIRM TOTAL ERASE OF:\n\n%s\n\nIRREVERSIBLE?"
MSG_NO_USB="No USB HDD detected."
MSG_UMOUNT="Active partitions will be unmounted."
MSG_SMART_BEFORE="SMART BEFORE:"
MSG_SMART_AFTER="SMART AFTER:"
MSG_BADBLOCKS="Run badblocks?"
MSG_GOOD="DISK OK"
MSG_BAD="DISK FAILED"
MSG_SYS_PROTECT="ERROR: System disk protected:"
;;
esac

# ----------------------------------------------------------------------
# Root
# ----------------------------------------------------------------------

[[ $EUID -ne 0 ]] && { echo "$MSG_ROOT_ERROR"; echo "$MSG_ROOT_USE"; exit 1; }

# ----------------------------------------------------------------------
# Dependencias
# ----------------------------------------------------------------------

REQ=(dialog smartctl lsblk findmnt udevadm dd badblocks sync awk)
for c in "${REQ[@]}"; do
  command -v "$c" >/dev/null || { echo "Missing dependency: $c"; exit 1; }
done

MSG_BACK_TITLE="CREALIB FORMAT v1.3.4 — HDD USB ONLY"

trap clean_exit EXIT INT TERM
DIALOG_STARTED=1

dialog --backtitle "$MSG_BACK_TITLE" --msgbox "$MSG_WELCOME" 16 70
log "Inicio"

# ----------------------------------------------------------------------
# Funciones
# ----------------------------------------------------------------------

is_valid_usb_hdd() {
  local dev base rm rot flash size

  base="$(basename "$1")"

  # Solo USB
  [[ "$(lsblk -dn -o TRAN "$1")" != "usb" ]] && return 1

  # Solo rotacional
  rot="$(cat /sys/block/$base/queue/rotational 2>/dev/null)"
  [[ "$rot" != "1" ]] && return 1

  # Descarta dispositivos removibles tipo pendrive
  rm="$(cat /sys/block/$base/removable 2>/dev/null)"
  [[ "$rm" == "1" ]] && return 1

  # Detecta flash explícito vía udev
  flash="$(udevadm info --query=property --name="$1" 2>/dev/null | grep -E 'ID_DRIVE_FLASH=1|ID_DRIVE_THUMB=1')"
  [[ -n "$flash" ]] && return 1

  # Tamaño mínimo (IDE antiguos)
  size=$(blockdev --getsize64 "$1" 2>/dev/null)
  [[ -z "$size" || "$size" -lt $((20*1024*1024*1024)) ]] && return 1

  return 0
}


unmount_parts() {
  lsblk -ln "$1" | awk '$7!=""{print $1}' | while read -r p; do
    umount "/dev/$p" 2>/dev/null
  done
}

is_system_disk() {
  ROOT_DEV=$(findmnt -n -o SOURCE / | sed 's/[0-9]*$//')
  [[ "$1" == "$ROOT_DEV" ]]
}

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

# ----------------------------------------------------------------------
# Detección HDD USB mecánicos
# ----------------------------------------------------------------------

mapfile -t DISKS < <(
  lsblk -ndo NAME,TYPE | awk '$2=="disk"{print "/dev/"$1}'
)

VALID=()
for d in "${DISKS[@]}"; do
  is_valid_usb_hdd "$d" && VALID+=("$d")
done


[[ ${#VALID[@]} -eq 0 ]] && dialog --msgbox "$MSG_NOT_HDD" 12 70 && exit 1

# ----------------------------------------------------------------------
# Menú
# ----------------------------------------------------------------------

MENU=()
for d in "${VALID[@]}"; do
  MENU+=("$d" "$(lsblk -ndo SIZE "$d")")
done

DISK=$(dialog --menu "$MSG_MENU_TEXT" 16 60 8 "${MENU[@]}" 3>&1 1>&2 2>&3)
[[ -z "$DISK" ]] && exit 0

# ----------------------------------------------------------------------
# Protección sistema
# ----------------------------------------------------------------------

if is_system_disk "$DISK"; then
  dialog --msgbox "$MSG_SYS_PROTECT $DISK" 8 60
  exit 1
fi

# ----------------------------------------------------------------------
# Flujo
# ----------------------------------------------------------------------

unmount_parts "$DISK"

SB=$(get_smart "$DISK")
dialog --msgbox "$MSG_SMART_BEFORE\n\n$SB" 12 60

dialog --yesno "$MSG_BADBLOCKS" 10 60 && \
( badblocks -wsv "$DISK" ) | dialog --programbox 16 85

dialog --yesno "$(printf "$MSG_CONFIRM_ZERO" "$DISK")" 12 70 || exit 0

dd if=/dev/zero of="$DISK" bs=4M status=progress conv=fsync
sync

SA=$(get_smart "$DISK")
dialog --msgbox "$MSG_SMART_AFTER\n\n$SA" 12 60

disk_ok "$DISK" && dialog --msgbox "$MSG_GOOD" 8 40 || dialog --msgbox "$MSG_BAD" 8 50

exit 0
