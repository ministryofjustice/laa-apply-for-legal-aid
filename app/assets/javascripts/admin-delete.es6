$(document).ready(function() {
  $(".request-delete-button").click(function(){
    const actionRoot = "/admin/legal_aid_applications/"; 
    let applicationID = $(this).attr("data-application-id"); //ID code of element to delete
    let fullName = $(this).parent().siblings(".case-full-name").text(); //Full Name of case to delete
    let caseNumber = $(this).parent().siblings(".case-reference-number").text(); //Case Reference Number of case to delete
    let deleteDetails = " " + caseNumber + " (" +fullName+")";
    if (!fullName) deleteDetails = ""; //if there is no full name (i.e. a delete all), no details to display
    
    //if the current error box is poised to delete the same field as is clicked,
    //we want to cancel the delete
    if (applicationID == $("#confirm-delete-button").attr("data-application-id")) {
      $("#confirm-delete").attr('hidden',"true"); //restore hidden status to box
      $("#confirm-delete-button")
        .attr('disabled',"true") //restore disabled status to button
        .removeAttr("data-application-id") //remove the attribute ID from the button - this is used for comparison - the if statement we are currently in
        .parent("form").attr("action",""); //tells confirm button not to delete anything
        
      $(".request-delete-button").addClass("govuk-button--warning"); //add the red button style to the button (it will currently be green)
      $(this).val($(this).data("original-text")); //restore the original text to the button (it will currently say cancel delete)
    }
    
    //if it isn't the same, then we are trying to delete something different from current
    //or the box is hidden
    //so we set up the record for deletion
    else {
      $("#confirm-delete-button")
        .removeAttr('disabled') //enable the delete button
        .attr("data-application-id",applicationID) //set the delete button to reference the specific case (this is for comparison, so another click on the same button will remove the box)
        .parent("form").attr("action",actionRoot + applicationID); //tells confirm button what to delete
      
      $("#confirm-delete").removeAttr('hidden'); //shows the box
      $("#delete-case-details").text(deleteDetails);//changes delete details to relevant case (box title)
      $("#delete-message").text($(this).attr("data-delete-message")); //changes message of box
            
      $(".request-delete-button")
        .addClass("govuk-button--warning") //makes all buttons red (in case another button is in a green state)
        .each(function(){
          $(this).val($(this).data("original-text")); //makes all buttons revert to their original text (in case another button is in a cancel delete state)
        });
      $(this)
        .removeClass("govuk-button--warning") //makes this button green
        .val($("#confirm-delete").data("cancel-text")); //makes this button read "cancel delete"
    }
  });
});
