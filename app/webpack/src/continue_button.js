$(document).ready(function() {
  const link = document.getElementById("continue");

  if (link != null) {
    link.onkeydown = function(e) {
      if (e.keyCode == 32) {
        e.preventDefault();
        link.click();
      }
    };
  }
});
