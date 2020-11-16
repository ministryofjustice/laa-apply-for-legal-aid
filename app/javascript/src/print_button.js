document.addEventListener('DOMContentLoaded', event => {

  document.querySelectorAll('.print-button').forEach(button => {
    button.addEventListener('click', event => {
      window.print();
    })
  })

});
