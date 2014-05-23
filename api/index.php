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

Flight::route('GET /events/filter/weekend', function() {
  $weekendDates = Flight::getWeekendDates();
  $sql = "SELECT " . Flight::get("event_fields") . " FROM Query_Dettaglio WHERE Annullato=0 AND DTSTART >= {$weekendDates["start"]} AND DTFINE <= {$weekendDates["start"]};";
//  $sql = "SELECT " . Flight::get("event_fields") . " FROM Query_Dettaglio WHERE Annullato=0 AND DT;";
  $data = Flight::query($sql);

  Flight::json($data);
});




Flight::start();


