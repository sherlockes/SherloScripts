////////////////////////////////////////////////////////////////////////////
// Script Name: 20191219_mover_archivos.gs
// Description: Mueve los archivos de la raiz de Google Drive a una carpeta
// Args: N/A
// Creation/Update: 20191219/20191220
// Author: www.sherblog.pro
// Email: sherlockes@gmail.com
// Post: https://sherblog.pro/archivos-de-telegram-al-nas/
////////////////////////////////////////////////////////////////////////////

function move_files() {
  // Carpeta compartida Shd_Sherlockes78
  var shd_id = "1RoVpSOD0wzGZ-1OPweS9DR55wwndKcbO"
  var shd_folder = DriveApp.getFolderById(shd_id)
  
  // Mueve los archivo en el raiz a la carpeta compartida
  var root_files = DriveApp.getRootFolder().getFiles();
  while (root_files.hasNext()) {
    var file = root_files.next();
    shd_folder.addFile(file);
    DriveApp.getRootFolder().removeFile(file);
  }
  
  // Mueve los archivos de la carpeta a la papelera cuando han pasado 24 horas
  var shd_files = shd_folder.getFiles();
  while (shd_files.hasNext()) {
    var file = shd_files.next();
    if (new Date() - file.getLastUpdated() > 24 * 60 * 60 * 1000) {
      file.setTrashed(true);
    }
  }
  
  // Vacía la papelera
  Drive.Files.emptyTrash();
}