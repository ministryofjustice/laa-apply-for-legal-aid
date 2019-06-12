$(document).ready(() => {
  $(".request-delete-button").click(function(event){
    event.preventDefault();

    const action = $(this).parent("form").attr("action"); 
    let applicationID = $(this).attr("data-application-id"); //ID code of element to delete
    let deleteTitle = $(this).attr("data-delete-message");
    let deleteName = $(this).attr("data-delete-name");
    let deleteRef = $(this).attr("data-delete-ref");

    //if the current error box is poised to delete the same field as is clicked,
    //we want to cancel the delete
    if (applicationID == $("#confirm-delete-button").attr("data-application-id")) {
      cancelDeleteButton(this);  
    }
    //if it isn't the same, then we are trying to delete something different from current
    //or the box is hidden
    //so we set up the record for deletion
    else {
      prepareDeleteWarning(action, deleteTitle, deleteName, deleteRef, applicationID);
      showDeleteWarning();
      resetAllButtons();
      changeClickedButton(this);
    }

    function cancelDeleteButton(clickedButton) {
      $("#confirm-delete").attr('hidden', "true"); //restore hidden status to box
      $("#confirm-delete-button")
        .attr('disabled', "true") //restore disabled status to button
        .removeAttr("data-application-id") //remove the attribute ID from the button - this is used for comparison - the if statement we are currently in
        .parent("form").attr("action", ""); //tells confirm button not to delete anything
      $(".request-delete-button").addClass("govuk-button--warning"); //add the red button style to the button (it will currently be green)
      $(clickedButton).val($(clickedButton).data("original-text")); //restore the original text to the button (it will currently say cancel delete)
    }

    function prepareDeleteWarning(action, deleteTitle, deleteName, deleteRef, applicationID) {
      $("#delete-case-name").text(""); //removes any hangover content
      $("#delete-case-ref").text(""); //removes any hangover content
      $("#confirm-delete-button")
        .removeAttr('disabled') //enable button
        .attr("data-application-id", applicationID) //set the delete button to reference the specific case (this is for comparison, so another click on the same button will remove the box)
        .parent("form").attr("action", action); //tells confirm button what to delete
      console.log(applicationID);
      $("#delete-message").text(deleteTitle); //changes title of box
      $("#delete-case-name").text(deleteName); //changes message of box
      $("#delete-case-ref").text(deleteRef); //changes message of box
      if ($("#delete-case-name").text().length) {
        $("#delete-case-details").removeAttr("hidden");
      } else {
        $("#delete-case-details").attr("hidden","hidden");
      }
    }

    function showDeleteWarning() { 
      $("#confirm-delete").removeAttr('hidden'); 
    }

    function resetAllButtons() {
      $(".request-delete-button")
        .addClass("govuk-button--warning") //makes all buttons red (in case another button is in a green state)
        .each(function() {
          $(this).val($(this).data("original-text")); //makes all buttons revert to their original text (in case another button is in a cancel delete state)
        });
    }

    function changeClickedButton(clickedButton) {
      $(clickedButton)
        .removeClass("govuk-button--warning") //makes this button green
        .val($("#confirm-delete").data("cancel-text")); //makes this button read "cancel delete"
    }

  })
})
