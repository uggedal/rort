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
      callback(xhr);
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

  function setupContainer() {
    $('#frontpage .mainnewsspot').prepend(ele("div id='activity-list'", ''));
  }

  function insertError(msg) {
    $('#activity-list').append(ele("div id='errors'", msg));
  }

  function setupActivities() {
    $('#activity-list').append(ele("ul id='activities'", ''));
  }

  function insertActivity(activity) {
    $('#activities').append(ele('li', activity));
  }

  function display(res) {
    if (res.status != 200)
      insertError('Unknown person: ' + ele('em', user));
    else
      displayActivities(res.responseText);
  }

  function displayActivities(data) {
    var parsed = parseJson(data);

    if (parsed.length > 0) {
      setupActivities();

      $.each(parsed, function() {
        formatActivity(this);
      });
    } else {
      insertError("Either you don't have any favorites " +
                  'or your favorites are not doing anything interesting');
    }
  }

  function formatActivity(activity) {
    lastActivityDate = '';

    if (lastActivityDate != activity.date)
      insertActivity(ele('h3', activity.date));

    lastActivityDate = activity.date;

    switch (activity.type) {
      case 'blog':
        var blog = ele('a href=' + activity.author_url,
                       ele('em', activity.author)) +
                       ' blogget om ' +
                       ele('a href=' + activity.url, activity.title) +
                       ' klokken ' + activity.time;
        insertActivity(blog);
      case 'concert':
        var concert = ele('a href=' + activity.artist_url,
                          ele('em', activity.artist)) +
                          ' holdt konsert i ' + activity.location +
                          ': ' + activity.title;
        insertActivity(concert);
      default:
        insertActivity('Unknown activity type');
    }
  }

  setupContainer();

  get('http://rort.redflavor.com/?favorites=' + user, display);
}
