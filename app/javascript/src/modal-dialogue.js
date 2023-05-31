import axios from 'axios'

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

// set the tab index to -1 for all elements on the underlying page
function makeModalTabbable (modal, nonModalElems) {
  const dialogElements = modal.querySelectorAll('.modal-dialog')
  dialogElements.forEach((elem) => {
    elem.setAttribute('tabindex', 0)
  })
  nonModalElems.forEach((elem) => {
    elem.setAttribute('data-previous-tabindex', elem.getAttribute('tabindex'))
    elem.setAttribute('tabindex', -1)
  })
}

// restore the tab index for all elements on the underlying page and set to -1 for all modal dialog elements
function updateTabIndex (modal, nonModalElems) {
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
function handleKeyEvents (modal, previouslyFocusedElement, nonModalElems) {
  modal.focus()
  const modalContent = modal.querySelector('.modal-content')
  modalContent.addEventListener('keydown', (event) => {
    const KEY_TAB = 9
    const KEY_ESC = 27

    // to keep tab keypresses within the modal and not the (hidden) document underneath
    const firstFocusableElement = modalContent.firstElementChild
    const lastFocusableElement = modalContent.lastElementChild

    switch (event.keyCode) {
      case KEY_TAB:
        if (event.shiftKey) {
          if (document.activeElement === firstFocusableElement) {
            event.preventDefault()
            lastFocusableElement.focus()
          }
        } else {
          if (document.activeElement === lastFocusableElement) {
            event.preventDefault()
            firstFocusableElement.focus()
          }
        }

        break
      case KEY_ESC:
        closeModal(modal)
        updateTabIndex(modal, nonModalElems)
        previouslyFocusedElement.focus()
        break
      default:
        break
    }
  })
}

async function deleteApplication (applicationId) {
  const url = `/v1/legal_aid_applications/${applicationId}`
  const response = await axios({
    method: 'delete',
    url
  })
  return response.status
}

function startModal (modal, previouslyFocusedElement, nonModalElems) {
  // display the modal
  openModal(modal)
  handleKeyEvents(modal, previouslyFocusedElement, nonModalElems)
  announceModal()

  // Get the button and span elements that close the modal
  const closeButtons = modal.querySelectorAll('.close-modal')
  closeButtons.forEach((btn) => {
    btn.addEventListener('click', (event) => {
      event.preventDefault()
      closeModal(modal)
      updateTabIndex(modal, nonModalElems)
      previouslyFocusedElement.focus()
    })
    btn.addEventListener('keydown', (event) => {
      const KEY_ENTER = 13
      if (event.keyCode === KEY_ENTER) {
        event.preventDefault()
        closeModal(modal)
        updateTabIndex(modal, nonModalElems)
        previouslyFocusedElement.focus()
      }
    })
  })

  // close modal and refresh page when an application is deleted
  const confirmDeleteBtn = modal.querySelector('.confirm-delete-btn')
  confirmDeleteBtn.addEventListener('click', (event) => {
    const applicationRef = modal.id.replace('-modal', '')
    const applicationId = document.getElementById(`${applicationRef}-id`).textContent.trim()
    deleteApplication(applicationId).then(() => {
      closeModal(modal)
      window.location.reload()
      previouslyFocusedElement.focus()
    }).catch((error) => {
      console.error(error.message)
    })
  })

  // When the user clicks anywhere outside of the modal, close it
  window.onclick = function (event) {
    if (event.target === modal) {
      closeModal(modal)
      updateTabIndex(modal, nonModalElems)
      previouslyFocusedElement.focus()
    }
  }
}

function initiateModals () {
  const deleteButtons = document.querySelectorAll('[data-toggle="modal"]')
  const nonModalElements = document.querySelectorAll('body *:not(.modal-dialog):not([tabindex="-1"])') // all tabbable non-modal elements

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
}

document.addEventListener('DOMContentLoaded', (e) => {
  initiateModals()
})
