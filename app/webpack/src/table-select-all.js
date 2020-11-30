document.addEventListener('DOMContentLoaded', event => {
  var clearAllElems = document.querySelector('.select-clear-all')
  var selectTable = clearAllElems.parentNode.parentNode.parentNode

  if (clearAllElems) {
    function resetSelectClearLink(table) {
      const link = table.querySelector('.select-clear-all');
      link.setAttribute('tabindex', 0);
      link.classList.remove('select-all', 'clear-all');

      if (table.querySelector('input:checked')) {
        link.classList.add('clear-all');
        link.textContent = link.getAttribute('data-copy-clear');
      }
      else {
        link.classList.add('select-all');
        link.textContent = link.getAttribute('data-copy-select');
      }
    }

    function setCategory(row) {
      let vacantItem = row.querySelector(".table-category-vacant");
      if (row.querySelector('input:checked')) {
        vacantItem.classList.add("table-category-preview");
      } else {
        vacantItem.classList.remove("table-category-preview");
      }
    }

    clearAllElems.addEventListener("click", function() {
      const table = selectTable;
      if (this.classList.contains('clear-all')) {
        let checkboxes = document.querySelectorAll('input:checked');
        checkboxes.forEach(function(box) {
          box.checked = false;
        })
        document.querySelector("#screen-reader-messages").textContent = "All transactions deselected.";  //this adds a message to the message div which is read out by the screen reader
      } else if (this.classList.contains('select-all')) {
        let checkboxes = table.querySelectorAll('input:not(:checked)');
        checkboxes.forEach(function(box) {
          box.checked = true;
        })
        document.querySelector("#screen-reader-messages").textContent = "All transactions selected.";
      }
      resetSelectClearLink(table);
      return false;
    });

    // TODO: test this
    clearAllElems.addEventListener('keypress', function(ev) {
      const returnKeyCode = 13;
      const spaceBarCode = 32;
      if (ev.which === returnKeyCode || ev.which === spaceBarCode) { //on space or return
        this.click(); //mimic a click
        return false;
      }
    });

    const table = selectTable
    const input = table.querySelector("input")
    input.addEventListener("click", function() {
      resetSelectClearLink(table);
      setCategory(table.querySelector('tr'));
    });

    resetSelectClearLink(table)
  }
});
