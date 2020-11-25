$(document).ready(function() {
  const link = document.getElementById("start");

  if (link != null) {
    link.onkeydown = function(e) {
      if (e.keyCode == 32) {
        e.preventDefault();
        link.click();
      }
    };
  }
});
