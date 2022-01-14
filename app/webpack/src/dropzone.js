import Dropzone from 'dropzone'

document.addEventListener('DOMContentLoaded', event => {
  const dropzoneElem = document.querySelector('#dropzone-form')
  const statusMessage = document.querySelector(('#file-upload-status-message'))
  if (dropzoneElem) {
    const applicationId = document.querySelector('#application-id').textContent.trim()
    const url = '/v1/statement_of_cases'
    const dropzone = new Dropzone(dropzoneElem, {
      url: url,
      headers: {
        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      }
    })
    dropzone.on('addedfile', file => {
      statusMessage.innerHTML = 'Your files are being uploaded.'
    })
    dropzone.on('sending', (file, xhr, formData) => {
      // send the legal_aid_application id in the form data
      formData.append('legal_aid_application_id', applicationId)
    })
    dropzone.on('success', () => {
      // refresh the page to see the uploaded files
      window.location.reload()
      statusMessage.innerHTML = 'Your files have been uploaded successfully.'
    })
    dropzone.on('error', () => {
      statusMessage.innerHTML = 'There was an error uploading your files.'
    })
  }
})
