#!/bin/bash

# Incluye el archivo que contiene la función
source telegram_V2.sh

# Llama a la función
tele_msg_title "Un título para un texto"

artista="Pedro Sanchez y sus amigos"

tele_msg_instr "Descargando de $artista"
tele_msg_resul "ok"

tele_msg_instr "iNTERRUMPIENDO A LA VACA"
tele_msg_resul "error"

tele_msg_instr "iNTERRUMPIENDO A LA VACA"
tele_msg_resul "..."



tele_end

