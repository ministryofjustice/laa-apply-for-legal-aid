$(function() {
  $('.deselect-group').each(function() {
    let container = $(this);
    let control = $(container.data('deselect-ctrl'));
    if(control.length) {
      control.change( function () {
        if(this.checked) {
          container.find("input:checkbox").prop("checked", !this.checked);
        };
      });
    };
  });
});
