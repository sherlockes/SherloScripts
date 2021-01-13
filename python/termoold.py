####################################################################
##  Clase e Reniciar el archivo de Gsheet  ##
####################################################################

gsheet_datos = Gsheet("shermostat")

######################
## Cálculo de datos ##
######################

if gsheet_datos.online:

    tiempo = datetime.now().strftime('%Y/%m/%d %H:%M:%S')
    tiempo_ant = datetime.strptime(gsheet_datos.leer_fila("datos",2)[0], '%Y/%m/%d %H:%M:%S')
    temp_ant_consigna = float(gsheet_datos.leer_fila("datos",2)[2])
    real_temp_ant = float(gsheet_datos.leer_fila("datos",2)[3])
    hum_ant_real = float(gsheet_datos.leer_fila("datos",2)[4])
    temp_ant_estado = gsheet_datos.leer_fila("datos",2)[5]
    var_temp = abs(interior.temp - real_temp_ant) + abs(consigna_temp_act - consigna_temp_ant)
    var_tiempo = datetime.now() - tiempo_ant
    var_temp_tiempo = round((60*(interior.temp - real_temp_ant))/var_tiempo.seconds,2)
    if abs(var_temp_tiempo) < 0.01:
        var_temp_tiempo = 0

    # Incrementa la inercia si la Tª supera el rango de inercia con la caldera encendida
    if interior.temp > datos_json["inercia_rango"] * (datos_json["consigna"] + datos_json["histeresis"]) and datos_json["rele_estado"] == "on":
        if datos_json["inercia"] <= 1800:
            datos_json["inercia"] += 25
        print("Se ha aumentado la inercia térmica de la caldera")
        Telegram("Se ha aumentado la inercia térmica de la caldera")
else:
    var_temp_tiempo = 0

#################################################################
## Graba los datos en una hoja de Google Sheets si han variado ##
#################################################################
if gsheet_datos.online:
    print(f"Dato ant: Tª consigna: {consigna_temp_ant} - Tª real:{real_temp_ant}ºC - Calef:{temp_ant_estado} - Humedad:{hum_ant_real}%")
    print(f"Dato act: Tª consigna: {consigna_temp_act} - Tª real:{interior.temp}ºC - Calef:{rele.estado} - Humedad:{interior.hume}%")

    print("Datos GSheet: ", end="")
    # Guarda la consigna (Si ha variado)
    datos_json["consigna"] = consigna_temp_act
    if consigna_temp_var != 0:
        gsheet_datos.escribir_celda("consigna","A1",consigna_temp_act)
        print(f"Nueva consigna a {consigna_temp_act}ºC, ", end="")

    # Guarda los datos (Si han variado o la calefacción está en marcha)
    if var_temp  < 0.1 and estado == temp_ant_estado:
        print("Nada ha cambiado (La humedad no cuenta...)")
    elif var_temp >= 0.1 or rele_estado == "on":
        gsheet_datos.escribir_celda("consigna","A1",consigna_temp_act)
        gsheet_datos.escribir_fila("datos",[tiempo,exterior.temp_actual,consigna_temp_act,interior.temp,interior.hume,rele_estado,var_temp_tiempo,rele_tiempo_on])
        print("Se han guardado los datos actuales.")
else:
    print(f"Dato act: Tª consigna: {consigna_temp_act} - Tª real:{interior.temp}ºC - Calef:{estado} - Humedad:{interior.hume}%")