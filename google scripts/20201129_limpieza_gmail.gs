function limpiar_propaganda() {
  var filtro = GmailApp.search('category:promotions older_than:10d');
  for (var i = 0; i < filtro.length; i++) {
    filtro[i].moveToTrash();
  }
  var filtro = GmailApp.search('label:notificarme older_than:10d');
  for (var i = 0; i < filtro.length; i++) {
    filtro[i].moveToTrash();
  }
}