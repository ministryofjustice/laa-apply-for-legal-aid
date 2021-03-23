document.addEventListener('DOMContentLoaded', event => {
  const deleteButtons = document.querySelectorAll('.request-delete-button')
  deleteButtons.forEach((button) => {
    button.addEventListener('click', (event) => {
      event.preventDefault();
      const action = button.closest('form').getAttribute('action');
      const applicationID = button.getAttribute('data-application-id'); // ID code of element to delete
      const deleteTitle = button.getAttribute('data-delete-message');
      const deleteName = button.getAttribute('data-delete-name');
      const deleteRef = button.getAttribute('data-delete-ref');

      // if the current error box is poised to delete the same field as is clicked,
      // we want to cancel the delete
      const confirmDeleteApplicationId = document.querySelector('#confirm-delete-button').getAttribute('data-application-id')
      if (applicationID === confirmDeleteApplicationId) {
        cancelDeleteButton(button);
      } else {
      // if it isn't the same, then we are trying to delete something different from current or the box is hidden
      // so we set up the record for deletion
        prepareDeleteWarning(action, deleteTitle, deleteName, deleteRef, applicationID);
        showDeleteWarning();
        resetAllButtons();
        changeClickedButton(button);
      }
      return false;
    })
  })

  const confirmDeleteButton = document.querySelector('#confirm-delete-button')

  function cancelDeleteButton (clickedButton) {
    document.querySelector('#confirm-delete').setAttribute('hidden', 'true'); // restore hidden status to box
    confirmDeleteButton.disabled = true; // restore disabled status to button
    confirmDeleteButton.removeAttribute('data-application-id');// remove the attribute ID from the button - this is used for comparison - the if statement we are currently in
    confirmDeleteButton.closest('form').setAttribute('action', ''); // tells confirm button not to delete anything
    clickedButton.classList.add('govuk-button--warning'); // add the red button style to the button (it will currently be green)
    clickedButton.value = clickedButton.getAttribute('data-original-text'); // restore the original text to the button (it will currently say cancel delete)
  }

  function prepareDeleteWarning (action, deleteTitle, deleteName, deleteRef, applicationID) {
    const deleteCaseName = document.querySelector('#delete-case-name');
    const deleteCaseRef = document.querySelector('#delete-case-ref');
    deleteCaseName.textContent = ''; // removes any hangover content
    deleteCaseRef.textContent = ''; // removes any hangover content
    confirmDeleteButton.disabled = false; // enable button
    confirmDeleteButton.setAttribute('data-application-id', applicationID); // set the delete button to reference the specific case (this is for comparison, so another click on the same button will remove the box)
    confirmDeleteButton.closest('form').setAttribute('action', action); // tells confirm button what to delete
    document.querySelector('#delete-message').textContent = deleteTitle; // changes title of error box
    deleteCaseName.textContent = deleteName; // changes name in error box
    deleteCaseRef.textContent = deleteRef; // changes reference in error box
  }

  function showDeleteWarning () {
    document.querySelector('#confirm-delete').removeAttribute('hidden');
  }

  function resetAllButtons () {
    deleteButtons.forEach((button) => {
      button.classList.add('govuk-button--warning'); // makes all buttons red (in case another button is in a green state)
      button.value = button.getAttribute('data-original-text'); // makes all buttons revert to their original text (in case another button is in a cancel delete state)
    })
  }

  function changeClickedButton (clickedButton) {
    clickedButton.classList.remove('govuk-button--warning') // makes this button green
    clickedButton.value = document.querySelector('#confirm-delete').getAttribute('data-cancel-text'); // makes this button read 'cancel delete'
  }
})
