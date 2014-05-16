<?php
header("Content-Type: text/html; charset=utf-8");

/*     --------------  HELP  -----------------------
es:
responder_r00.php?get=event_id&id=42789
responder_r00.php?get=events

*/

ini_set( 'display_errors','1');
error_reporting(E_ERROR | E_WARNING | E_PARSE | E_NOTICE);

function responder_print($responder){
	if ( isset($_GET['debug']) ){
		echo "<pre>";
		print_r($responder);
		echo "</pre>";
	}else{
		echo json_encode($responder);
	}
}

function open_on_run($sql){
	$opts = array('http' =>	array('method'  => 'POST','header'  => 'Content-type: application/x-www-form-urlencoded','content' => http_build_query( array('sql'=>$sql))));
	$context  = stream_context_create($opts);
	$str_data = file_get_contents("http://www.nonsocosafare.it/api/run.asp", true, $context);
	return json_decode($str_data);
}

function unicode_decode($str){ 
	return preg_replace("/\\\\u([0-9a-f]{3,4})/i","&#x\\1;",$str);
    // return preg_replace("/\u([0-9A-F]{4})/ie", "hex2str(\"$1\")", $str); 
}

//$nscf_container['events'] = array();
//$nscf_container['locations'] = array();
//$nscf_container['animations'] = array();
//$nscf_container['users'] = array();
//$nscf_container['links'] = array();

switch (@$_GET['get']) {
	case "events":
		$nscf_container['events'] = array();
		
		$sql = "
			SELECT id, NomeEventoSuperEsteso, luogo, data, JPG_Miglior_Link 
			FROM Query_Dettaglio 
			WHERE Annullato=0 AND DaIeri='Si';
		";
		//$nscf_container['events'] = open_on_run($sql);
		
		foreach (open_on_run($sql) as $key => $event) {
			$nscf_container['events'][$event->id]["name"] = $event->NomeEventoSuperEsteso;
			$nscf_container['events'][$event->id]["location_raw"] = $event->luogo;
			$nscf_container['events'][$event->id]["when_raw"] = $event->data;
			$nscf_container['events'][$event->id]["img_link"] = $event->JPG_Miglior_Link;
		}
		break;
	case "event_id":
		$nscf_container['events'] = array();
		$nscf_container['locations'] = array();
		
		if ( isset($_GET['id']) ){
			$sql = "
				SELECT id, NomeEventoSuperEsteso, luogo, data, EM, ES, FI, MM, SP, FE, Indirizzo, Evento_Web_Link, Evento_Facebook_Link, NSCF_Link, 
					Evento_Myspace_Link, Evento_Twitter_Link, Luoghi_Web_Link, Luoghi_Facebook_Link, Luoghi_Myspace_Link, Luoghi_Twitter_Link, 
					Luoghi_GooglePlus_Link, Evento_GooglePlus_Link, Luoghi_Foursquare_Link, Evento_Foursquare_Link, Luoghi_JPG, ID_ilMeteo, 
					JPG_Miglior_Link, ID_Luogo, DataInizio, DataFine, OraInizio, Annullato, OraFine, GPS_L, NomeLuogo, Localita 
				FROM Query_Dettaglio 
				WHERE id=".$_GET['id'].";
			";
			//$nscf_container['events'] = open_on_run($sql);
			
			foreach (open_on_run($sql) as $key => $event) {
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
		}
		break;
}

responder_print($nscf_container);
?>
