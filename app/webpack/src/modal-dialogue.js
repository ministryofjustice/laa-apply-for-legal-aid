const MODAL_OPEN_MESSAGE = 'A new window has opened inside the current window'

function announceModal () {
  const messagesDiv = document.querySelector('#screen-reader-messages')
  messagesDiv.innerText = MODAL_OPEN_MESSAGE
}

function openModal (modal) {
  modal.style.visibility = 'visible'
}

function closeModal (modal) {
  modal.style.visibility = 'hidden'
}

function makeModalTabbable (modal, nonModalElems) {
  const dialogElements = modal.querySelectorAll('.modal-dialog')
  dialogElements.forEach((elem) => {
    elem.setAttribute('tabindex', 2)
  })
  nonModalElems.forEach((elem) => {
    elem.setAttribute('data-previous-tabindex', elem.getAttribute('tabindex'))
    elem.setAttribute('tabindex', -1)
  })
}

function updateTabIndex(modal, nonModalElems) {
  const dialogElements = modal.querySelectorAll('.modal-dialog')
  dialogElements.forEach((elem) => {
    elem.setAttribute('tabindex', -1)
  })
  nonModalElems.forEach((elem) => {
    elem.setAttribute('tabindex', elem.getAttribute('data-previous-tabindex'))
  })
}

// while open, prevent tabbing to outside the dialogue
// and listen for ESC key to close the dialogue
function handleKeyEvents (modal) {
  modal.focus()
  const modalContent = modal.querySelector('.modal-content')
  modalContent.addEventListener('keydown', (event) => {
    const KEY_TAB = 9
    const KEY_ESC = 27

    // to keep tab keypresses within the modal and not the (hidden) document underneath
    const firstFocusableElement = modalContent.firstElementChild
    const lastFocusableElement = modalContent.lastElementChild
    console.log(lastFocusableElement)
    console.log(firstFocusableElement)
    console.log(document.activeElement)

    switch (event.keyCode) {
      case KEY_TAB:
        if (event.shiftKey) {
          if (document.activeElement === firstFocusableElement) {
            event.preventDefault()
            lastFocusableElement.focus()
            console.log(lastFocusableElement)
          }
        } else {
          if (document.activeElement === lastFocusableElement) {
            event.preventDefault()
            firstFocusableElement.focus()
            console.log(firstFocusableElement)
          }
        }

        break
      case KEY_ESC:
        closeModal(modal)
        break
      default:
        break
    }
  })
}

function startModal (modal, lastFocusableElement, nonModalElems) {
  // display the modal
  openModal(modal)
  handleKeyEvents(modal)
  announceModal()

  // Get the button and span elements that close the modal
  const closeButtons = modal.querySelectorAll('.close-modal');
  closeButtons.forEach((btn) => {
    btn.addEventListener('click', (event) => {
      event.preventDefault()
      closeModal(modal)
      updateTabIndex(modal, nonModalElems)
      lastFocusableElement.focus()
    })
  })

  // close modal and refresh page when an application is deleted
  const confirmDeleteBtn = modal.querySelector('.confirm-delete-btn')
  confirmDeleteBtn.addEventListener('click', (event) => {
    closeModal(modal)
    window.location.reload()
    lastFocusableElement.focus()
  })

  // When the user clicks anywhere outside of the modal, close it
  window.onclick = function (event) {
    if (event.target === modal) {
      closeModal(modal)
      updateTabIndex(modal, nonModalElems)
    }
  }
}

document.addEventListener('DOMContentLoaded', event => {
  const deleteButtons = document.querySelectorAll('[data-toggle="modal"]')
  const nonModalElements = document.querySelectorAll('body *:not(.modal-dialog):not([tabindex="-1"])')

  if (deleteButtons) {
    // When the user clicks on the button, open the modal
    deleteButtons.forEach((deleteBtn) => {
      deleteBtn.addEventListener('click', () => {
        // find the corresponding modal for that button
        const modalId = deleteBtn.id.replace('-btn', '')
        const modal = document.getElementById(modalId)
        startModal(modal, deleteBtn, nonModalElements)
        makeModalTabbable(modal, nonModalElements)
      })
    })
  }
})
