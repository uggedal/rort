// ==UserScript==
// @name           Rørt
// @version        0.2.0
// @author         Eivind Uggedal <eu@redflavor.com>
// @namespace      http://redflavor.com/
// @description    Rører ved Urørt
// @include        http://redflavor.com/urort.html
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
    onload: function(xhr) {
      callback(xhr.responseText);
    }
  });
}

function parseJson(data) {
  return eval("(" + data + ")");
}

// jQuery enabled scope
function withJQuery() {

  var userHref = $('ul#loggedinuser > li.item > a:first').attr('href');
  var user = userHref.match(/\/Person\/(\w+)/)[1];

  function display(text) {
    $('#frontpage .mainnewsspot').prepend(text);
  }

  function displayActivities(data) {
    var parsed = parseJson(data);

    if ( parsed.status == 200 ) {
      data = parsed.body;
      $.each(data, function() {
        formatActivities(this);
      });
    } else {
      display('Connection error');
    }
  }

  function formatActivities(activities) {
    $.each(activities, function() {
      display('<p>'+this+'</p>');
    });
  }

  get('http://rort.redflavor.com/artists/' + user + '/favorites',
      displayActivities);
  
}
