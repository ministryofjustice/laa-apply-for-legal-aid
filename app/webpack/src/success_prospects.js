$(function() {
  $('#success-prospect-text-area').hide();
  let optionName = $("input[type=radio][name='chances_of_success[success_prospect]']:checked").val();
  if (typeof(optionName) != "undefined" && optionName != 'likely') {
    showSuccessProspectTextArea(optionName)
  }

  $('.success_prospect_option').click(function() {
    showSuccessProspectTextArea($(this).val());
  });
});

function showSuccessProspectTextArea(optionName) {
  let id = "#conditional-"+optionName;
  $('#success-prospect-text-area').prependTo( id );
  $('#success-prospect-text-area').show();
}
