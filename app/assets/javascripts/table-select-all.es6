$(document).ready(function() {
  if ($('.select-clear-all').length) {
    function resetSelectClearLink(table) {
      const link = table.find('.select-clear-all');
      link.attr('tabindex', 0);
      link.removeClass('select-all clear-all');

      if (table.find('input:checked').length) {
        link.addClass('clear-all').text(link.data('copy-clear'));
      }
      else {
        link.addClass('select-all').text(link.data('copy-select'));
      }
    }

    function setCategory(row) {
      let vacantItem = row.find(".table-category-vacant");
      if (row.find('input:checked').length) {
        vacantItem.addClass("table-category-preview");
      } else {
        vacantItem.removeClass("table-category-preview");
      }
    }

    $('.select-clear-all').click(function() {
      const table = $(this).parents('table');
      if($(this).hasClass('clear-all')) {
        $("#screen-reader-messages").text("All transactions deselected.");  //this adds a message to the message div which is read out by the screen reader
        table.find('input:checked').prop('checked', false);
      } else if ($(this).hasClass('select-all')) {
        table.find('input:not(:checked)').prop('checked', true);
        $("#screen-reader-messages").text("All transactions selected."); 
      }
      resetSelectClearLink($(this).parents('table'))
      return false;
    });

    $('.select-clear-all').keypress(function(ev) {
      const returnKeyCode = 13;
      const spaceBarCode = 32;
      if (ev.which==returnKeyCode || ev.which==spaceBarCode) { //on space or return
        $(this).click(); //mimic a click
        return false;
      }
    });

    $('table').find("input").click(function() {
      resetSelectClearLink($(this).parents('table'));
      setCategory($(this).parents('tr'))
    });

    resetSelectClearLink($('.select-clear-all').parents('table'))
  }
});
