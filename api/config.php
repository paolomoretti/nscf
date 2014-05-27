<?php
error_reporting(1);
ini_set( 'display_errors','1');

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, PUT, OPTIONS');
header('Content-type: application/json');


/*
 * Siccome vogliamo che tutti gli oggetti evento siano uguali, non importa se con piu' dati del necessario, imposto
 * la lista di campi come variabile statica, in modo che ogni volta l'oggetto sia lo stesso e se cambiamo la variabile
 * cambi in ogni risposta
 */
Flight::set("event_fields", "id, NomeEventoSuperEsteso as nome, data, EM, ES, FI, MM, SP, FE, NSCF_Link,

          Luoghi_Web_Link as luogo_link, Luoghi_Facebook_Link as luogo_facebook, Luoghi_Myspace_Link as luogo_myspace, Luoghi_Twitter_Link as luogo_twitter,
          Luoghi_GooglePlus_Link as luogo_googleplus, Luoghi_Foursquare_Link as luogo_foursquare, Luoghi_JPG as luogo_image, luogo, Indirizzo,

          Evento_Myspace_Link as evento_myspace, Evento_Twitter_Link as evento_twitter, Evento_GooglePlus_Link as evento_googleplus, Evento_Foursquare_Link as evento_foursquare,
          Evento_Web_Link as evento_link, Evento_Facebook_Link as evento_facebook,

          ID_Animazione, Animazione, AnimazioneNome, Animazione_Web_Link, Animazione_JPG,
          Animazione_Facebook_Link, Animazione_Myspace_Link, Animazione_Twitter_Link, Animazione_Miglior_Link, Animazione_GooglePlus_Link,

          ID_ilMeteo as meteo_id,
          JPG_Miglior_Link as image_hi, DataInizio, DataFine, OraInizio, Annullato, OraFine, GPS_L, NomeLuogo, Localita");








