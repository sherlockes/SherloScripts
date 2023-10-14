#!/bin/bash

###################################################################
#Script Name: hazigbee.sh
#Description: Descripción
#Args: N/A
#Creation/Update: 20231014/20231014
#Author: www.sherblog.pro                                             
#Email: sherlockes@gmail.com                               
###################################################################

################################
####       Variables        ####
################################

TOKEN=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJkNzU5MjQ3YzRkMGY0YzQxYmQ3ZGZiODMzN2I0MWQ0ZSIsImlhdCI6MTY5NzMxNjA5NCwiZXhwIjoyMDEyNjc2MDk0fQ.r9JWIpkDIdEsqXEVcMU9X2iGoPnWtSr7FpJ0Ekq09z8


################################
####      Dependencias      ####
################################


################################
####       Funciones        ####
################################



################################
####    Script principal    ####
################################

curl -X GET -H "Authorization: Bearer $TOKEN" http://192.168.10.202:8123/api/states/switch.chicos_mesilla_enchufe
