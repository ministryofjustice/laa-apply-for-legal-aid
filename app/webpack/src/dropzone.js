import Dropzone from 'dropzone'

// Make sure Dropzone doesn't try to attach itself to the
// element automatically.
// This behaviour will change in future versions.
Dropzone.autoDiscover = false

document.addEventListener('DOMContentLoaded', event => {
  const dropzone = new Dropzone('#dropzone-form')
  dropzone.on('addedfile', file => {
    console.log(`File added: ${file.name}`)
  })
})
