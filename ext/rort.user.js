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

function parseJson(data) {
  return eval("(" + data + ")");
}

// Create a HTML element (can include attributes) with closing tag
function ele(tag, content) {
  var closeTag = tag.match(/^(\w+)/)[1];
  return '<'+tag+'>'+content+'</'+closeTag+'>';
}

// Return a data: URI based icon
function icon(type) {
  data = eval(type + 'Icon()');
  return ele('img class="icon" alt="' + type + '" src="' + data + '"', '');
}

// Scope where jQuery is enabled
function withJQuery() {

  var user = $('ul#loggedinuser > li.item > a:first').attr('href')
               .match(/\/Person\/(\w+)/)[1];

  // Sets a global css style
  function setStyle(css) {
    $('head').append(ele('style type="text/css"', css));
  }

  function setupContainer() {
    $('#frontpage .mainnewsspot').prepend(ele("div id='activity-list'", ''));
  }

  function insertError(msg) {
    $('#activity-list').append(ele("div id='errors'", icon('error') + msg));
  }

  function setupActivities() {
    var activitiesCss = {
      listStyleType: 'none'
    }

    $('#activity-list').append(ele("ul id='activities'", ''));
    $('#activities').css(activitiesCss);
  }

  function insertActivity(activity) {
    $('#activities').append(ele('li', activity));
  }

  function display(res) {
    if (res.status != 200)
      insertError('Unknown person: ' + ele('em', user));
    else
      displayActivities(res.responseText);

    removeLoadingStatus();
  }

  function displayActivities(data) {
    var parsed = parseJson(data);

    if (parsed.length > 0) {
      setupActivities();

      var lastActivityDate = '';

      $.each(parsed, function() {
        lastActivityDate = formatActivity(this, lastActivityDate);
      });
    } else {
      insertError("Either you don't have any favorites " +
                  'or your favorites are not doing anything interesting');
    }
  }


  function formatActivity(activity, lastDate) {

    if (lastDate != activity.date)
      insertActivity(ele('h3', activity.date));

    switch (activity.type) {
      case 'blog':
        var blog = icon('blog') +
                   ele('a href=' + activity.author_url, activity.author) +
                   ' blogget om ' +
                   ele('a href=' + activity.url, activity.title)
        insertActivity(blog);
        break;
      case 'concert':
        var concert = icon('concert') +
                      ele('a href=' + activity.artist_url, activity.artist) +
                      ' holdt konsert: ' + activity.location +
                      ' &mdash; ' + activity.title;
        insertActivity(concert);
        break;
      case 'song':
        var song = icon('song') +
                   ele('a href=' + activity.artist_url, activity.artist) +
                   ' har lagt ut sangen: ' +
                   ele('a href=' + activity.url, activity.title);
        insertActivity(song);
        break;
      case 'review':
        var review = icon('review') +
                     ele('a href=' + activity.reviewer_url,
                         activity.reviewer) +
                       ' har anmeldt sangen: ' +
                       ele('a href=' + activity.url, activity.title) +
                       ' av ' +
                       ele('a href=' + activity.artist_url, activity.artist);
        insertActivity(review);
        break;
      default:
        insertActivity('Unknown activity type ' + activity.type);
    }
    return activity.date;
  }

  function insertLoadingStatus() {
    $('#activity-list').append(ele('div id="load-status"',
                                   ele('img alt="Loading"' +
                                       'src="' + loadingImage() + '"', '') +
                                   ele('p',
                                       'Laster inn aktivitetsdata...')));
  }

  function removeLoadingStatus() {
    $('#activity-list > #load-status').hide();
  }

  setStyle(rortStyle());

  setupContainer();

  insertLoadingStatus();

  get('http://rort.redflavor.com/?favorites=' + user, display);
}

function rortStyle() {
  return '#load-status, #load-status > p { text-align: center; }' +
         'img.icon { margin: 0 5px 0 0; }' +
         '#activity-list { margin: 0 0 0 20px; }' +
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

function reviewIcon() {
  return "data:image/png,%89PNG%0D%0A%1A%0A%00%00%00%0DIHDR%00%00%00%10%00%00%00%10%08%06%00%00%00%1F%F3%FFa%00%00%00%04sBIT%08%08%08%08%7C%08d%88%00%00%00%09pHYs%00%00%0D%D7%00%00%0D%D7%01B(%9Bx%00%00%00%19tEXtSoftware%00www.inkscape.org%9B%EE%3C%1A%00%00%02aIDAT8%8D%85%93Mh%D4g%10%C6%7F%F3%BE%FF%8F%DDU%D6P)%88X%F1%A3%14%13%2Ba%11%D1%16%85%5E%05%91bz%08%C1%85R%0F%3Dx%F0%EC%A9%F4%E6Q%7B%EB%A1%12X%2C-x%90%5C%04%AF-%22%88.Q%D1V%EA%8AVkM%88Y%D9%EC%C7%FFk%C6C%8C%AC%E2%B6s%9E%E77%CC%3C%F3%88%991%AA%9Au%F9%12%18%AB5lvT%8F%8C%024%EB%B2A%BCk%81%8B%AD%C8w%D6%1A%F6%FC%3F%01%CD%BA%7C%03%94%81k%C0-%F1%EE%C7%B1O%26g%82%F2%3AY%9A%BFzY%0B%9D%02%F6%00%FB%81R%ADa%E7%00%82!%D8%07%3E%AE%9CqQI%F3n%1B%17%96%D8%7C%E0%8BP%BCg%F9%FE%9D%C3%D6%7D%D9%F3%95%AA%C3T%F2%5E%E7%EC%9Ah%18p%CD%85Q6%3E%7D%A2%94%F6%FBh%96%E2%D2%25(%12v%1E%99%8E%C4%7B%C2J%99%07s%BFt%F3%5E%E7%F7%F7%01nd%DDv%98%BE%5C%22%E8%3D%043%FC%A1%EF%00%08%7F%FB%1ELQ%99%A0%BF%F8%AC%02%5C%5D%13%B9%D7%FB%7F(N%CE%FB%A8%A4%BA%D2%C6%92%01%BA%FC%08%89%AAHTE%97%1Fa%83%15%F2%CE2A%5C%CA%9Cw%3F5%EB%B2%19%40n%1E%E7%84%88%9C%1D%DB%BA%3D%DC%B4%FB%D3%D8%E5%1D%AC%DD%02%CD%89g%E6%00H~%3E%0A%E2%90%B1mh%BC%91%C5%3F%EEfK%AD%BFrS%3D%EDV%BD%100%C5%92%3E6%E8%E0wM%BD%11%03%C43s%F8%F1%AF%B0%FE%0A%96%F4%18%B6%5E%CClu%05%E1%07%09%E3%A9%ED%B5%3Da%94.%12L%1C%25%D8%FB5%00%F9%8DY%B2%DB%17%D1%F5%5Bi%DD%BC%9Dj%DA%BF%A2j%DF%D6%1A%F6%CF%F0%1F%94%81%CE%C7%B5%DD%3EH%16%C0%94%60r%1A0%F2%F9_W%A7V%3F%E2%CF%EB%B7%0C%B3M%B5%86-%BC%EB%C2%5E%1F%86Y%A0%03%9FJ%15%B5%82%D2%FCE%D0%9C%C4U%11%2FD%C9%0AQ)%EE%A6%FD%C1%E7%C0%A5w%01%07L5%BC%7F%EFIfy%8A%88c%C7%F8%96PB%E1%F1%BD'%A9%169%E2C'h%198%B8%06pC%80%17Z%14%A74M%3E3%B5u%A6%C5%85%7F%9F%BE%18%2C%3Ck%A7V%E4%97M%AD%A2Y%BA%AF%C8%F2%93%C0%DFo%1D%F1%7D%D5%AC%CB%06q%D2%C2%88%CD%EC%FF%C34%02r%8C%D58%9F%1F%D5%F3%0A%C2S0%D9%A0%606%5D%00%00%00%00IEND%AEB%60%82"
}

function loadingImage() {
  return "data:image/gif,GIF89a%20%00%20%00%F7%00%00%FF%FF%FF%B3%B3%B3%FB%FB%FB%D6%D6%D6%E1%E1%E1%F2%F2%F2%BA%BA%BA%81%81%81444%01%01%01%1B%1B%1B%C4%C4%C4%97%97%97%FD%FD%FDTTT%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00%00!%FF%0BNETSCAPE2.0%03%01%00%00%00!%F9%04%05%0A%00%00%00%2C%00%00%00%00%20%00%20%00%00%08%FA%00%01%08%1CH%90%E0%82%03%0B%0A*%5C%C8p%E0%81%87%05%09%14h%A8p%80%81%82%0F%0F%10%1C%C0%91%22%C1%02%0F%03%10%CC8%B0%00%C7%01%1EG%3ED)%90%A4%C0%93%04R%0E4%F0%90%81C%88%00%08%9C%94I%90%C1%C3%8B%00%5C%C2%E49p%C0%01%9F%13%1F%3A%C8%B9s%A0%CE%011_2%60%90p%60%80%9F%0Au%96%3C%09u%E0%82%A9SY%1A%AD%DA%90k%C7%9E%60%A7F%F5hv%ED%C6%B46S%3Eu%BB%F0%2B%03%96ry%12%00J%B4%2FQ%B3%1CM.0%40%B8p_%C0%1C%0B%2B%E6%2B%F3%E4%02%98%03%06%2F%F6KY%26%5D%8A%97%19%CE%F5%B89%A5%D9%89%0AMr%E5%09%B8%60i%CCx%9Fr%5C%AB%BA%EB%CB%CB%AA%09vf%EA%FA%E5j%00MO%82%26*Z%EC%D9%D8%87o%E3%3E%3B%BC%B6%DC%A6%C5%9D%22%F7%2C%3CyQ%E2%CC%F1%3Aw%9A%99a%01%BA%CB%2Bg5N1%20%00!%F9%04%05%0A%00%00%00%2C%00%00%00%00%18%00%12%00%00%08%80%00%01%08%1CH%B0%20%80%01%06%13*d%00%80!A%03%0B%14FT8%90%C1%81%03%09%19h%2C%E8P%E0%82%8B%18%0Dj%EC%98%10%A4%81%84%0B6%12%ECh%00%24%C5%86%0C%26%12%24%00Rf%C6%86%04%04Zl%E8R%20%01%03%06%10VTY%B0eN%81%03%80%02%3DJ%80%81%D0%97H%95B%2C%005%E1O%A9U%15%26%3D%99Ua%81%A7%5D%C3z%1D%40%B6%2C%D8%AAf%CD%8A%25PvAY%B1%01%01%00!%F9%04%05%0A%00%00%00%2C%01%00%00%00%1D%00%0E%00%00%08%89%00%01%08%1CHp%E0%00%06%05%13*%5C(%10a%C2%01%0C%07%12%80H%90%81E%82%01%22%124%60%80bC%00%0E%01P%0C%C9%90%A3%01%02%03-%86%24%A9q%80%C9%94%0AY2%5C%C0q%E4%C5%02%20E%16%C4%A9%90%80I%9C%08%11%1A%F88%D0%C0%81%03C%07%0C%409%90f%00%8FM%09.8z%F4%A4R%A5%3C%0B%0C%8Dx%90%EAQ%83W%090%D5%E8%F5%00T%91W%CF.4z%20cO%A5c52%88%9BP%ACF%8D%01%01%00!%F9%04%05%0A%00%00%00%2C%07%00%00%00%19%00%11%00%00%08%81%00%01%08%1C%08%80%80%01%82%08%13*%04%B0%C0%C0%02%84%0F%17%16%20%80%D0%80E%82%0C2.%1C0%A0%E2%C5%81%1A7r%2C0%D0%E2A%90%0C%22%26%24%C0%B1%A3%40%93%02%17%84%5C%08%A0%25E%000%090%00%B0%93%A6%40%9B8%3F%CED%E8%F2'%C7%9B%04%07%F4%AC%B94%E1%00%A4%0A%91%EE%0C%E0%93f%CF%A6U!%C6%CC%EA%D3%00I%AE%60%C3%26%3C%40%B6%EC%01%95%60%CD%9A%15%0B%80%AC%03%B3%0B%02%02%00!%F9%04%05%0A%00%00%00%2C%0E%00%00%00%12%00%18%00%00%08%82%00%01%2C%20%00%A0%A0%C1%83%08%07%2C%40%08%60%00A%86%02%17%2C4%B8%C0%80%01%88%11'%02%20%60%F1%22D%89%1A%3B%0E%C0%08%B2%E0%80%8E%183%02(%D0%F1%E1G%89%0D%03%18%D0(%90%01%83%94%06%0A%1C%B4%C9%80%26F%9B%00%80%A6%0C%1A%F4%E6%D0%9DF%8F%1Et%A9%B4i%D3%A4)oJuz%C0%20%83%91N%9B%1A%60z%D4%C0%81%03%01%A8~%FD%EA%13%E2%00%06c%0F%40%C5%99%D6%A3%D2%00d%01%04%04%00!%F9%04%05%0A%00%00%00%2C%0E%00%00%00%12%00%1E%00%00%08%99%00%01%0C(%00%A0%A0%C1%83%08%05%0EH%C8%B0%E0%80%87%07%07%2CX%D0%F0%E1B%83%13%2F%26%B4hP%22%C5%8A%10%0BN%FC%C8%90%23%80%91%0D%1D%86%CC%18%D1%80%01%02%0C%09h%24%E0%D2%A5%C6%86%0Bj%1A%20%D9P%E7%CB%94%1Dm%02E8p%A8Q%A3%0C%92*%15%08%94%01%00%A7P%9D%A6%5C%9A%F4%A8%D5%83%04%AD~4p%D5%20%83%9B%0D%09%0488%96%A1%81%030%05Vm%C8%E0%80%DB%83%06%9C%82%05%40%C0%ED%01%9E%40%CF%BE%B5j%97%EB%D1%01v%AF%DA%CDz%D4%25%C3%80%00!%F9%04%05%0A%00%00%00%2C%0F%00%01%00%11%00%1F%00%00%08%8C%00%01%08%1C%08%80%40%01%82%08%13%0E%18%90%B0a%81%85%0D%23.%24%10%91%20%81%85%0C%2B%0A%BC%08Q%E3%C6%8E%039z%14%88q%00%C5%8A%1C1j%2C%99Q%23%C7%93%23%09%C0%1CI%13%A1%81%9B8%17h%C4%C9%D3%40%C5%9E%06t%D6%1CJs%00%03%06B%3D%1E%3DZs%E9%D2%86%3A%5B%0A%3C%9AT%A0O%A6%03u2%10x%A0%2B%80%83%24%23v%3D%40%10k%C2%B1%03%B7VDK%93%EDT%B5g%0F8P%D8%D0%AD%C7%05%07%AAj%0C%08%00!%F9%04%05%0A%00%00%00%2C%08%00%0E%00%18%00%12%00%00%08%7D%00%01%08%1CH%B0%20%80%01%08%13%0E(%60%B0%E1%40%85%0A%1D%3AL%B8%20!%01%89%183b%1C%A01%A3%01%03%1C%3B%1A%FCH%F2%A2%C8%81%05%16%904%B0%40%E4%00%06%26%09%AC%0Cy%F0%80%81%86%0C%0C%0E%F8h%12%00%83%03%07r%12%24%C0%A0(%C6%05%40%0F%98%14%0A%60%01S%87Io%3A%2C%DArdR%82O%7D%1A5%98%B4*%C6%AC%02%AFb%3DP%D0kY%A9%03s%82%3DI%B3c%40%00!%F9%04%05%0A%00%00%00%2C%02%00%12%00%1D%00%0E%00%00%08%89%00%01%08%1CH%B0%A0A%00%04%0E%12%24%C0%40%A1A%02%03%06%24%3Ch%E0%C0%01%03%0E%09F%DCX%40%A3%C5%8F%195n%8C(%90%C1%C7%03%0C%06d%24%80q%E0H%96'%5B%26%5C%60p%80%01%034%07BTY%F1%40%00%82%3F%01%60d%40%14%40%81%9B%06%26%3E%2C%A8%12%40C%A7P%01%D8%BC%19r%E0S%82E%05.%B8%D9%B4jT%A8WYR%0DY%B4%2B%D1%AB%00%B6%B6%AC%8A%16%ADK%A5%0E%BBb%0D%EA%95%ED%DA%8C%01%01%00!%F9%04%05%0A%00%00%00%2C%00%00%0F%00%19%00%11%00%00%08%80%00%17%1C%18H%F0%00%80%83%08%13*%3CX%B0%E0%C2%87%09%05%12t0%10%A2%C5%8B%181%160%90%B1%E3%82%8E%0F%19%80%84%18%20a%00%02%18%07%40d%C0%40%E5%C1%96%0B%09%0C%98%99%D0%25G%84%2CE%020%C0%13%80%CC%99%05%12%06U%C8%12!%CF%9B%3F%5DZd%F9qg%CF%833%07%A0%7C%B8%A0%A8%D1%A7Pi.Mx%B4%A6%D6%85V%AF%DED8%15bS%84%0B%0C%9C%1D%A9%D0%40%D9%84%01%01%00!%F9%04%05%0A%00%00%00%2C%01%00%08%00%11%00%18%00%00%08w%00%07%1C8%60%00%80%C1%83%08%0F%1A%188pA%C2%87%00%18%0Ed0%00%22%C2%05%12%0FXL%18%60%60%C1%8D%1CA%8A%1CI%B2%A4%C9%93(7.%60%C0%A0%24K%96%20_%BE%04%B9%B2%25%C2%02%1F%1F%B2txp%81%01%03%15%07%085H%20!%81%9F%06%0A%00%10Z%11%22%D2%A6L!%0E%40z0%EAC%A4E%0DZM%F8%B3%A9%D6%A1%0F%09x%FD%3A%16%A4X%00%01%01%00!%F9%04%05%0A%00%00%00%2C%00%00%02%00%0E%00%1D%00%00%08%8A%00%01%08%1C%08%60%81%01%82%08%07%1E8%C0%20!%C2%85%07%068%1C%18%00%E2D%85%0B%0F%5E%5C%60%91%60C%82%10%3Fz%94%08%80%C0%81%00%04Q%8A%240q%C0G%91%13%17%08%94y%11%40%01%8D5%5B2%D8%C9%13%A6%C0%9E%3D%13%BA%DC%09%80g%CE%A3%08I%5E%1C%60%C0%80R%84%04%9AJuhP%EA%82%02B%AD%0E%240%00%AB%C0%A8N%09%0E%18%CBR%A0%D7%81%05%C6%0E(%EBP-%DB%84%5C%C7%D6T%9BSn%CE%02o%03%02%00%3B";
}
