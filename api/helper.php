<?php

Flight::map("toKeyValue", function ($text) {
  return str_replace(" ", "_", $text);
});

Flight::map("query", function ($sql) {
  if ($entries = apc_fetch(Flight::toKeyValue($sql)))
    return $entries;

  $context  = stream_context_create(array(
    'http' =>	array(
      'method'  => 'POST',
      'header'  => 'Content-type: application/x-www-form-urlencoded',
      'content' => http_build_query( array('sql'=>$sql))
    )
  ));
  $entries = json_decode(file_get_contents("http://www.nonsocosafare.it/api/run.asp", true, $context));
  $entries["cached"] = false;

  apc_add( Flight::toKeyValue($sql), $entries, 60*60*2);  // Cache for 2 hours
  return $entries;

});
