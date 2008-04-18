// ==UserScript==
// @name           Rørt
// @version        0.2.0
// @author         Eivind Uggedal <eu@redflavor.com>
// @namespace      http://redflavor.com/
// @description    Rører ved Urørt
// @include        http://www11.nrk.no/urort/default.aspx
// ==/UserScript==

function get(url, callback) {
  GM_xmlhttpRequest({
    method: "GET",
     url: url,
     onload: function(xhr) { callback(xhr.responseText); }
  });
}
 
function display(text) {
  dummyDiv = document.createElement('div');
  dummyDiv.innerHTML = text;
  document.body.insertBefore(dummyDiv.firstChild, document.body.firstChild);
}

get('http://roert.redflavor.com/', display);
