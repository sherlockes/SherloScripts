#!/bin/bash

# Incluye el archivo que contiene la función
source telegram_V2.sh

# Llama a la función
tele_msg_title "Un título pra un texto"


tele_msg_instr "Hola Mundo"
tele_msg_resul "Adios"

tele_msg_instr "iNTERRUMPIENDO A LA VACA"
tele_msg_resul "error"

tele_msg_instr "iNTERRUMPIENDO A LA VACA"
tele_msg_resul "..."



tele_send_msg

