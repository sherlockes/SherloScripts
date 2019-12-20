/////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: 20171210_sherblog_db_backup.gs
// Description: Realiza una copia de seguridad "versionada" de la base de datos de WordPress
// Args: N/A
// Creation/Update: 20171210/20191220
// Author: www.sherblog.pro
// Email: sherlockes@gmail.com
// Post: https://sherblog.pro/copia-de-seguridad-de-la-base-de-datos-de-wordpress/
/////////////////////////////////////////////////////////////////////////////////////////////

// Declaración de variables
var ahora = new Date();
var carpeta = DriveApp.searchFolders("title contains 'sherblog_db_backups'").next();
 
// Matrices para distintos rangos de antiguedad 10-20-40-80-160 
var d10 = new Array();
var d20 = new Array();
var d40 = new Array();
var d80 = new Array();
var d160 = new Array();
 
function backup_db() {
  // Genera matriz con los archivos existentes en carpeta
  var archivos = carpeta.getFiles();
  
  while (archivos.hasNext()) {
    var archivo = archivos.next();
    // Asigna cada archivo al rango de antiguedad y borra los obsoletos
    if(dias(archivo)>5 && dias(archivo)<11){d10.push(archivo)};
    if(dias(archivo)>10 && dias(archivo)<21){d20.push(archivo)};
    if(dias(archivo)>20 && dias(archivo)<41){d40.push(archivo)};
    if(dias(archivo)>40 && dias(archivo)<81){d80.push(archivo)};
    if(dias(archivo)>80 && dias(archivo)<161){d160.push(archivo)};
    if(dias(archivo)>160){archivo.setTrashed(true)};
  }
               
  // Borrar los archivos recientes de cada rango
  limpiar(d10);
  limpiar(d20);
  limpiar(d40);
  limpiar(d80);
  limpiar(d160); 
}
 
// función para contar los días de antiguedad de un archivo
function dias(archiv){
  return(Math.round((ahora - archiv.getLastUpdated())/1000/60/60/24));
}
 
// Función para eliminar los archivos mas recientes de una matriz
function limpiar(matriz){
  while (matriz.length>1){
    if(dias(matriz[0])>dias(matriz[1])){
      matriz[1].setTrashed(true);  //Elimina el archivo más reciente
      matriz.splice(1,1);  //Elimina la entrada de la matriz correspondiente al archivo borrado
    }else{
      matriz[0].setTrashed(true);
      matriz.splice(0,1);
    }
  }
}