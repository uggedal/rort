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

  var uri = 'http://rort.redflavor.com/';

  var userHref = $('ul#loggedinuser > li.item > a:first').attr('href');

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

  // Return a data: URI based icon
  function icon(data) {
    return ele('img class="icon" alt="" src="{0}"'.i(data));
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

  function setupActivities() {
    $('#activity-list').append(ele("ul id='activities'", ''));
  }

  function setupExcludes() {
    $('#activity-list').append(ele('h3', 'Favoritter uten nylig aktivitet'));
    $('#activity-list').append(ele("ul id='excludes'", ''));
  }

  function setupDocumentation() {
    $('#activity-list').append(ele('h3', 'Hjelp'));
    $('#activity-list').append(ele('p', ele('a href="{0}favorites"'.i(uri),
                                            'Hva er favoritter?')));
    $('#activity-list').append(ele('p', ele('a href="{0}uninstall"'.i(uri),
      'Hvordan fjerner jeg {0}?'.i(quote('Siste fra dine Favoritter')))));
  }

  function insertActivity(activity) {
    $('#activities').append(ele('li', activity));
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

    if (parsed.activities.length > 0) {
      setupActivities();
      insertActivitiesList(parsed.activities);

    } else {
      insertError('Du har ingen favoritter som har foretatt seg noe.');
    }

    if (parsed.excludes.length > 0) {
      setupExcludes();
      insertExcludesList(parsed.excludes);
    }
    setupDocumentation();
  }

  function insertExcludesList(excludes) {
    for (var i = 0; i < excludes.length; i++) {
      var exclude = excludes[i];

      insertExclude(ele('a href="{artist_url}"'.i(exclude), exclude.artist));
    }
  }

  // Global variable for the latest date
  lastActivityDate = '';

  function insertActivitiesList(data) {

    for (var i = 0; i < data.length; i++) {
      lastActivityDate = formatActivity(data[i], lastActivityDate);
    }
  }

  function formatActivity(act, lastDate) {

    if (lastDate != act.date)
      insertActivity(ele('h3', act.date));


    switch (act.type) {
      case 'blog':
        act.icon      = icon(blogIcon());
        act.art_link  = ele('a href="{artist_url}"'.i(act), act.artist);
        act.link      = ele('a href={url}'.i(act), act.title);
        act.sum_html  = ele('blockquote',
                              quote(act.summary));
        act.formatted = '{icon}{art_link} blogget om {link} {sum_html}'
                          .i(act);
        insertActivity(act.formatted);
        break;
      case 'concert':
        act.icon      = icon(concertIcon());
        act.art_link  = ele('a href="{artist_url}"'.i(act), act.artist);
        act.formatted = ('{icon}{art_link} holdt konsert: {location} ' +
                         '&mdash; {title}').i(act);
        insertActivity(act.formatted);
        break;
      case 'song':
        act.icon      = icon(songIcon());
        act.art_link  = ele('a href="{artist_url}"'.i(act), act.artist);
        act.link      = ele('a href={url}'.i(act), act.title);
        act.formatted = '{icon}{art_link} har lagt ut sangen {link}'.i(act);
        insertActivity(act.formatted);
        break;
      case 'review':
        if (act.rating == 1) {
          act.vote = 'elsker'; 
          act.icon      = icon(positiveReviewIcon());
        } else {
          act.vote = 'hater';
          act.icon      = icon(negativeReviewIcon());
        }

        act.rev_link  = ele('a href="{reviewer_url}"'.i(act), act.reviewer);
        act.link      = ele('a href={url}'.i(act), act.title);
        act.art_link  = ele('a href="{artist_url}"'.i(act), act.artist);
        act.com_html  = ele('blockquote', quote(act.comment));
        act.formatted =
          '{icon}{rev_link} {vote} sangen {link} av {art_link} {com_html}'
            .i(act);
        insertActivity(act.formatted);

        break;
      default:
        var actEle = ele('em', act.type);
        insertActivity('Ukjent aktivitet {0}'.i(actEle));
    }
    return act.date;
  }

  function insertLoadingStatus() {
    $('#activity-list').append(ele('div id="load-status"',
      ele('img alt="Loading" src="{0}"'.i(loadingImage())) +
      ele('p', 'Henter siste hendelser...')));
  }

  function removeLoadingStatus() {
    $('#activity-list > #load-status').hide();
  }

  setStyle(rortStyle());

  setupContainer();

  insertLoadingStatus();

  get('{0}api/?activities={1}'.i([uri, user]), display);
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

function errorIcon() {
  return "data:image/png,%89PNG%0D%0A%1A%0A%00%00%00%0DIHDR%00%00%00%10%00%00%00%10%08%06%00%00%00%1F%F3%FFa%00%00%00%06bKGD%00%00%00%00%00%00%F9C%BB%7F%00%00%00%09pHYs%00%00%0B%13%00%00%0B%13%01%00%9A%9C%18%00%00%00%07tIME%07%D5%0B%0A%092%0E%93S%B4%B0%00%00%02%1AIDAT8%CB%9D%93%BDO%93Q%14%C6%7F%F7m%0B%E5%A3%BE%A0%C4%1AM%A0h%9B%02%B6%0B%C4%94D%87%8E%BA2i%D2%81%11%FE%22%3B2tf%23%B2%90%40XD%070%92%16%9Ahc%F8%B0%24%A4-M%5B(%F6%3D%C7%E1%7DK%10%89%1AOrs%93%9B%F3%FC%9E%E49%F7%18nT%0ER%C0%3C%90%06%C6%BD%E7%12%B0%0E%2Ce%60%EBz%BF%B9!~%3B%1C%0A-L%26%93%04%C3a%7C%03%03%A8*%9D%B33%CE%CBe%8A%85%02%D5f3%9B%81%C5%DF%009x7%9DL%BE%1C%99%99%E1r%7B%1B%E7%F4%14%1C%07UE%0CXCw%F1OMR%DD%DD%E5S%B1%B8%9A%81W%00%BE%AE%F3t2%F9%FA%5E%2CF%7Bs%13m4%40%04UAEA%04i%B6%E8%1C%7C%A3%3F%16%C3%B6%AC%E8%8Bj%F5%C12%AC%98%1C%A4%86C%A1%F7%CF%E6%E6%B8X%5BC%9D%0E%AA%8A*%A8zb%05%C5%85%A91%04S)%3EolPk%B5f-%60~2%91%E0rg%07u%1C%10P%01%15q%0F%EA%81%14T%C1q%B8%C8%E7y%3C%16%01%98%F7%03%E9%60%F8%3E%3F%3E%7CDE%19%2B%7F%E7O%B5o%DFA%AA5%02%0F%1F%01%A4%FD%C0%B8%D5%3F%88%8A%1B%D8%DFJDQ%ED%60z%02%00%E3%16p%95%F6%BF%00%F0%FAT%05%00%3FP%EA%D4%CF%26%14%83%AA%C3%97%91%11%B7A%C4%BDQ7%3C7UD%DD%20%B5%D9%02(Y%C0%FA%F9%C9%09%C6%1E%BA%22%FF%22%EE%3A%8A'V%C1%1A%1C%A4%5D%AB%01%AC%5B%C0%D2%FE%DE%1E%81x%DC%25%CBu%917%3A%EDNCPc%F0G%22%94%0E%0F%01%96%AC%0Cl%D5Z%ADl%A5%90%A7g%EA%A9%0B%B9%E6%8Aw%AB(%18CO4F%E3%E0%80z%BB%9D%CD%C0%96%0F%60%19V%9EW*%B3%B6%CF%17%1DH%24p%1A%0D%E4%A2%7D%F5%13%150v%88%DE%F8%04%8Dr%99%C2%F1%F1j%06%DE%DC%BALv_%DF%C2%93%D1Q%02%B6%8D%E9%EDEEp%9AM%3A%F5%3A_%8F%8E%BA%CE%8B%B7n%E3%FF%AC%F3O%C2Gf%1E%B9Xvw%00%00%00%00IEND%AEB%60%82"
}

function blogIcon() {
  return "data:image/png,%89PNG%0D%0A%1A%0A%00%00%00%0DIHDR%00%00%00%10%00%00%00%10%08%06%00%00%00%1F%F3%FFa%00%00%00%06bKGD%00%FF%00%FF%00%FF%A0%BD%A7%93%00%00%00%09pHYs%00%00%0B%13%00%00%0B%13%01%00%9A%9C%18%00%00%00%07tIME%07%D5%09%16%127)%3BR%02H%00%00%01%CBIDAT8%CB%A5%93Mh%13A%14%C7%7F3%DD%A3H%16%22-%E2%B1%E0)%A0X%2B%01%0F%82%15%84x%ECE%D0%B6'%AF%A5%17%15%3C%8A%20%C5%20%F5%22~%80%9A%16%8A1%BD%5B%1A%11M%5C%10%ED%C1b%D3%8D%1BL%FD%C0%D5l%EB%10%15Z%91%CDx0C%B3mj%2B%BE%CB%FF%0D%CC%FB%CFof%DE%83%FF%0Ca%92%E2%5D%FA%80%19%E0%D8Vzx%88%BC%A9%93%00%97G%2F%9D%01f%0E%1Ew%D8%8E%B6%12XM%BD%01%F0%ED%F99%B6%A3WOJ%DD%AC%3B-%8D%D3%DET%40Y%15X%DD%93%A7%AC%0A%FC%E8z%D8V_LK%06%C7%8A%1C%E9%1F%06%187%04%C4%E3q%C4%89%A5%3F%8B%7DMeM%7D%DF'%7FO2t%ED%19%1F%9E%8C3%B7%10%84%40%87%D5z%1F%A5%14%F5z%7D%C3K%07A%80%9BI%AD%15%7B%CB%7C-Mu%00%3D%11%03%DB%B6%B1m%3BR%EC%FB%3En%26%C5%E0X%91%C5%C7%19%5E%95%97Q%A5%1C%40%CF%C8dc%F6%AF%04%E6%E4%81t%81%C5%7C%86%B9%B7%0AU%CA%F1s%FFE%CE%9F%BD0%0B%88M%09%B4%D6%14%D2%BD%0C%5Cy%8A7%7D%87%CA%E7%EF%A8%F9%07%BC%EF%1A%A6%B3%CD7F%08%B4%D6d%B3Y~%C9C%CC%3B%0E%EF%3E%D5Yz%3D%05%BDiv%AD%AC%00%DA4%A1nK%10%86!%BB%3F%A6y%F4%A5%9B%FB%B9%1C%DD%F2%25%3B%FBn%91L%26q%5D%977%95%05%8C%8B%5COP%ADV%F1%3C%8F%91%C9%06G%3B%2B%AC%EEH%10%1E%18%25%91H%60Y%16%96eE%BAx%03A%2C%16CkM%ADVCk%8D%94%12%AD5B%08%84%10%AD%DB%1B%11%03%A5%14%8E%E3l%3Au%C6d%7D%18%83%89%9B%B7%AF%9F%FA%87)%9E0%C9oZ%9D%E8%98y%09%FC%12%00%00%00%00IEND%AEB%60%82"
}

function concertIcon() {
  return "data:image/png,%89PNG%0D%0A%1A%0A%00%00%00%0DIHDR%00%00%00%10%00%00%00%10%08%06%00%00%00%1F%F3%FFa%00%00%00%06bKGD%00%EA%00%EA%00%EA%7F%8D%3A%11%00%00%00%09pHYs%00%00%0D%D7%00%00%0D%D7%01B(%9Bx%00%00%00%07tIME%07%D5%0B%03%16*!%D0%EB%BAw%00%00%02LIDAT8%CB%7D%93_HSa%18%C6%7F%93%CD%B6S%B3H%EA%2C%C8%B4%0B%EF%94%04%D9%94X%97%5Ev%25%B2At%D1MiwA%D4%8D%0C%8A%FE%987u%E3%86%20%D4%F4j%1EF%BB%D8%1F%D0%8B%BC%89%08%8DmHM%5D%DA%89%99lzl%188%8Fy8%EB%22w%DAh%FA%C0%C7%F7%F7y%DE%E7%7B%BF%F73q%88%01O%FF%23%C0%C7%D1%98%03%B2R(%7C%BBz%D1T!%BB%9C._o%EFU%BA%AEt%D5%B0%8A%C5%22%00%5B%CA%16%23%2F%9E%01%DC%93B%E1W%95%FD%86%C3%DE%E7v_%A3%F5R%2B%C5b%D1h%8A%A2%A0%AA*%0B%0B%F3%AC%AD%AE%F2%E0%FEC%80%97%D5%01%CC%95%81C%BC%80%D7%EB%05%20%16%8B%11%8F%C7%19%1B%1B3%0EZ%AD'%B0%09V%84%93%02%F5%04%1E%8B%A2%E8%F3%FB%FDh%9A%86%A2(%B8%DDn%BA%BB%BB%FF%5E~%EE%1D%00%ABk_%91%BF%CBu%05%7C333%8C%8E%8E%1A%0E%A2%D1(%81%40%A0%C6%81%A5%D1B%D3i%3Bu%93%18%7C%3D%E5%5BYYA%D34%2C%16%0B%82%20%606%9BY%5E%5EF%96%BF%F1cc%83B!%CF%E6f%81%7D%F57%F6%26%FB%9B%E9%90t%EBH%07%89D%82%89%89%89%9Ahg%CE%9E%C6%E3%F1%92J%25%99%9F%FFt%030%04%9E%F4%F5%F5%0D%B7%B7%B7%A3%EB%3A%F9%7C%9E%8E%8E%0E%82%C1%20%BB%BB%BB%C8%B2L%26%93%E1%C3%C7%F7%A4RI2_%960aj%A8%CE%C1%F0%EC%EC%AC%E1%20%12%89%90H%24%18%1F%1F%C7j%B5%1A%0E%DA.%B7%91J%A6)%97%CB%D8%ED%A7%E25%CF%D8%D3%D3%83%24I%00d%B3YDQdrr%D2%20GcQ%1C%A2%83%F0%5B%09%C1%26P%DA%2B%5D%AF%11(l%E6%11%CF%3BH%A7%D3%00%A8%AA%CA%E2%E2%22%9A%A6%A1%EB%3A%07%DA%01%DB%3F%15%00%9A%9B%9B)%AD%97j%0B%C9%1F%F03xg%88%CE%CENt%5D%A7%5C.%A3%EB%3A%9A%A6%B1%F3k%87%CC%D2gR%A9%24%C0%9E%D3%E9%B2%E5%D6s%FF%04%A4P%D84twp%FF%F9%C8%D3F%8E%C7%12%E0%00l%FF%95%B2%B2%BD5%DDr%B1%85%DCz%0E)%14%BEy%94%C2%80%A7%7F%AA%EE_%00%22N%A7%EB%5C%C5%DA1%88TO%FE%00%E3%D8%01yO4%896%00%00%00%00IEND%AEB%60%82"
}

function songIcon() {
  return "data:image/png,%89PNG%0D%0A%1A%0A%00%00%00%0DIHDR%00%00%00%10%00%00%00%10%08%06%00%00%00%1F%F3%FFa%00%00%00%06bKGD%00%FF%00%FF%00%FF%A0%BD%A7%93%00%00%00%09pHYs%00%00%0D%D7%00%00%0D%D7%01B(%9Bx%00%00%00%07tIME%07%D5%04%1C%0B69%BB%24%9FG%00%00%010IDAT8%CBc%60%A0%100b%13%2C%AD5%EDg%60%FAZ%40H3%13%13%C7%5E%16%EC2_%0B%82%83%02%09%DA%BEv%DDzg%26l%12%FF%FF3~%23%D6%0B%2C%04l%C0*%FE%FF%1F%C3%BF%90%90%40%26%82%060000t7%5E%C3%08%A7%92%3A%ED%EF%0C%0C%0C%1C%0C%0C%0C%0CLd%06%FE%3Fxpa%8D%1A%C6%FF%5Cx%A3%0EI%9E%89%D2t%40V%2C%20%CB%B30000d%15ZH2%B3%FC%89%FD%F1%FD%BB%93%80%F0%7Fw%06%86%FF%0C%BF%FE%7C%86k%C0'%CF%C2%C0%C0%C0%F0%F9%D3%A7%3A5-%B6%0C%133U%06~%5Eu%06~ne%86%7BO%D72%88%89s2%10%92ga%60%60%60%90%90a%C8%B0%B7%B7f%F8%F7%EF%0F%0333%3B%C3%DD'k%18.%9D%7F%FD%FF%CD%EB%FF%5B%F1%C9%BFz%C1%D4%00O%07%F7%1E%9Eg%E0%E0%60a%E0%E7%7B%CBp%F3%FA%5B%86wo%FF%5E%3C%7D%ECC%17%3E%F9%B3'%DF%EE%87'%92%C4L%B5%DB%22b%2C*%0C%0C%0C%0C%B7%AF%FF%5C%B4a%D5%DDx%E4%80C%97%97W%94%A8%98%D8y%F49%A5%B1%C8%00%00%BDu%89%F9o)J%9E%00%00%00%00IEND%AEB%60%82"
}

function positiveReviewIcon() {
  return "data:image/png,%89PNG%0D%0A%1A%0A%00%00%00%0DIHDR%00%00%00%10%00%00%00%15%08%06%00%00%00O%3En%D2%00%00%00%01sRGB%00%AE%CE%1C%E9%00%00%00%06bKGD%00%FF%00%FF%00%FF%A0%BD%A7%93%00%00%00%09pHYs%00%00%0B%13%00%00%0B%13%01%00%9A%9C%18%00%00%00%07tIME%07%D8%05%09%10%0D%0B%B9%0B%F0%AD%00%00%02%B8IDAT8%CB%A5%92%CBkSA%14%C6%BF337i%1E%D4%D6%DA%165j*%AD%A8%B5%0F%C1%07%D4%A6%AE%04AP%10_%A8%E0%7F%20%15ta%05WnD%14%84%BAs'b%11E%5C%BAR%7C%20*%98Z%D0%96%FA%D6VC51%7D%A4I%EE%9D%99%E3%22%B166%8A%E2%81%BB%99s%EEo%BE%F3%CDG%F8M%C5c%ADU%ECy%BB%18%B6AH%D5GB%3Eo%BF7%60%7F%9DSe%7F%EEj%F5%B3%B5%7B%7C%91%25%C7UUuu%EE%ED%EB(%E7%B2G%01%7C%FEuV%94%BD%3E%9F%AFT%81%E0%F6%DA%BD%87%A2%91%EE%9Ey%15K%1B%B6%B21%AB%CB%8D%96%05%B05%12%8E%F2%FB%EA%EA%E1%D4%2C%80%0C%04%02%04T%FE5%A0%40%01%60-%C0%5C%F8%0A'%FF%00%F8%CB%FAo%80*u%BF%0D%C4%96l.%0B%22b%22*4%88%18%60%D3%DF%B9%86P%3Cc%22%5E%7Bw%E0'%20%1Ekq%D8sW%B1%F6%1A%C1%A81%99%CC%C2%89G%F7%91%1F%FD%08o%2C!%60m%97%CD%E7%82D%A4%98%A1%E18%2F%E2%5DmC%04%00%FD%B1%16%87%3D%BD_%CC%AF9%1Ch%5C%B1L%06C%3E%18%13%E0%A2Bb%CB%201%0D%22%0D%22%B2%F9%9C%9D%1E%1E%EC%B7%E3%E9%13%14%8F%B5H%F6%BC%9DNd%E9%B9%C8%91%9EH%B8%B9%0D%24%0A%D603%D8s%0B%FE%D3%0F%AD%04%3D%91%C6%A7%0Bg%BD%C9%07wN)X%DBL%3E%DF%C1%DA%DD%07%16Uul.1%C8d%A7%91%B8~%05vj%12(BA%04%93J%22%3B%3C%98%60)%9E)h%DD%AAj%EB%A3%E1%F6u%E5Ce4%8C%E7%82%84%9C%01X%A3%C1%DAs%89%91V%60%EB%93%8E%23%A4r%E6%BE%B1%BF%02%F5%3B%F6%80%8D)Y%C1K~%C1h%E2S%7D%E6%E9%E3%E5jVgN%E9%CC%14%DE%F7%9E%81%9EH%83%E4%2C%05%DFR%F0%DE%BC%7C%25%1C'%AE%FE%14%12%E9%AF%40%CD%96m0%85%5C%14%01%02%3A9%86%E4%B5%CBu%EE%87w%8B%15%A8%E86%CDUBB%C0_%5B%07%EB%BA%25%2BHGA%84%C2~f%0E%2B%08%F9YOMN%B9c%09%04%1A%1A%E7%BC%C2%C8%C5%5Ex%C9%AF%20)f%14pf%12z%E4%C3%A8t%9CaEJ%3D4%E9%D4%ED%AF7%AF%B6%07%9BVV%A8y%D5%F8%11W%19%0C!z%EC%24X%EBb%10%18%20%013%9E%C2%E8%F9%D3M%D3%FDO6%11%00%C4%3B%D74%B0%14g*7%C6%B6%87%D7w8%22%14.Y%03%B3%D7%93%026%93A%EAF_2%3B%F4%A2%7B%A6%13%EFl%8E%82%B1%0F%81%E0%06%922T%DEV%22%10%24%AC%F18%EF%DE%82%D1%97%BE%03%EBb'-%B3X%C3%AB%00%00%00%00IEND%AEB%60%82"
}

function negativeReviewIcon() {
  return "data:image/png,%89PNG%0D%0A%1A%0A%00%00%00%0DIHDR%00%00%00%10%00%00%00%15%08%06%00%00%00O%3En%D2%00%00%00%01sRGB%00%AE%CE%1C%E9%00%00%00%06bKGD%00%FF%00%FF%00%FF%A0%BD%A7%93%00%00%00%09pHYs%00%00%0B%13%00%00%0B%13%01%00%9A%9C%18%00%00%00%07tIME%07%D8%05%09%10%0E'%A0%FE%CF%8D%00%00%02%BEIDAT8%CB%B5%94OHTQ%18%C5%CFw%EF%7D%EA8%93%8D%16Y44%05%22%88%9AMdR4A%9B%16%05%B6%E8%0F%D1%BAv%E2%AAVA%8B%96%B9%2Ch%19Q%81%D5%22%8A%82%A2MhnB%9CIk%92%824%A9h%1Cg%1CG%C7%99%F7%DE%7D%F7k1%E9%243F%10%1D%B8%CB%EFw%CF%C79%F7%12~)v%A8%7D'%18g%E1%AB%DFOR%FAQUD%20H%18%CFe%DBy%01O%DFQ%A5%E1%8E%5D%2C%C5%40CO%B47%D0%7D%D0%12%FE%40yD%08%80%A8%CC%90%02%26%9FG%E6%D1%E0%BE%C2d%22%A5%E2%D1%CE%A0q%9D%0B%0D%D1%A3%C7w%5C%BCb%A9%8D%8D%E5%01f8%E9%14Xk%00%04%80%01%12%F0%162%C8%D6%F9%EA%09%26%A8X%EB%032%D8td%F3%893uV%D3%E65%86%F5b%0E%D3%03W%E1%A6%E7%40R%ACX%02%E7%17%A1%BF%CE%7C%22e%8D(%18o%9B%0Al%08%D4l%D9Z%B1%B1%F4%D5%23t%BE%0F%C6qJ%06J%04%E8%F94~%DC%BA%B9%BD%90%98hU%60%80%88%40%CC%15%006%06vj%16%5E%B1%00ZY%8B%04tz%16%26%BFd%13%D1%92%C2%1F%E4%D9E%A4_%3E%83%CEeAR%AE%06a%E63%D0%A9%E4%2CI%F9M%01%BC.%40%F9%03%08%F7%5D%02%7B%DE%9A%15%DCt%0A%DF%AE_k%C9%8F%BD%89(%90p%3C%D75%9Ev%2B%00%C6.%22%F9%F8%01tn%01%24%CA%0E%BCl%06%CE%97%CFI%A1%D4g%01%A5%C6ufnz)%3Ej%AAVG*H%AB%06%C2%B2%CAG*%90%B2j%98%10T%10%E2%3D%3B%CE%DD%D4%C3%7B%7BkC%E1P%A0%BD%ABT%1E%00%CC%8C%E6%DE%93%A5-%7FO!%97%C5%F7lf%AB%1EIv%11%00%C4%A3%9D%16%BB%FA%9Ch%DA%D4%EFki%0D%CBz%7F%0D%3C%CF%C7%80%02%00b%C3%20%B1%0C%22%0D%222v%D1%2C%7F%FC%107%0B%D9%CB%AB%DCX%B4%D3b%AD%DB%A0%DD%1606%09%7F%A0%BF%E9%D8%89%8E%DAP%18%E9G%83E%7Bf%EA%063%8F%12%91b%86%86e%25HY%93%AB1F%86'%DC%D8%E1%AEqRj%C2%14%0B%CD%D2%EF%3F%DD%D0s%A8%C3%D7%DA%86%DC%C8%2Bc%7F%FD2%24%94%F5%B4%F4%9E%00%26%E2%C8%D0%5B%AC%E9Ad%E8-%00%F0Xw%0B%98%99x%A5%5C%CC%04%90%DC%F3%FA%5DE%E6%02%FF%A8%FF%08%20%00%2B%7FA%E9%1D%D0_%03HH%0F%AE%B6%9D%D9%24%DC%F4%1C%BCB%A1%C0%40%AEj%DD%AB%DE%5E%5B%9B%D3%85%E5'%A9%FB%B7%DB%E7%83%8D%8D%C5%99%A9%E7%24eb%3D%A3U%15%8B%EE%0E%B2%EB%9Eb%98%5DB%AAA%12%F2%FD%9E%E1%F1%8A%BA%FF%04%E0%E01%AB%C4%01%83Y%00%00%00%00IEND%AEB%60%82"
}

function loadingImage() {
  return "data:image/gif,GIF89a%20%00%20%00%F7%00%00%FF%FF%FF%B3%B3%B3%FB%FB%FB%D6%D6%D6%E1%E1%E1%F2%F2%F2%BA%BA%BA%81%81%81444%01%01%01%1B%1B%1B%C4%C4%C4%97%97%97%FD%FD%FDTTT%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00!%FF%0BNETSCAPE2.0%03%01%00%00%00!%F9%04%05%0A%00%00%00%2C%00%00%00%00%20%00%20%00%00%08%FA%00%01%08%1CH%90%E0%82%03%0B%0A*%5C%C8p%E0%81%87%05%09%14h%A8p%80%81%82%0F%0F%10%1C%C0%91%22%C1%02%0F%03%10%CC8%B0%00%C7%01%1EG%3ED)%90%A4%C0%93%04R%0E4%F0%90%81C%88%00%08%9C%94I%90%C1%C3%8B%00%5C%C2%E49p%C0%01%9F%13%1F%3A%C8%B9s%A0%CE%011_2%60%90p%60%80%9F%0Au%96%3C%09u%E0%82%A9SY%1A%AD%DA%90k%C7%9E%60%A7F%F5hv%ED%C6%B46S%3Eu%BB%F0%2B%03%96ry%12%00J%B4%2FQ%B3%1CM.0%40%B8p_%C0%1C%0B%2B%E6%2B%F3%E4%02%98%03%06%2F%F6KY%26%5D%8A%97%19%CE%F5%B89%A5%D9%89%0AMr%E5%09%B8%60i%CCx%9Fr%5C%AB%BA%EB%CB%CB%AA%09vf%EA%FA%E5j%00MO%82%26*Z%EC%D9%D8%87o%E3%3E%3B%BC%B6%DC%A6%C5%9D%22%F7%2C%3CyQ%E2%CC%F1%3Aw%9A%99a%01%BA%CB%2Bg5N1%20%00!%F9%04%05%0A%00%00%00%2C%00%00%00%00%18%00%12%00%00%08%80%00%01%08%1CH%B0%20%80%01%06%13*d%00%80!A%03%0B%14FT8%90%C1%81%03%09%19h%2C%E8P%E0%82%8B%18%0Dj%EC%98%10%A4%81%84%0B6%12%ECh%00%24%C5%86%0C%26%12%24%00Rf%C6%86%04%04Zl%E8R%20%01%03%06%10VTY%B0eN%81%03%80%02%3DJ%80%81%D0%97H%95B%2C%005%E1O%A9U%15%26%3D%99Ua%81%A7%5D%C3z%1D%40%B6%2C%D8%AAf%CD%8A%25PvAY%B1%01%01%00!%F9%04%05%0A%00%00%00%2C%01%00%00%00%1D%00%0E%00%00%08%89%00%01%08%1CHp%E0%00%06%05%13*%5C(%10a%C2%01%0C%07%12%80H%90%81E%82%01%22%124%60%80bC%00%0E%01P%0C%C9%90%A3%01%02%03-%86%24%A9q%80%C9%94%0AY2%5C%C0q%E4%C5%02%20E%16%C4%A9%90%80I%9C%08%11%1A%F88%D0%C0%81%03C%07%0C%409%90f%00%8FM%09.8z%F4%A4R%A5%3C%0B%0C%8Dx%90%EAQ%83W%090%D5%E8%F5%00T%91W%CF.4z%20cO%A5c52%88%9BP%ACF%8D%01%01%00!%F9%04%05%0A%00%00%00%2C%07%00%00%00%19%00%11%00%00%08%81%00%01%08%1C%08%80%80%01%82%08%13*%04%B0%C0%C0%02%84%0F%17%16%20%80%D0%80E%82%0C2.%1C0%A0%E2%C5%81%1A7r%2C0%D0%E2A%90%0C%22%26%24%C0%B1%A3%40%93%02%17%84%5C%08%A0%25E%000%090%00%B0%93%A6%40%9B8%3F%CED%E8%F2'%C7%9B%04%07%F4%AC%B94%E1%00%A4%0A%91%EE%0C%E0%93f%CF%A6U!%C6%CC%EA%D3%00I%AE%60%C3%26%3C%40%B6%EC%01%95%60%CD%9A%15%0B%80%AC%03%B3%0B%02%02%00!%F9%04%05%0A%00%00%00%2C%0E%00%00%00%12%00%18%00%00%08%82%00%01%2C%20%00%A0%A0%C1%83%08%07%2C%40%08%60%00A%86%02%17%2C4%B8%C0%80%01%88%11'%02%20%60%F1%22D%89%1A%3B%0E%C0%08%B2%E0%80%8E%183%02(%D0%F1%E1G%89%0D%03%18%D0(%90%01%83%94%06%0A%1C%B4%C9%80%26F%9B%00%80%A6%0C%1A%F4%E6%D0%9DF%8F%1Et%A9%B4i%D3%A4)oJuz%C0%20%83%91N%9B%1A%60z%D4%C0%81%03%01%A8~%FD%EA%13%E2%00%06c%0F%40%C5%99%D6%A3%D2%00d%01%04%04%00!%F9%04%05%0A%00%00%00%2C%0E%00%00%00%12%00%1E%00%00%08%99%00%01%0C(%00%A0%A0%C1%83%08%05%0EH%C8%B0%E0%80%87%07%07%2CX%D0%F0%E1B%83%13%2F%26%B4hP%22%C5%8A%10%0BN%FC%C8%90%23%80%91%0D%1D%86%CC%18%D1%80%01%02%0C%09h%24%E0%D2%A5%C6%86%0Bj%1A%20%D9P%E7%CB%94%1Dm%02E8p%A8Q%A3%0C%92*%15%08%94%01%00%A7P%9D%A6%5C%9A%F4%A8%D5%83%04%AD~4p%D5%20%83%9B%0D%09%0488%96%A1%81%030%05Vm%C8%E0%80%DB%83%06%9C%82%05%40%C0%ED%01%9E%40%CF%BE%B5j%97%EB%D1%01v%AF%DA%CDz%D4%25%C3%80%00!%F9%04%05%0A%00%00%00%2C%0F%00%01%00%11%00%1F%00%00%08%8C%00%01%08%1C%08%80%40%01%82%08%13%0E%18%90%B0a%81%85%0D%23.%24%10%91%20%81%85%0C%2B%0A%BC%08Q%E3%C6%8E%039z%14%88q%00%C5%8A%1C1j%2C%99Q%23%C7%93%23%09%C0%1CI%13%A1%81%9B8%17h%C4%C9%D3%40%C5%9E%06t%D6%1CJs%00%03%06B%3D%1E%3DZs%E9%D2%86%3A%5B%0A%3C%9AT%A0O%A6%03u2%10x%A0%2B%80%83%24%23v%3D%40%10k%C2%B1%03%B7VDK%93%EDT%B5g%0F8P%D8%D0%AD%C7%05%07%AAj%0C%08%00!%F9%04%05%0A%00%00%00%2C%08%00%0E%00%18%00%12%00%00%08%7D%00%01%08%1CH%B0%20%80%01%08%13%0E(%60%B0%E1%40%85%0A%1D%3AL%B8%20!%01%89%183b%1C%A01%A3%01%03%1C%3B%1A%FCH%F2%A2%C8%81%05%16%904%B0%40%E4%00%06%26%09%AC%0Cy%F0%80%81%86%0C%0C%0E%F8h%12%00%83%03%07r%12%24%C0%A0(%C6%05%40%0F%98%14%0A%60%01S%87Io%3A%2C%DArdR%82O%7D%1A5%98%B4*%C6%AC%02%AFb%3DP%D0kY%A9%03s%82%3DI%B3c%40%00!%F9%04%05%0A%00%00%00%2C%02%00%12%00%1D%00%0E%00%00%08%89%00%01%08%1CH%B0%A0A%00%04%0E%12%24%C0%40%A1A%02%03%06%24%3Ch%E0%C0%01%03%0E%09F%DCX%40%A3%C5%8F%195n%8C(%90%C1%C7%03%0C%06d%24%80q%E0H%96'%5B%26%5C%60p%80%01%034%07BTY%F1%40%00%82%3F%01%60d%40%14%40%81%9B%06%26%3E%2C%A8%12%40C%A7P%01%D8%BC%19r%E0S%82E%05.%B8%D9%B4jT%A8WYR%0DY%B4%2B%D1%AB%00%B6%B6%AC%8A%16%ADK%A5%0E%BBb%0D%EA%95%ED%DA%8C%01%01%00!%F9%04%05%0A%00%00%00%2C%00%00%0F%00%19%00%11%00%00%08%80%00%17%1C%18H%F0%00%80%83%08%13*%3CX%B0%E0%C2%87%09%05%12t0%10%A2%C5%8B%181%160%90%B1%E3%82%8E%0F%19%80%84%18%20a%00%02%18%07%40d%C0%40%E5%C1%96%0B%09%0C%98%99%D0%25G%84%2CE%020%C0%13%80%CC%99%05%12%06U%C8%12!%CF%9B%3F%5DZd%F9qg%CF%833%07%A0%7C%B8%A0%A8%D1%A7Pi.Mx%B4%A6%D6%85V%AF%DED8%15bS%84%0B%0C%9C%1D%A9%D0%40%D9%84%01%01%00!%F9%04%05%0A%00%00%00%2C%01%00%08%00%11%00%18%00%00%08w%00%07%1C8%60%00%80%C1%83%08%0F%1A%188pA%C2%87%00%18%0Ed0%00%22%C2%05%12%0FXL%18%60%60%C1%8D%1CA%8A%1CI%B2%A4%C9%93(7.%60%C0%A0%24K%96%20_%BE%04%B9%B2%25%C2%02%1F%1F%B2txp%81%01%03%15%07%085H%20!%81%9F%06%0A%00%10Z%11%22%D2%A6L!%0E%40z0%EAC%A4E%0DZM%F8%B3%A9%D6%A1%0F%09x%FD%3A%16%A4X%00%01%01%00!%F9%04%05%0A%00%00%00%2C%00%00%02%00%0E%00%1D%00%00%08%8A%00%01%08%1C%08%60%81%01%82%08%07%1E8%C0%20!%C2%85%07%068%1C%18%00%E2D%85%0B%0F%5E%5C%60%91%60C%82%10%3Fz%94%08%80%C0%81%00%04Q%8A%240q%C0G%91%13%17%08%94y%11%40%01%8D5%5B2%D8%C9%13%A6%C0%9E%3D%13%BA%DC%09%80g%CE%A3%08I%5E%1C%60%C0%80R%84%04%9AJuhP%EA%82%02B%AD%0E%240%00%AB%C0%A8N%09%0E%18%CBR%A0%D7%81%05%C6%0E(%EBP-%DB%84%5C%C7%D6T%9BSn%CE%02o%03%02%00%3B";
}
