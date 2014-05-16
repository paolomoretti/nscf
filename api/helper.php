<?php

Flight::map("query", function ($sql) {
  Flight::etag(date("Y-m-d"));

  $context  = stream_context_create(array(
    'http' =>	array(
      'method'  => 'POST',
      'header'  => 'Content-type: application/x-www-form-urlencoded',
      'content' => http_build_query( array('sql'=>$sql))
    )
  ));

  return json_decode(file_get_contents("http://www.nonsocosafare.it/api/run.asp", true, $context));
});