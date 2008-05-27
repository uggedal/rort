// ==UserScript==
// @name           Rørt
// @version        0.2.0
// @author         Eivind Uggedal <eu@redflavor.com>
// @namespace      http://redflavor.com/
// @description    Rører ved Urørt
// @include        http://redflavor.com/urort.html
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
    onload: function(xhr) {
      callback(xhr);
    }
  });
}

// Scope where jQuery is enabled
function withJQuery() {

  var email = '#/#/#/#/#/'
  var uri = 'http://rort.redflavor.com/';

  var userHref = $('#loggedinmenu > #menuItems1 li.item > a:first')
                   .attr('href');

  // Return silently if the user is not logged in
  if (userHref == undefined)
    return;

  var user = userHref.match(/\/Person\/(\w+)/)[1];

  // String interpolation with {}. Partly taken from Remedial
  // by Douglas Crockford (http://javascript.crockford.com/remedial.html)
  String.prototype.i = function (obj) {
    // Interpolate with all arguments as an array or a object
    if (typeof arguments[0]  == 'string')
      var arg = arguments;
    else
      var arg = obj;

    return this.replace(/{([^{}]*)}/g,
      function (a, b) {
        var r = arg[b]; 
        return typeof r === 'string' || typeof r === 'number' ? r : a;
      }
    );
  };

  function parseJson(data) {
    return eval('({0})'.i(data));
  }

  // Create a HTML element (can include attributes) with closing tag
  function ele(tag, text) {
    var closeTag = tag.match(/^(\w+)/)[1];
    if (text == undefined)
      return '<{0}>'.i(tag);
    else
      return '<{0}>{1}</{2}>'.i(tag, text, closeTag);
  }

  // Quotes a text with proper quotes: ``text''
  function quote(text) {
    return '&#8220;{0}&#8221;'.i(text)
  }

  // Sets a global css style
  function setStyle(css) {
    $('head').append(ele('style type="text/css"', css));
  }

  function setupContainer() {
    $('#frontpage .mainnewsspot').prepend(ele("div id='activity-list'", ''));
    $('#activity-list').append(ele("h2", 'Siste fra dine Favoritter'));
  }

  function insertError(msg) {
    $('#activity-list').append(ele("div id='errors'",
                               icon(errorIcon()) + msg));
  }

  function setupExcludes() {
    $('#activity-list').append(ele('h3', 'Dine favoritter'));
    $('#activity-list').append(ele("ul id='excludes'", ''));
    $('#activity-list').append(ele('p',
      'Bruk pekerne til dine favoritter for &aring; holde seg ' +
      'oppdatert med hva de foretar seg.'));
  }

  function setupDocumentation() {
    $('#activity-list').append(ele('h3', 'Hjelp'));
    $('#activity-list').append(ele('p',
      ele('a href="{0}doc/favorites.html"'.i(uri),
      'Hva er favoritter?')));
    $('#activity-list').append(ele('p',
      ele('a href="{0}doc/uninstall.html"'.i(uri),
      'Hvordan fjerner jeg {0}?'.i(quote('Siste fra dine Favoritter')))));
  }

  function insertExclude(exclude) {
    $('#excludes').append(ele('li', exclude));
  }

  function display(res) {
    switch (res.status) {
      case 200:
        displayActivities(res.responseText);
        break;
      case 403:
        var usrEle = ele('em', user);
        insertError('Ukjent bruker {0}.'.i(usrEle));
        break;
      default:
        insertError('Tilkoblingsproblemer.');
        break;
    }
    removeLoadingStatus();
  }

  function displayActivities(data) {
    var parsed = parseJson(data);

    if (parsed.length > 0) {
      setupExcludes();
      insertExcludesList(parsed);
    } else {
      insertError('Du har ingen favoritter.');
    }
    setupDocumentation();
  }

  function insertExcludesList(excludes) {
    for (var i = 0; i < excludes.length; i++) {
      var exclude = excludes[i];

      insertExclude(ele('a href="{artist_url}"'.i(exclude), exclude.artist));
    }
  }

  function insertLoadingStatus() {
    $('#activity-list').append(ele('div id="load-status"',
      ele('img alt="Loading" src="{0}"'.i(loadingImage())) +
      ele('p', 'Henter dine favoritter...')));
  }

  function removeLoadingStatus() {
    $('#activity-list > #load-status').hide();
  }

  setStyle(rortStyle());

  setupContainer();

  insertLoadingStatus();

  get('{0}api/favorites?slug={1}&email={2}'.i([uri, user, email]), display);
}

function rortStyle() {
  return '#load-status, #load-status > p { text-align: center; }' +
         'img.icon { margin: 0 8px -4px -24px; }' +
         '#activity-list { margin: 0 0 0 34px; }' +
         '#activity-list a { color: blue; text-decoration: none; }' +
         'a#more-events { color: #b33633; text-decoration: underline; }' +
         'ul#activities, ul#excludes { list-style-type: none;' +
                                      'margin: 0 0 20px 0;}' +
         'ul#activities li { margin: 0 0 10px 0; }' +
         'ul#activities blockquote { margin: 10px 0 0 20px; ' +
                                    'font-style: italic; }' +
         '#activity-list h3 { margin:15px 0 5px 0; }'
}

function loadingImage() {
  return "data:image/gif,GIF89a%20%00%20%00%F7%00%00%FF%FF%FF%B3%B3%B3%FB%FB%FB%D6%D6%D6%E1%E1%E1%F2%F2%F2%BA%BA%BA%81%81%81444%01%01%01%1B%1B%1B%C4%C4%C4%97%97%97%FD%FD%FDTTT%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00!%FF%0BNETSCAPE2.0%03%01%00%00%00!%F9%04%05%0A%00%00%00%2C%00%00%00%00%20%00%20%00%00%08%FA%00%01%08%1CH%90%E0%82%03%0B%0A*%5C%C8p%E0%81%87%05%09%14h%A8p%80%81%82%0F%0F%10%1C%C0%91%22%C1%02%0F%03%10%CC8%B0%00%C7%01%1EG%3ED)%90%A4%C0%93%04R%0E4%F0%90%81C%88%00%08%9C%94I%90%C1%C3%8B%00%5C%C2%E49p%C0%01%9F%13%1F%3A%C8%B9s%A0%CE%011_2%60%90p%60%80%9F%0Au%96%3C%09u%E0%82%A9SY%1A%AD%DA%90k%C7%9E%60%A7F%F5hv%ED%C6%B46S%3Eu%BB%F0%2B%03%96ry%12%00J%B4%2FQ%B3%1CM.0%40%B8p_%C0%1C%0B%2B%E6%2B%F3%E4%02%98%03%06%2F%F6KY%26%5D%8A%97%19%CE%F5%B89%A5%D9%89%0AMr%E5%09%B8%60i%CCx%9Fr%5C%AB%BA%EB%CB%CB%AA%09vf%EA%FA%E5j%00MO%82%26*Z%EC%D9%D8%87o%E3%3E%3B%BC%B6%DC%A6%C5%9D%22%F7%2C%3CyQ%E2%CC%F1%3Aw%9A%99a%01%BA%CB%2Bg5N1%20%00!%F9%04%05%0A%00%00%00%2C%00%00%00%00%18%00%12%00%00%08%80%00%01%08%1CH%B0%20%80%01%06%13*d%00%80!A%03%0B%14FT8%90%C1%81%03%09%19h%2C%E8P%E0%82%8B%18%0Dj%EC%98%10%A4%81%84%0B6%12%ECh%00%24%C5%86%0C%26%12%24%00Rf%C6%86%04%04Zl%E8R%20%01%03%06%10VTY%B0eN%81%03%80%02%3DJ%80%81%D0%97H%95B%2C%005%E1O%A9U%15%26%3D%99Ua%81%A7%5D%C3z%1D%40%B6%2C%D8%AAf%CD%8A%25PvAY%B1%01%01%00!%F9%04%05%0A%00%00%00%2C%01%00%00%00%1D%00%0E%00%00%08%89%00%01%08%1CHp%E0%00%06%05%13*%5C(%10a%C2%01%0C%07%12%80H%90%81E%82%01%22%124%60%80bC%00%0E%01P%0C%C9%90%A3%01%02%03-%86%24%A9q%80%C9%94%0AY2%5C%C0q%E4%C5%02%20E%16%C4%A9%90%80I%9C%08%11%1A%F88%D0%C0%81%03C%07%0C%409%90f%00%8FM%09.8z%F4%A4R%A5%3C%0B%0C%8Dx%90%EAQ%83W%090%D5%E8%F5%00T%91W%CF.4z%20cO%A5c52%88%9BP%ACF%8D%01%01%00!%F9%04%05%0A%00%00%00%2C%07%00%00%00%19%00%11%00%00%08%81%00%01%08%1C%08%80%80%01%82%08%13*%04%B0%C0%C0%02%84%0F%17%16%20%80%D0%80E%82%0C2.%1C0%A0%E2%C5%81%1A7r%2C0%D0%E2A%90%0C%22%26%24%C0%B1%A3%40%93%02%17%84%5C%08%A0%25E%000%090%00%B0%93%A6%40%9B8%3F%CED%E8%F2'%C7%9B%04%07%F4%AC%B94%E1%00%A4%0A%91%EE%0C%E0%93f%CF%A6U!%C6%CC%EA%D3%00I%AE%60%C3%26%3C%40%B6%EC%01%95%60%CD%9A%15%0B%80%AC%03%B3%0B%02%02%00!%F9%04%05%0A%00%00%00%2C%0E%00%00%00%12%00%18%00%00%08%82%00%01%2C%20%00%A0%A0%C1%83%08%07%2C%40%08%60%00A%86%02%17%2C4%B8%C0%80%01%88%11'%02%20%60%F1%22D%89%1A%3B%0E%C0%08%B2%E0%80%8E%183%02(%D0%F1%E1G%89%0D%03%18%D0(%90%01%83%94%06%0A%1C%B4%C9%80%26F%9B%00%80%A6%0C%1A%F4%E6%D0%9DF%8F%1Et%A9%B4i%D3%A4)oJuz%C0%20%83%91N%9B%1A%60z%D4%C0%81%03%01%A8~%FD%EA%13%E2%00%06c%0F%40%C5%99%D6%A3%D2%00d%01%04%04%00!%F9%04%05%0A%00%00%00%2C%0E%00%00%00%12%00%1E%00%00%08%99%00%01%0C(%00%A0%A0%C1%83%08%05%0EH%C8%B0%E0%80%87%07%07%2CX%D0%F0%E1B%83%13%2F%26%B4hP%22%C5%8A%10%0BN%FC%C8%90%23%80%91%0D%1D%86%CC%18%D1%80%01%02%0C%09h%24%E0%D2%A5%C6%86%0Bj%1A%20%D9P%E7%CB%94%1Dm%02E8p%A8Q%A3%0C%92*%15%08%94%01%00%A7P%9D%A6%5C%9A%F4%A8%D5%83%04%AD~4p%D5%20%83%9B%0D%09%0488%96%A1%81%030%05Vm%C8%E0%80%DB%83%06%9C%82%05%40%C0%ED%01%9E%40%CF%BE%B5j%97%EB%D1%01v%AF%DA%CDz%D4%25%C3%80%00!%F9%04%05%0A%00%00%00%2C%0F%00%01%00%11%00%1F%00%00%08%8C%00%01%08%1C%08%80%40%01%82%08%13%0E%18%90%B0a%81%85%0D%23.%24%10%91%20%81%85%0C%2B%0A%BC%08Q%E3%C6%8E%039z%14%88q%00%C5%8A%1C1j%2C%99Q%23%C7%93%23%09%C0%1CI%13%A1%81%9B8%17h%C4%C9%D3%40%C5%9E%06t%D6%1CJs%00%03%06B%3D%1E%3DZs%E9%D2%86%3A%5B%0A%3C%9AT%A0O%A6%03u2%10x%A0%2B%80%83%24%23v%3D%40%10k%C2%B1%03%B7VDK%93%EDT%B5g%0F8P%D8%D0%AD%C7%05%07%AAj%0C%08%00!%F9%04%05%0A%00%00%00%2C%08%00%0E%00%18%00%12%00%00%08%7D%00%01%08%1CH%B0%20%80%01%08%13%0E(%60%B0%E1%40%85%0A%1D%3AL%B8%20!%01%89%183b%1C%A01%A3%01%03%1C%3B%1A%FCH%F2%A2%C8%81%05%16%904%B0%40%E4%00%06%26%09%AC%0Cy%F0%80%81%86%0C%0C%0E%F8h%12%00%83%03%07r%12%24%C0%A0(%C6%05%40%0F%98%14%0A%60%01S%87Io%3A%2C%DArdR%82O%7D%1A5%98%B4*%C6%AC%02%AFb%3DP%D0kY%A9%03s%82%3DI%B3c%40%00!%F9%04%05%0A%00%00%00%2C%02%00%12%00%1D%00%0E%00%00%08%89%00%01%08%1CH%B0%A0A%00%04%0E%12%24%C0%40%A1A%02%03%06%24%3Ch%E0%C0%01%03%0E%09F%DCX%40%A3%C5%8F%195n%8C(%90%C1%C7%03%0C%06d%24%80q%E0H%96'%5B%26%5C%60p%80%01%034%07BTY%F1%40%00%82%3F%01%60d%40%14%40%81%9B%06%26%3E%2C%A8%12%40C%A7P%01%D8%BC%19r%E0S%82E%05.%B8%D9%B4jT%A8WYR%0DY%B4%2B%D1%AB%00%B6%B6%AC%8A%16%ADK%A5%0E%BBb%0D%EA%95%ED%DA%8C%01%01%00!%F9%04%05%0A%00%00%00%2C%00%00%0F%00%19%00%11%00%00%08%80%00%17%1C%18H%F0%00%80%83%08%13*%3CX%B0%E0%C2%87%09%05%12t0%10%A2%C5%8B%181%160%90%B1%E3%82%8E%0F%19%80%84%18%20a%00%02%18%07%40d%C0%40%E5%C1%96%0B%09%0C%98%99%D0%25G%84%2CE%020%C0%13%80%CC%99%05%12%06U%C8%12!%CF%9B%3F%5DZd%F9qg%CF%833%07%A0%7C%B8%A0%A8%D1%A7Pi.Mx%B4%A6%D6%85V%AF%DED8%15bS%84%0B%0C%9C%1D%A9%D0%40%D9%84%01%01%00!%F9%04%05%0A%00%00%00%2C%01%00%08%00%11%00%18%00%00%08w%00%07%1C8%60%00%80%C1%83%08%0F%1A%188pA%C2%87%00%18%0Ed0%00%22%C2%05%12%0FXL%18%60%60%C1%8D%1CA%8A%1CI%B2%A4%C9%93(7.%60%C0%A0%24K%96%20_%BE%04%B9%B2%25%C2%02%1F%1F%B2txp%81%01%03%15%07%085H%20!%81%9F%06%0A%00%10Z%11%22%D2%A6L!%0E%40z0%EAC%A4E%0DZM%F8%B3%A9%D6%A1%0F%09x%FD%3A%16%A4X%00%01%01%00!%F9%04%05%0A%00%00%00%2C%00%00%02%00%0E%00%1D%00%00%08%8A%00%01%08%1C%08%60%81%01%82%08%07%1E8%C0%20!%C2%85%07%068%1C%18%00%E2D%85%0B%0F%5E%5C%60%91%60C%82%10%3Fz%94%08%80%C0%81%00%04Q%8A%240q%C0G%91%13%17%08%94y%11%40%01%8D5%5B2%D8%C9%13%A6%C0%9E%3D%13%BA%DC%09%80g%CE%A3%08I%5E%1C%60%C0%80R%84%04%9AJuhP%EA%82%02B%AD%0E%240%00%AB%C0%A8N%09%0E%18%CBR%A0%D7%81%05%C6%0E(%EBP-%DB%84%5C%C7%D6T%9BSn%CE%02o%03%02%00%3B";
}
