document.addEventListener('DOMContentLoaded', event => {
  const table = document.querySelector('table.sortable');
  if (table) {
    const endText = {
      asc: {
        date: 'from Oldest to Newest',
        numeric: 'from Smallest to Largest',
        alphabetic: 'from A. to Zed',
        undefined: 'in ascending order' // for when the data-sort-type is not set
      },
      desc: {
        date: 'from Newest to Oldest',
        numeric: 'from Largest to Smallest',
        alphabetic: 'from Zed to A',
        undefined: 'in descending order' // for when the data-sort-type is not set
      }
    }

    const tableHeaders = document.querySelectorAll('th.sort')

    function resetTableHeaders () {
      tableHeaders.forEach((header) => {
        header.classList.remove('header-sort-asc', 'header-sort-desc');
        header.removeAttribute('aria-sort');
      })
    }

    function sortTableCells (index, inverse) {
      const tableCells = table.querySelectorAll('td');
      const sortedRows = Array.prototype.filter.call(tableCells, (td) => {
        return Array.from(td.parentNode.children).indexOf(td) === index;
      }).sort((a, b) => {
        return sortableValue(a) > sortableValue(b) ? inverse ? -1 : 1 : inverse ? 1 : -1
      }).map((td) => {
        return td.parentNode; // parentNode is the row which is the element we want to move
      });
      const tableBody = sortedRows[0].parentNode;
      tableBody.innerHTML = ''; // empty table
      sortedRows.forEach((row) => {
        tableBody.appendChild(row); // and add rows back to table in correct order
      })
    }

    function sortableValue (elem) {
      let value = elem.getAttribute('data-sort-value');
      if (value === undefined || value === null) { value = elem.textContent.trim() }
      if (elem.getAttribute('data-sort-type') === 'number') { value = +value }
      return value;
    }

    function addScreenReaderMessages (tableHeader, sortDirection) {
      // this adds a message to the message div, stating what it is sorted by
      document.querySelector('#screen-reader-messages').innerHTML = 'Sorted by ' +
          tableHeader.querySelector('.aria-sort-description').textContent + ' ' +
          endText[sortDirection][tableHeader.getAttribute('data-sort-type')];
    }

    tableHeaders.forEach((th) => {
      th.classList.add('js-sortable'); // this class used to style as links, if JS not enabled, titles won't look clickable.
      th.setAttribute('tabindex', 0);
      const index = Array.from(document.querySelectorAll('th')).indexOf(th); // need to select all table headers including hidden cell to get index
      let inverse = false;

      th.addEventListener('click', (event) => {
        resetTableHeaders();
        const sortDirection = inverse ? 'desc' : 'asc';
        const verboseSortDirection = inverse ? 'descending' : 'ascending';
        th.classList.add('header-sort-' + sortDirection);
        th.setAttribute('aria-sort', verboseSortDirection);

        sortTableCells(index, inverse);
        addScreenReaderMessages(th, sortDirection);
        inverse = !inverse;
      });

      th.addEventListener('keypress', (ev) => {
        const spaceBarCode = 32;
        const returnKeyCode = 13;
        // on space or return, the column is sorted
        if (ev.which === returnKeyCode || ev.which === spaceBarCode) {
          th.click();
          return false;
        }
      });
    });
  }
})
