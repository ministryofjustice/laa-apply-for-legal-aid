import Dropzone from 'dropzone'
import imgLoading from '../../assets/images/loading-small.gif'
import { initFileUploadCategorisation } from './file-upload-categorisation'

const screenReaderMessageDelay = 1000 // wait before updating the screenreader message, to avoid interrupting queue

const ERR_GENERIC = 'There was a problem uploading FILENAME - try again'
const FILE_SIZE_ERR = 'FILENAME is larger than 7MB'
const ZERO_BYTE_ERR = 'FILENAME has no content'
const ERR_CONTENT_TYPE = 'FILENAME is not a valid file type'
const ACCEPTED_FILES = [
  // dropzone checks both the mimetype and the file extension so this list covers everything
  '.doc', '.docx', '.rtf', '.odt', '.jpg', '.jpeg', '.bpm', '.png', '.tif', '.tiff', '.pdf',
  'application/pdf',
  'application/msword',
  'application/vnd.oasis.opendocument.text',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'text/rtf',
  'text/plain',
  'application/rtf',
  'image/jpeg',
  'image/png',
  'image/tiff',
  'image/bmp',
  'image/x-bitmap'
]

function addErrorMessage (msg) {
  // this adds an error message to the gov uk error summary and shows the errors
  const errorSummary = document.querySelector('.govuk-error-summary')
  const ul = errorSummary.querySelector('ul')
  const li = document.createElement('li')
  const a = document.createElement('a')
  li.appendChild(a)
  ul.appendChild(li)
  // add text and link to field
  a.innerText += msg
  a.setAttribute('aria-label', msg)
  a.setAttribute('data-turbolinks', false)
  a.setAttribute('href', '#dz-upload-button')
  // show error message on the dropzone form field
  const dropzoneElem = document.querySelector('#dropzone-form-group')
  dropzoneElem.classList.add('govuk-form-group--error')
  const fieldErrorMsg = document.querySelector('#dropzone-file-error')
  const div = document.createElement('div')
  div.innerText = msg
  fieldErrorMsg.appendChild(div)
  fieldErrorMsg.classList.remove('hidden')
  // show the error summary and move focus to it
  errorSummary.classList.remove('hidden')
  errorSummary.scrollIntoView()
  errorSummary.focus()
}

function removeErrorMessages () {
  document.querySelectorAll('.dropzone-error').forEach((dzError) => {
    if (dzError) {
      dzError.querySelectorAll('div').forEach(div => {
        div.remove()
      })
    }
  })
  const errorSummary = document.querySelector('.govuk-error-summary')
  errorSummary.querySelectorAll('li').forEach(listItem => {
    listItem.remove()
  })
  errorSummary.classList.add('hidden') // toggle error-summary-hideable
  document.querySelector('#dropzone-form-group').classList.remove('govuk-form-group--error')
  document.querySelector('#dropzone-form-group > p.govuk-error-message').classList.add('hidden')
}

document.addEventListener('DOMContentLoaded', event => {
  const dropzoneElem = document.querySelector('#dropzone-form')
  const statusMessage = document.querySelector(('#file-upload-status-message'))
  if (dropzoneElem) {
    const applicationId = document.querySelector('#application-id').textContent.trim()
    const url = document.querySelector('#dropzone-url').getAttribute('data-url')
    const chooseFilesBtn = document.querySelector('#dz-upload-button')

    if (url.includes('bank_statement')) ACCEPTED_FILES.push('text/csv')

    chooseFilesBtn.addEventListener('click', (e) => {
      e.preventDefault() // prevent submitting form by default
      removeErrorMessages()
    })
    // use enter key to add files
    chooseFilesBtn.addEventListener('keydown', (e) => {
      const KEY_ENTER = 13
      if (e.keyCode === KEY_ENTER) {
        e.preventDefault() // prevent submitting form by default
        removeErrorMessages()
      }
    })

    const dropzone = new Dropzone(dropzoneElem, {
      url,
      headers: {
        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      },
      maxFilesize: 7,
      acceptedFiles: ACCEPTED_FILES.join(', '),
      disablePreviews: true,
      accept: function (file, done) {
        if (file.size === 0) {
          done('Empty files will not be uploaded.')
        } else { done() }
      }
    })
    dropzone.on('drop', () => {
      removeErrorMessages()
    })
    dropzone.on('addedfile', file => {
      setTimeout(() => { statusMessage.innerHTML = 'Your files are being uploaded.' }, screenReaderMessageDelay)
    })
    dropzone.on('sending', (file, xhr, formData) => {
      // send the legal_aid_application id in the form data
      formData.append('legal_aid_application_id', applicationId)
    })
    dropzone.on('success', (file) => {
      dropzone.removeFile(file)
    })
    dropzone.on('queuecomplete', () => {
      // reload the partial to see the uploaded files
      const fileSection = document.querySelector('#uploaded-files-table-container')
      const url = window.location.pathname + '/list'
      const xmlHttp = new XMLHttpRequest() // eslint-disable-line no-undef
      xmlHttp.open('GET', url, false) // false for synchronous request
      xmlHttp.send(null)
      fileSection.innerHTML = xmlHttp.responseText

      // reintialise eventhandlers for categorisation select lists
      const categorisationSelectLists = document.querySelectorAll('select[id^="uploaded-evidence-collection-"]')
      if (categorisationSelectLists.length) {
        initFileUploadCategorisation(categorisationSelectLists)
      }

      setTimeout(() => { statusMessage.innerText = 'Your files have been uploaded successfully.' }, screenReaderMessageDelay)
    })
    dropzone.on('error', (file, response) => {
      let errorMsg = ''
      if (!ACCEPTED_FILES.includes(file.type)) {
        errorMsg = ERR_CONTENT_TYPE.replace('FILENAME', file.name)
      } else if (file.size >= 7000000) {
        errorMsg = FILE_SIZE_ERR.replace('FILENAME', file.name)
      } else if (file.size === 0) {
        errorMsg = ZERO_BYTE_ERR.replace('FILENAME', file.name)
      } else if (response.error !== '') {
        errorMsg = response.error
      } else {
        errorMsg = ERR_GENERIC.replace('FILENAME', file.name)
      }
      dropzone.removeFile(file)// add an error message to the error summary component
      addErrorMessage(errorMsg)
      if (errorMsg !== ERR_GENERIC) {
        errorMsg = ERR_GENERIC + errorMsg // make error message more informative for screenreaders
      }
      // update the screenreader message to alert the user of the error
      statusMessage.innerHTML = errorMsg
    })

    // aria-hide auto-generated dropzone input field so Wave doesn't complain
    const dzInput = document.querySelector('.dz-hidden-input')
    if (dzInput) {
      dzInput.style.display = 'none'
    }

    const uploadingText = document.querySelector('#uploaded-files-table-container').getAttribute('data-uploading')

    window.LAA_VARS = {
      images: {
        loading_small: imgLoading
      },
      locales: {
        generic: {
          uploading: uploadingText
        }
      }
    }
  }
})
