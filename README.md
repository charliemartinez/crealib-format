# Crealib Format

**Autor / Author:** Charlie Martínez – Quirinux GNU/Linux®  
**Licencia / License:** GPLv2.0 <br>
**Compatible OS:** Debian, Devuan y derivadas


---
![Contributors](https://img.shields.io/github/contributors/charliemartinez/crealib-format) ![Stars](https://img.shields.io/github/stars/charliemartinez/crealib-format?style=flat) ![Forks](https://img.shields.io/github/forks/charliemartinez/crealib-format?style=flat) ![Issues](https://img.shields.io/github/issues/charliemartinez/crealib-format) ![Last Commit](https://img.shields.io/github/last-commit/charliemartinez/crealib-format) ![Activity](https://img.shields.io/github/commit-activity/m/charliemartinez/crealib-format) ![Repo Size](https://img.shields.io/github/repo-size/charliemartinez/crealib-format?style=flat) ![Lenguaje](https://img.shields.io/badge/Lenguaje-Bash-blue)

---

## 🧭 Descripción general / Overview

**ES:**  
`Crealib Format` es una herramienta profesional para **revisión, recuperación, borrado seguro y certificación básica de discos duros HDD conectados por USB**, orientada a entornos de **reciclaje, reacondicionamiento y bancos de pruebas**. Integra verificación SMART, recuperación de sectores con `badblocks` y borrado forense con `dd`, todo mediante una interfaz interactiva basada en `dialog`.

**EN:**  
`Crealib Format` is a professional tool for **testing, recovering, secure erasing and basic certification of USB-connected HDD drives**, designed for **recycling environments, refurbishment labs and test benches**. It integrates SMART diagnostics, sector recovery with `badblocks`, and forensic wiping with `dd`, all through an interactive `dialog` interface.

---

## ✔️ Características / Features

**ES:**
- Detección automática de HDD conectados por USB  
- Verificación SMART antes y después del proceso  
- Recuperación avanzada de sectores con `badblocks`  
- Borrado forense completo mediante `dd`  
- Desmontaje automático de particiones activas  
- Clasificación automática del estado del disco (APTO / NO APTO)  
- Interfaz 100% interactiva con `dialog`  
- Soporte multilenguaje (ES, EN, PT, GL, FR, IT, DE)  
- Requiere ejecución como administrador (root)  
- Programado íntegramente en Bash Scripting  

**EN:**
- Automatic detection of USB-connected HDDs  
- SMART verification before and after processing  
- Advanced sector recovery using `badblocks`  
- Full forensic wipe using `dd`  
- Automatic unmounting of active partitions  
- Automatic disk health classification (GOOD / FAILED)  
- 100% interactive interface with `dialog`  
- Multilanguage support (ES, EN, PT, GL, FR, IT, DE)  
- Requires administrator (root) execution  
- Fully programmed in Bash scripting  

---

## ▶️ Ejecución / How to Run

### ES / EN – Instalación

Clonar el repositorio:

    git clone https://github.com/charliemartinez/crealib-format.git
    cd crealib-format
    chmod +x crealib-format.sh

---

### ES / EN – Uso

Ejecutar como administrador:

    sudo ./crealib-format.sh

---

## ⚠️ Nota Importante / Important Note

**ES:**  
`Crealib Format` realiza operaciones **destructivas y de bajo nivel sobre los discos**. Todo el contenido del dispositivo seleccionado será **eliminado de forma irreversible**. Utilice esta herramienta **únicamente en entornos de prueba, reciclaje o reacondicionamiento**.

**EN:**  
`Crealib Format` performs **destructive low-level operations on disks**. All data on the selected device will be **permanently erased**. Use this tool **only in testing, recycling, or refurbishment environments**.

---

## 🤝 Agradecimientos / Acknowledgments

**ES:**  
A la comunidad de **HACKLAB ESCARNIO (Santiago de Compostela, Galicia)**, por fomentar la reutilización responsable del hardware y el uso de herramientas abiertas en procesos de reacondicionamiento.

**EN:**  
Thanks to the **HACKLAB ESCARNIO (Santiago de Compostela, Galicia)** for promoting responsible hardware reuse and the adoption of open tools in refurbishment processes.

---

## 📘 Información ampliada / More Information

https://www.quirinux.org/

---

## ⚖️ Aviso legal / Legal Notice

**ES:**  
Este proyecto forma parte del ecosistema **Quirinux**, pero es compatible con cualquier distribución moderna de GNU/Linux. Distribuido bajo los términos de la licencia **GPLv2**.

**EN:**  
This project is part of the **Quirinux** ecosystem but remains compatible with any modern GNU/Linux distribution. Released under the terms of the **GPLv2 license**.

**Autor / Author:** Charlie Martínez  
📧 <cmartinez@quirinux.org>

**Más información / More information:**  
https://www.quirinux.org/aviso-legal
