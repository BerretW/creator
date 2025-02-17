var disableIt = false;
$(document).keydown(function (e) {
  var close = 27;
  var close2 = 8;
  switch (e.keyCode) {
    case close:
      disableIt = false;
      $.post("http://aprts_horses/exit");
      break;
    case close2:
      disableIt = false;
      $.post("http://aprts_horses/exit");
      break;
  }
});

$(function () {
  $.post(
    "http://aprts_horses/screen",
    JSON.stringify({
      x: window.screen.availWidth,
      y: window.screen.availHeight,
    })
  );
});
