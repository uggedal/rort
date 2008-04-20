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

function ele(tag, content) {
  var closeTag = tag.match(/^(\w+)/)[1];
  return '<'+tag+'>'+content+'</'+closeTag+'>';
}

// jQuery enabled scope
function withJQuery() {

  var userHref = $('ul#loggedinuser > li.item > a:first').attr('href');
  var user = userHref.match(/\/Person\/(\w+)/)[1];

  function setup() {
    $('#frontpage .mainnewsspot').prepend(ele("ul id='activities'", ''));
  }

  function insertActivity(activity) {
    $('#activities').append(activity);
  }

  function displayActivities(data) {
    setup();

    var parsed = parseJson(data);

    if (parsed.status == 200) {
      var data = parsed.body;
      $.each(data, function() {
        formatActivity(this);
      });
    } else {
      display('Connection error');
    }
  }

  function formatActivity(activity) {
    lastActivityDate = '';
    if (activity.type == 'blog') {
      if (lastActivityDate != activity.date) {
        insertActivity(ele('h3', activity.date));
      }
      lastActivityDate = activity.date;
      var blog = ele('li',
                 ele('em', activity.author) +
                 ' blogget om ' +
                 ele('a href=' + activity.url, activity.title) +
                 ' klokken ' + activity.time);
      insertActivity(blog);
    }
  }

  get('http://rort.redflavor.com/artists/' + user + '/favorites',
      displayActivities);
  
}
