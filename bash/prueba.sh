#!/bin/bash

# Incluye el archivo que contiene la función
source telegram_V2.sh

# Llama a la función
msg_instr "Hola Mundo"
msg_resul "Adios"

msg_instr "Hola Mundo de los enanos"
msg_resul "Adios"

msg_instr "LLamando a la función que come bichos"
msg_resul "Error"

send_msg
