#!/bin/bash

# Incluye el archivo que contiene la función
source telegram_V2.sh

# Llama a la función
msg_instr "Hola Mundo"
msg_resul "Adios"

msg_instr "iNTERRUMPIENDO A LA VACA"
msg_resul "error"

send_msg
