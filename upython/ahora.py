##################################################################
# Script Name: ahora.py
# Description: Devuelve los segundos de la hora española corregidos
#               con el horario de invierno/verano
# Args: N/A
# Creation/Update: 20210205/20210211
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
##################################################################

import utime

class ahora:

    def __new__(self):
        sg_utc_1 = utime.mktime(utime.localtime())+3600
        ano = utime.localtime(sg_utc_1)[0]
        
        for i in range(25,32):
            fecha_ini = utime.localtime(utime.mktime([ano,03,i,2,0,0,0,0]))
            fecha_fin = utime.localtime(utime.mktime([ano,10,i,2,0,0,0,0]))
            if fecha_ini[6] == 6: ini_h_ver = utime.mktime(fecha_ini) 
            if fecha_fin[6] == 6: fin_h_ver = utime.mktime(fecha_fin)
            
        if sg_utc_1 > ini_h_ver and sg_utc_1 < fin_h_ver:
            sg_esp = sg_utc_1 + 3600
        else:
            sg_esp = sg_utc_1
        
        return sg_esp
