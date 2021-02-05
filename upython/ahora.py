##################################################################
# Script Name: ahora.py
# Description: Devuelve los segundos de la hora española corregidos
#               con el horario de invierno/verano
# Args: N/A
# Creation/Update: 20210205/20210205
# Author: www.sherblog.pro                                                
# Email: sherlockes@gmail.com                                           
##################################################################

import utime

class ahora:

    def __new__(self):
        for i in range(25,32):
            fecha_ini = utime.localtime(utime.mktime([2021,3,i,2,0,0,0,0]))
            fecha_fin = utime.localtime(utime.mktime([2021,10,i,2,0,0,0,0]))
            if fecha_ini[6] == 6: ini_h_ver = utime.mktime(fecha_ini) 
            if fecha_fin[6] == 6: fin_h_ver = utime.mktime(fecha_fin)

        sg_utc = utime.mktime(utime.localtime())
            
        if sg_utc > ini_h_ver and sg_utc < fin_h_ver:
            sg_esp = sg_utc + 7200
        else:
            sg_esp = sg_utc + 3600
        
        return sg_esp
