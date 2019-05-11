'use strict';

require('./index.html');
require('./scss/main.scss');
require('./img/logo.png');

const Elm = require('./elm/App/Main.elm');
Elm.Elm.App.Main.init({flags: 1, node: document.getElementById("main")});