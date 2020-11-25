import gspread
import matplotlib.pyplot as plt
import pandas as pd
from datetime import datetime, timedelta


gsheets = gspread.service_account()
archivo = gsheets.open("shermostat")
hoja = archivo.worksheet("datos")

def convertir(estado):
    if estado == "on":
        return 1
    else:
        return 0


#hoja.update("A2", datetime.now())

dataframe = pd.DataFrame(hoja.get_all_records())
print(dataframe.head())
###dataframe['Hora'] = pd.to_datetime(dataframe['Hora']).dt.date
dataframe['Hora'] = pd.to_datetime(dataframe['Hora'],format='%Y/%m/%d %H:%M:%S')
#dataframe['Hora'] = pd.to_datetime(dataframe['Hora'],format= '%YYYY/mm/dd %H:%M:%S' ).dt.time
dataframe['T_Consigna'] = pd.to_numeric(dataframe['T_Consigna'])
dataframe['T_Ext'] = pd.to_numeric(dataframe['T_Ext'])
dataframe['momento'] = dataframe.apply(lambda row: convertir(row.Estado_Rele) , axis = 1)
dataframe['estado'] = dataframe.apply(lambda row: row.Hora , axis = 1)

dataframe = dataframe[::-1]
print(dataframe.head())
dataframe.plot(kind='line', x="Hora", y=["T_Real", "T_Ext", "momento"])
plt.ylabel("Temperaturas")
plt.title("La Tª en mi casa")

plt.grid()
#dataframe.plot(drawstyle="steps", linewidth=2)
ayer = datetime.now() - timedelta(days = 1) 
plt.xlim(ayer,datetime.now())
#dataframe.plot.bar(x="Hora", y="momento", rot=0)
plt.show()

""" plt.plot([1, 2, 3, 4])
plt.ylabel('some numbers')
plt.show() """