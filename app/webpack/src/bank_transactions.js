import { slideUp } from './helpers'

document.addEventListener('DOMContentLoaded', event => {
    document.body.addEventListener('ajax:success', function(event) {
      event.preventDefault()
      const elem = event.target
      if (!elem.classList.contains('remote-remove-transaction')) return
      const row = elem.closest('tr');
      slideUp(row)

      const table = row.closest('table')
      const rowsRemaining = Array.prototype.filter.call(row.parentElement.querySelectorAll("tr"), (row) => {
          return row.style.display !== 'none' || !row.classList.contains('slide');
      }).length

      if (rowsRemaining === 1) { // all rows have been removed except just hidden
        slideUp(table);
      }
    })

    document.body.addEventListener('ajax:error', function(event){
      const elem = event.target;
      if (!elem.classList.contains('remote-remove-transaction')) return
      location.reload(); // reloads page - because if it has failed, the row may have been removed behind the scenes
    });
});
