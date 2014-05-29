<?php
require 'flight/Flight.php';
require 'config.php';
require 'functions.php';

Flight::route('GET /events', function() {
  $sql = "SELECT " . Flight::get("event_fields") . " FROM Query_Dettaglio WHERE Annullato=0;";
  $data = Flight::query($sql);

  Flight::json($data);
});

Flight::route('GET /events/today', function() {
  $sql = "SELECT " . Flight::get("event_fields") . " FROM Query_Dettaglio WHERE Annullato=0 AND DataInizio < now() AND DataFine >= now();";
  $data = Flight::query($sql);

  Flight::json($data);
});

Flight::route('GET /events/@id', function($id) {
  $sql = "SELECT " . Flight::get("event_fields") . " FROM Query_Dettaglio WHERE id=$id";
  $data = Flight::query($sql);

  Flight::json($data);
});

Flight::route('GET /events/search/@key', function($key) {
  $sql = "SELECT " . Flight::get("event_fields") . " FROM Query_Dettaglio WHERE NomeEventoSuperEsteso LIKE '%$key%'";
  $data = Flight::query($sql);

  Flight::json($data);
});

Flight::route('GET /events/@id/image', function($id) {
  $sql = "SELECT " . Flight::get("event_fields") . " FROM Query_Dettaglio WHERE id=$id";
  $data = Flight::query($sql);
  $event = $data[0];

  $imageUri = $_SERVER["DOCUMENT_ROOT"]."/assets/images/events/".md5($event->image_hi);
  if(!is_file($imageUri)) {
    try {
      copy($event->image_hi, $imageUri);
    } catch (Exception $e) {}
  }

  $fp = fopen($imageUri, 'rb');

  header("Content-Type: image/png");
  header("Content-Length: " . filesize($imageUri));
  fpassthru($fp);
  exit;

});

Flight::route('GET /events/filter/weekend', function() {
  $weekendDates = Flight::getWeekendDates();
  $sat = Flight::query( "SELECT " . Flight::get("event_fields") . " FROM Query_Dettaglio WHERE Annullato=0 AND DTSTART >= {$weekendDates["start"]} AND DTFINE <= {$weekendDates["start"]};" );
  $sun = Flight::query( "SELECT " . Flight::get("event_fields") . " FROM Query_Dettaglio WHERE Annullato=0 AND DTSTART >= {$weekendDates["end"]} AND DTFINE <= {$weekendDates["end"]};" );

  Flight::json(array(
    "saturday" => $sat,
    "sunday" => $sun
  ));
});

Flight::route('GET /events/filter/region/@id', function($id) {
	$sql = "
		SELECT ".Flight::get("event_fields")." 
		FROM Query_Dettaglio 
		WHERE ID_Regione=$id;
	";
	$data = Flight::query($sql);

	Flight::json($data);
});

Flight::route('GET /events/filter/prov/@id', function($id) {
	$sql = "
		SELECT ".Flight::get("event_fields")." 
		FROM Query_Dettaglio 
		WHERE ID_Provincia=$id;
	";
	$data = Flight::query($sql);

	Flight::json($data);
});

Flight::route('GET /container/events', function() {
	$nscf_container['events'] = array();
	
	$sql = "
		SELECT TOP 10 id, NomeEventoSuperEsteso, luogo, data, JPG_Miglior_Link 
		FROM Query_Dettaglio 
		WHERE Annullato=0 AND DaIeri='Si' AND (Query_Dettaglio.Pross30g)='si';
	";
	$data = Flight::query($sql);
	
	foreach ($data as $key => $event) {
		$nscf_container['events'][$event->id]["name"] = $event->NomeEventoSuperEsteso;
		$nscf_container['events'][$event->id]["location_raw"] = $event->luogo;
		$nscf_container['events'][$event->id]["when_raw"] = $event->data;
		$nscf_container['events'][$event->id]["img_link"] = $event->JPG_Miglior_Link;
	}

	Flight::json($nscf_container);
});

Flight::route('GET /container/events/@id', function($id) {
	$nscf_container['events'] = array();
	$nscf_container['locations'] = array();

	$sql = "
		SELECT id, NomeEventoSuperEsteso, luogo, data, EM, ES, FI, MM, SP, FE, Indirizzo, Evento_Web_Link, Evento_Facebook_Link, NSCF_Link, 
			Evento_Myspace_Link, Evento_Twitter_Link, Luoghi_Web_Link, Luoghi_Facebook_Link, Luoghi_Myspace_Link, Luoghi_Twitter_Link, 
			Luoghi_GooglePlus_Link, Evento_GooglePlus_Link, Luoghi_Foursquare_Link, Evento_Foursquare_Link, Luoghi_JPG, ID_ilMeteo, 
			JPG_Miglior_Link, ID_Luogo, DataInizio, DataFine, OraInizio, Annullato, OraFine, GPS_L, NomeLuogo, Localita 
		FROM Query_Dettaglio 
		WHERE id=$id;
	";
	$data = Flight::query($sql);
	
	foreach ($data as $key => $event) {
		$nscf_container['events'][$event->id]["name"] = $event->NomeEventoSuperEsteso;
		$nscf_container['events'][$event->id]["location_raw"] = $event->luogo;
		$nscf_container['events'][$event->id]["location_id"] = $event->ID_Luogo;
		$nscf_container['events'][$event->id]["when"]["start_date"] = $event->DataInizio;
		$nscf_container['events'][$event->id]["when"]["stop_date"] = $event->DataFine;
		$nscf_container['events'][$event->id]["when"]["start_time"] = $event->OraInizio;
		$nscf_container['events'][$event->id]["when"]["stop_time"] = $event->OraFine;
		$nscf_container['events'][$event->id]["img_link"] = $event->JPG_Miglior_Link;
		if ( $event->EM ){$nscf_container['events'][$event->id]["tags"][] = "EM";}
		if ( $event->ES ){$nscf_container['events'][$event->id]["tags"][] = "ES";}
		if ( $event->FI ){$nscf_container['events'][$event->id]["tags"][] = "FI";}
		if ( $event->MM ){$nscf_container['events'][$event->id]["tags"][] = "MM";}
		if ( $event->SP ){$nscf_container['events'][$event->id]["tags"][] = "SP";}
		if ( $event->FE ){$nscf_container['events'][$event->id]["tags"][] = "FE";}
		if ( $event->Annullato ){
			$nscf_container['events'][$event->id]["canceled"] = 1;
		}else{
			$nscf_container['events'][$event->id]["canceled"] = 0;
		}
		if ( $event->Evento_Web_Link ) $nscf_container['events'][$event->id]["link"][] = $event->Evento_Web_Link;
		if ( $event->Evento_Facebook_Link ) $nscf_container['events'][$event->id]["link"][] = $event->Evento_Facebook_Link;
		if ( $event->Evento_Myspace_Link ) $nscf_container['events'][$event->id]["link"][] = $event->Evento_Myspace_Link;
		if ( $event->Evento_Twitter_Link ) $nscf_container['events'][$event->id]["link"][] = $event->Evento_Twitter_Link;
		if ( $event->Evento_GooglePlus_Link ) $nscf_container['events'][$event->id]["link"][] = $event->Evento_GooglePlus_Link;
		if ( $event->Evento_Foursquare_Link ) $nscf_container['events'][$event->id]["link"][] = $event->Evento_Foursquare_Link;
		if ( $event->NSCF_Link ) $nscf_container['events'][$event->id]["link"][] = $event->NSCF_Link;

		$nscf_container['locations'][$event->ID_Luogo]['name'] = $event->NomeLuogo;
		$nscf_container['locations'][$event->ID_Luogo]['address'] = $event->Indirizzo;
		$nscf_container['locations'][$event->ID_Luogo]['gps'] = $event->GPS_L;
		$nscf_container['locations'][$event->ID_Luogo]['locality_raw'] = $event->Localita;
		if ( $event->Luoghi_Web_Link ) $nscf_container['locations'][$event->ID_Luogo]["link"][] = $event->Luoghi_Web_Link;
		if ( $event->Luoghi_Facebook_Link ) $nscf_container['locations'][$event->ID_Luogo]["link"][] = $event->Luoghi_Facebook_Link;
		if ( $event->Luoghi_Myspace_Link ) $nscf_container['locations'][$event->ID_Luogo]["link"][] = $event->Luoghi_Myspace_Link;
		if ( $event->Luoghi_Twitter_Link ) $nscf_container['locations'][$event->ID_Luogo]["link"][] = $event->Luoghi_Twitter_Link;
		if ( $event->Luoghi_GooglePlus_Link ) $nscf_container['locations'][$event->ID_Luogo]["link"][] = $event->Luoghi_GooglePlus_Link;
		if ( $event->Luoghi_Foursquare_Link ) $nscf_container['locations'][$event->ID_Luogo]["link"][] = $event->Luoghi_Foursquare_Link;
		if ( $event->Luoghi_JPG ) $nscf_container['locations'][$event->ID_Luogo]["link"][] = $event->Luoghi_JPG;
		// $nscf_container['locations'][$event->ID_Luogo]['ilMeteo_id'] = $event->ID_ilMeteo;
	}
	
	Flight::json($nscf_container);
});


Flight::start();


