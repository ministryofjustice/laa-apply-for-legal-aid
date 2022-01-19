import Dropzone from 'dropzone'

const screenReaderMessageDelay = 1000 // wait before updating the screenreader message, to avoid interrupting queue

const ERR_GENERIC = 'There was a problem uploading your file - try again'
const FILE_SIZE_ERR = 'The selected file must be smaller than 7MB.'
const ERR_CONTENT_TYPE = 'The selected file must be a DOC, DOCX, RTF, ODT, JPG, BMP, PNG, TIF or PDF.'
// const ERR_VIRUS = 'The selected file contains a virus.'
const ACCEPTED_FILES = ['.doc', '.docx', '.rtf', '.odt', '.jpg', '.bpm', '.png', '.tif', '.tiff', '.pdf']

function addErrorMessage (msg) {
  // this adds an error message to the gov uk error summary and shows the errors
  const errorSummary = document.querySelector('.govuk-error-summary')
  const li = errorSummary.querySelector('li')
  let a = li.querySelector('a')
  if (a === null) {
    a = document.createElement('a')
    li.appendChild(a)
  }
  // add text and link to field
  a.innerText = msg
  a.setAttribute('aria-label', msg)
  a.setAttribute('data-turbolinks', false)
  a.setAttribute('href', '#dz-upload-button')
  // show error message on the dropzone form field
  const dropzoneElem = document.querySelector('#dropzone-form-group')
  dropzoneElem.classList.add('govuk-form-group--error')
  const fieldErrorMsg = document.querySelector('#dropzone-error')
  fieldErrorMsg.innerText = msg
  fieldErrorMsg.classList.remove('hidden')
  // show the error summary and move focus to it
  errorSummary.classList.remove('hidden')
  errorSummary.scrollIntoView()
  errorSummary.focus()
}

document.addEventListener('DOMContentLoaded', event => {
  const dropzoneElem = document.querySelector('#dropzone-form')
  const statusMessage = document.querySelector(('#file-upload-status-message'))

  const chooseFilesBtn = document.querySelector('#dz-upload-button')
  chooseFilesBtn.addEventListener('click', (e) => {
    e.preventDefault() // prevent submitting form by default
    e.parentElement.click()
  })
  // use enter key to add files
  chooseFilesBtn.addEventListener('keydown', (e) => {
    const KEY_ENTER = 13
    if (e.keyCode === KEY_ENTER) {
      e.parentElement.click()
    }
  })

  // aria-hide auto-generated dropzone input field so Wave doesn't complain
  document.querySelector('.dz-hidden-input').setAttribute('aria-hidden', true)

  if (dropzoneElem) {
    const applicationId = document.querySelector('#application-id').textContent.trim()
    const url = document.querySelector('#dropzone-url').getAttribute('data-url')
    const dropzone = new Dropzone(dropzoneElem, {
      url: url,
      headers: {
        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      },
      maxFilesize: 7,
      acceptedFiles: ACCEPTED_FILES.join(', ')
    })
    dropzone.on('addedfile', file => {
      setTimeout(() => { statusMessage.innerHTML = 'Your files are being uploaded.' }, screenReaderMessageDelay);
    })
    dropzone.on('sending', (file, xhr, formData) => {
      // send the legal_aid_application id in the form data
      formData.append('legal_aid_application_id', applicationId)
    })
    dropzone.on('success', () => {
      // refresh the page to see the uploaded files
      window.location.reload()
      setTimeout(() => { statusMessage.innerText = 'Your files have been uploaded successfully.' }, screenReaderMessageDelay);
    })
    dropzone.on('error', (file) => {
      let errorMsg = ''
      if (file.size >= 7000) {
        errorMsg = FILE_SIZE_ERR
      } else if (!ACCEPTED_FILES.includes(file.type)) {
        errorMsg = ERR_CONTENT_TYPE
      } else {
        errorMsg = ERR_GENERIC
      }
      dropzone.removeFile(file)// add an error message to the error summary component
      addErrorMessage(errorMsg)
      if (errorMsg !== ERR_GENERIC) {
        errorMsg = ERR_GENERIC + errorMsg // make error message more informative for screenreaders
      }
      // update the screenreader message to alert the user of the error
      statusMessage.innerHTML = errorMsg
    })
  }
})
