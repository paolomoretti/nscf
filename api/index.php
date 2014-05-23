<?php
require 'flight/Flight.php';
require 'config.php';
require 'functions.php';

Flight::route('GET /events', function() {
  $sql = "SELECT id, NomeEventoSuperEsteso as nome, luogo, data, JPG_Miglior_Link as img FROM Query_Dettaglio WHERE Annullato=0 AND DaIeri='Si';";
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




Flight::start();


