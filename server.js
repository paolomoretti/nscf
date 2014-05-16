// Piccolo server solo per attivita' di sviluppo

var express = require('express');
var app = express();

app.use(express["static"](__dirname + '/'));
app.listen(8000);

console.log("Node started!!");
