import { hide, show } from './helpers'

const ERROR_MESSAGE_TEXT = 'Upload the selected file'

function createErrorMessage () {
  const errorMessage = document.createElement('span')
  errorMessage.classList.add('govuk-error-message')
  errorMessage.innerHTML = ERROR_MESSAGE_TEXT
  const accessibilityMessage = document.createElement('span')
  accessibilityMessage.classList.add('govuk-visually-hidden')
  accessibilityMessage.innerHTML = 'Error: '
  errorMessage.appendChild(accessibilityMessage)
  return errorMessage
}

function addErrorMsgToField (input) {
  const errorMessage = createErrorMessage()
  input.parentNode.insertBefore(errorMessage, input)
  input.parentNode.classList.add('govuk-form-group--error')
}

document.addEventListener('DOMContentLoaded', event => {
  const fileUploadFields = document.querySelectorAll('[id$="-original-file-field"]')
  if (fileUploadFields.length) {
    const errorSummary = document.querySelector('#error-summary-hideable')
    document.querySelector('#continue').addEventListener('click', (e) => {
      fileUploadFields.forEach((field) => {
        if (field.value) {
          e.preventDefault()
          addErrorMsgToField(field)
          show(errorSummary)
          errorSummary.focus()
        } else {
          hide(errorSummary)
        }
      })
    })
  }
})
