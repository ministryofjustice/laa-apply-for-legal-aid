$(document).ready(function() {
  const print_button = document.getElementById("print");

  if (print_button != null) {
    print_button.onclick = function() {
      window.print();
    };
  }
});
