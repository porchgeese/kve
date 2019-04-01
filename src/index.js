'use strict';

require('./index.html');
require('./scss/main.scss');

const Elm = require('./elm/Main.elm');
Elm.Elm.Main.init({node: document.getElementById("main")});