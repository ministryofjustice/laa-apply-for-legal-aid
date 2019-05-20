$(function() {

  /*
    Usage:
      Required: A group of checkboxes,
        and another control checkbox outside the group

      Enclose the checkbox group with a div of class "deselect-group"
        and set it's "data-deselect-ctrl" to the jquery identifier for the control checkbox
  */
  $('.deselect-group').each(function() {
    const container = $(this);
    const control = $(container.data('deselect-ctrl'));
    const checkboxMemory = [];
    const checkboxes = container.find("input:checkbox");

    if(!control.length) return

    /*
      Monitor changes of the control
      For each checkbox within the container,
      If control is selected:
        remember how checkbox was set
        and set checkbox to false
      If deselected:
        Set each checkbox based on its remembered state
    */
    control.change( function() {
      const controlChecked = this.checked;
      checkboxes.each(function(index) {
        const checkbox = $(this);
        if(controlChecked) {
          checkboxMemory[index] = this.checked;
          checkbox.prop("checked", false);
        } else {
          checkbox.prop("checked", checkboxMemory[index]);
        };
      });
    });

    /*
      Monitor changes to the checkboxes within the container.
      If one is selected, deselect the control.
    */
    checkboxes.change( function() {
      if(this.checked) { control.prop("checked", false )};
    });
  });
});
