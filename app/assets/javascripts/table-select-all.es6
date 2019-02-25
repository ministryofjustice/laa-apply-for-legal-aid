$(document).ready(function() {
  if ($('.select-clear-all').length) {
    function resetSelectClearLink(table) {
      const link = table.find('.select-clear-all');
      link.removeClass('select-all clear-all');

      if (table.find('input:checked').length) {
        link.addClass('clear-all').text(link.data('copy-clear'));
      }
      else {
        link.addClass('select-all').text(link.data('copy-select'));
      }
    }

    $('.select-clear-all').click(function() {
      const table = $(this).parents('table');
      if($(this).hasClass('clear-all')) {
        table.find('input:checked').prop('checked', false);
      } else if ($(this).hasClass('select-all')) {
        table.find('input:not(:checked)').prop('checked', true);
      }
      resetSelectClearLink($(this).parents('table'))
      return false;
    });

    $('table input').click(function() {
      resetSelectClearLink($(this).parents('table'))
    });

    resetSelectClearLink($('.select-clear-all').parents('table'))
  }
});
