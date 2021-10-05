import { hide, show } from './helpers';

document.addEventListener('DOMContentLoaded', event => {
  const fileUploadFields = document.querySelectorAll('[id$="-original-file-field"]')
  if (fileUploadFields.length) {
    const errorSummary = document.querySelector('#error-summary-hideable')
    document.querySelector('#continue').addEventListener('click', (e) => {
      fileUploadFields.forEach((field) => {
        if (field.value) {
          e.preventDefault()
          show(errorSummary)
          errorSummary.focus()
        } else {
          hide(errorSummary)
        }
      })
    })
  }
})
