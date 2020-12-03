$(function() {
  /*
    Usage:
      Required: A group of checkboxes,
        and another control checkbox outside the group

      Enclose the checkbox group with a div of class "deselect-group"
        and set it's "data-deselect-ctrl" to the jquery identifier for the control checkbox
  */
  $('.deselect-group').each(function() {
    const container = $(this)
    const control = $(container.data('deselect-ctrl'))
    const checkboxMemory = []
    const checkboxes = container.find("input:checkbox")
    const hiddenFieldMemory = []
    const hideableFields = container.find('.govuk-checkboxes__conditional')

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
      const controlChecked = this.checked

      if (this.checked) {
        control.prop("checked", true ).val(true)
      } else {
        control.prop("checked", false ).val('')
      }

      checkboxes.each(function(index) {
        const checkbox = $(this)
        if(controlChecked) {
          checkboxMemory[index] = this.checked
          checkbox.prop("checked", false)
        } else {
          checkbox.prop("checked", checkboxMemory[index])
        }
      })

      hideableFields.each(function (index) {
        const hideableField = $(this)
        if (controlChecked) {
          if (!hideableField.hasClass('govuk-checkboxes__conditional--hidden')) {
            hideableField.addClass('govuk-checkboxes__conditional--hidden')
            hiddenFieldMemory[index] = true
          }
        } else if (hiddenFieldMemory[index]){
            hideableField.removeClass('govuk-checkboxes__conditional--hidden')
        }
      })
    })

    /*
      Monitor changes to the checkboxes within the container.
      If one is selected, deselect the control.
    */
    checkboxes.change( function() {
      if(this.checked) { control.prop("checked", false ).val(false) }
    })
  })
})
