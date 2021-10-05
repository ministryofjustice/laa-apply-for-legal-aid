import Dropzone from "dropzone";

// Make sure Dropzone doesn't try to attach itself to the
// element automatically.
// This behaviour will change in future versions.
Dropzone.autoDiscover = false;

let dropzone = new Dropzone("#my-form");
dropzone.on("addedfile", file => {
  console.log(`File added: ${file.name}`);
});