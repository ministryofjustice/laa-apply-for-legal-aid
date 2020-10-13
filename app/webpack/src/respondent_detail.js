$(document).ready(() => {
  // conditional--hidden will hide from voiceover/screen readers compared to visually hidden
  const govuk_hidden_class = 'govuk-radios__conditional--hidden'
  const police_notified_label = $("label[for='police_notified_details']")
  const police_notified = $('#police_notified_details')

  const police_notified_no = police_notified.data('police-notified-no')
  const police_notified_yes = police_notified.data('police-notified-yes')

  const police_notified_blank_error_yes = police_notified.data('police-notified-blank-error-yes')
  const police_notified_blank_error_no = police_notified.data('police-notified-blank-error-no')

  const police_notified_checked = "input[type=radio][name='respondent[police_notified]']:checked"

  if ($("#police_notified").length) {
    policeNotifiedHideTextArea()
    setPoliceNotifiedLabel()
    updatePoliceNotifiedLabel()
    updateError()
  }

  function policeNotifiedHideTextArea(){
    // If there is an error on the details text area then don't hide text area
    if ($('#police_notified_details-error').length) return
    if (typeof $(police_notified_checked).val() == 'undefined') {
      $('#police_notified_conditional')
        .addClass(govuk_hidden_class)
        .attr('aria-expanded', 'false');
    }
  }

  function updatePoliceNotifiedLabel() {  
    $("#police_notified input").on("change", function () {
      updateError()

      // show textarea regardless of what is selected
      $('#police_notified_conditional')
        .removeClass(govuk_hidden_class)
        .attr('aria-expanded', 'true');

      // js ternary, if true , do nothing, else show the other data label
      setPoliceNotifiedLabel()
    });
  }

  function setPoliceNotifiedLabel() {
    $(police_notified_checked).val() == 'true' ? police_notified_label.text(police_notified_yes) : police_notified_label.text(police_notified_no)
  }

  function updateError() {
    if (!$('#police_notified_details-error').length) return

    const error = selectedPoliceNotifiedError()
    $('#police_notified_details-error').text(error)
    $('[href="#police_notified_details"]').text(error)
  }

  function selectedPoliceNotifiedError() {
    return $(police_notified_checked).val() == 'true' ? police_notified_blank_error_yes : police_notified_blank_error_no
  }
})
