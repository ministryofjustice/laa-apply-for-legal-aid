// Allows blocks of CSS code to be enabled only when no JavaScript is present.
// 
// Usage:
//   The following CSS will set `display: none;` where JavaScript is present,
//   and `display: block;` where no JavaScript is present.
//
//     display: none;
//     &.no-script {
//       display: block;
//     }
//
//   Note, that the order is important - the `no-script` code needs to be
//   after the default entry for it to override the behaviour.
//
document.addEventListener('DOMContentLoaded', event => {
  document.querySelectorAll('.no-script').forEach(function(obj) {
    obj.classList.remove('no-script');
    obj.querySelectorAll('input:disabled').forEach(function(input) {
      input.disabled = false;
    });
  });
});
