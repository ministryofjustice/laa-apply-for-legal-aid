import Dropzone from 'dropzone'

// Make sure Dropzone doesn't try to attach itself to the
// element automatically.
// This behaviour will change in future versions.
// Dropzone.autoDiscover = false

document.addEventListener('DOMContentLoaded', event => {
  const dropzoneElem = document.querySelector('#dropzone-form')
  if (dropzoneElem) {
    const applicationId = document.querySelector('#application-id').textContent.trim()
    const url = `/v1/statement_of_cases/${applicationId}`
    const dropzone = new Dropzone(dropzoneElem, {
      url: url,
      createImageThumbnails: false,
      // dictResponseError: 'Error uploading file',
      headers: {
        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      }
    })
    dropzone.on('addedfile', file => {
      console.log(`File added: ${file.name}`)
    })
  }
})
