// ==UserScript==
// @name           Rørt
// @version        0.2.0
// @author         Eivind Uggedal <eu@redflavor.com>
// @namespace      http://redflavor.com/
// @description    Rører ved Urørt
// @include        http://www11.nrk.no/urort/default.aspx
// ==/UserScript==

// Add jQuery
var GM_JQ = document.createElement('script');
GM_JQ.src = 'http://code.jquery.com/jquery-latest.pack.js';
GM_JQ.type = 'text/javascript';
document.getElementsByTagName('head')[0].appendChild(GM_JQ);

// Check if jQuery is loaded
function GM_wait() {
  if (typeof unsafeWindow.jQuery == 'undefined') {
    window.setTimeout(GM_wait,100);
  } else {
    $ = unsafeWindow.jQuery; withJQuery();
  }
}

GM_wait();

// Cross-domain ajax get request with callback
function get(url, callback) {
  GM_xmlhttpRequest({
    method: "GET",
     url: url,
     onload: function(xhr) { callback(xhr.responseText); }
  });
}

// jQuery enabled scope
function withJQuery() {

  function display(text) {
    $('#frontpage .mainnewsspot').prepend(text);
  }

  var user = $('ul#loggedinuser > li.item > a:first').attr('href');
  display(user);

  get('http://roert.redflavor.com/', display);
}
