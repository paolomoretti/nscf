<?php
require 'flight/Flight.php';
require 'helper.php';

Flight::route('GET /events', function() {
  $sql = "SELECT id, NomeEventoSuperEsteso as nome, luogo, data, JPG_Miglior_Link as img FROM Query_Dettaglio WHERE Annullato=0 AND DaIeri='Si';";
  $json = Flight::query($sql);

  Flight::json($json);
});

Flight::route('GET /events/@id', function($id) {
  $sql = "SELECT id, NomeEventoSuperEsteso, luogo, data, EM, ES, FI, MM, SP, FE, Indirizzo, Evento_Web_Link, Evento_Facebook_Link, NSCF_Link,
					Evento_Myspace_Link, Evento_Twitter_Link, Luoghi_Web_Link, Luoghi_Facebook_Link, Luoghi_Myspace_Link, Luoghi_Twitter_Link,
					Luoghi_GooglePlus_Link, Evento_GooglePlus_Link, Luoghi_Foursquare_Link, Evento_Foursquare_Link, Luoghi_JPG, ID_ilMeteo,
					JPG_Miglior_Link, ID_Luogo, DataInizio, DataFine, OraInizio, Annullato, OraFine, GPS_L, NomeLuogo, Localita
				FROM Query_Dettaglio
				WHERE id=$id";
  $json = Flight::query($sql);

  Flight::json($json);
});

Flight::start();
?>
