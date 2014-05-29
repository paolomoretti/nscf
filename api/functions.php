<?php

Flight::map("toKeyValue", function ($text) {
  return str_replace(" ", "_", $text);
});

Flight::map("getWeekendDates", function () {
  if (date("w", time()) < 6) { // Non siamo ancora weekend
    $startDate = date("Ymd", strtotime("next saturday"));
    $endDate = date("Ymd", strtotime("next sunday"));
  } else {
    if (date("w", time()) == 6) {
      $startDate = date("Ymd", time());
      $endDate = date("Ymd", strtotime("next sunday"));
    } else
      $startDate = $endDate = date("Ymd", time());
  }
  return array(
    "start" => $startDate,
    "end"   => $endDate
  );
});

Flight::map("cache", function ($key, $callback, $expire) {
  if ($entries = apc_fetch(md5($key)))
    return $entries;

  $return = $callback($key);
  apc_add(md5($key), $return, ($expire == null) ? 60*60*2 : $expire);  // Cache for 2 hours
  return $return;

});

Flight::map("query", function ($sql) {
  if (isset($_REQUEST['debug']))
    return array("sql" => $sql);
  
  return Flight::cache($sql, function ($sql) {
    $context  = stream_context_create(array(
      'http' => array(
        'method'  => 'POST',
        'header'  => 'Content-type: application/x-www-form-urlencoded',
        'content' => http_build_query( array('sql'=>$sql))
      )
    ));
    return json_decode(file_get_contents("http://www.nonsocosafare.it/api/run.asp", true, $context));
  }, 60*60*2);
});