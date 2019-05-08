$(document).ready(() => {
  if ($("#bail_conditions_set").length) {
    $("input[type=radio][name='respondent[bail_conditions_set]']").on("change", () => {
      setBailConditionsLabel()
      updateError()
    })
    setBailConditionsLabel()
    updateError()

    function selectedBailConditionsLabel() {
      const optionChecked = selectedBailCondition()
      if (optionChecked.val() == 'false') {
        return $('#bail_conditions_set_details').data('bail-conditions-no')
      }
      else {
        return $('#bail_conditions_set_details').data('bail-conditions-yes')
      }
    }

    function selectedBailCondition(){
      return $("input[type=radio][name='respondent[bail_conditions_set]']:checked")
    }

    function setBailConditionsLabel() {
      $("label[for='bail_conditions_set_details']").text(selectedBailConditionsLabel())
    }

    function updateError() {
      if (!$('#bail_conditions_set_details-error').length) return

      let label = selectedBailConditionsLabel()
      if (selectedBailCondition().val() != 'false') {
        label = $('#bail_conditions_set_details').data('bail-conditions-blank-error')
      }
      $('#bail_conditions_set_details-error').text(label)
      $('[href="#bail_conditions_set_details"]').text(label)
    }
  }
})
