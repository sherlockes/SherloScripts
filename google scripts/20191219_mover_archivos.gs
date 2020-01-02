/////////////////////////////////////////////////////////////////////////
// Script Name: mover_archivos.gs
// Description: Mueve los archivos de las carpetas de Google Drive donde
//              los ubican los Bot a una carpeta compartida con el NAS
// Args: N/A
// Creation/Update: 20191219/20200102
// Author: www.sherblog.pro
// Email: sherlockes@gmail.com
// Post: https://sherblog.pro/archivos-de-telegram-al-nas/
/////////////////////////////////////////////////////////////////////////

function move_files() {
  // Carpeta compartida Shd_Sherlockes78
  var shd_id = "1RoVpSOD0wzGZ-1OPweS9DR55wwndKcbO"
  var shd_folder = DriveApp.getFolderById(shd_id)
  
  // Carpetas donde buscar los archivos para mover  
  var folders_id = [];
  // Carpeta compartida "driveuploadbot"
  folders_id.push("1Lf190bC0KFjWcLywjvCXuNehBSRlGFfS");
  // Carpeta compartida "driveuploadbot"
  folders_id.push("1qxy6waDIaCl6r8UdkiEm6XZ_DLKFedGF");
  
  for each (var folder_id in folders_id)
  {
    var to_move_folder = DriveApp.getFolderById(folder_id)
    var to_move_files = to_move_folder.getFiles();
    while (to_move_files.hasNext()) {
      var file = to_move_files.next();
      shd_folder.addFile(file);
      to_move_folder.removeFile(file);
    }
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