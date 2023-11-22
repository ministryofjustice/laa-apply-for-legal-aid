import axios from 'axios'

async function deleteApplication (applicationId) {
  const url = `/v1/legal_aid_applications/${applicationId}`
  const response = await axios({
    method: 'delete',
    url
  })
  return response.status
}

function initModalDialog () {
  openModal()
  deleteAppCloseModal()
  closeModal()
}

function openModal () {
  const openModals = document.querySelectorAll('[data-modal-open-target]')

  openModals.forEach((openModal) => {
    openModal.addEventListener('click', () => {
      const modalId = openModal.getAttribute('data-modal-open-target')
      const modal = document.getElementById(modalId)

      modal.showModal()
    })
  })
}

function deleteAppCloseModal () {
  const deleteCloseModals = document.querySelectorAll('[data-modal-delete-close-target]')

  deleteCloseModals.forEach((deleteCloseModal) => {
    deleteCloseModal.addEventListener('click', () => {
      const modalId = deleteCloseModal.getAttribute('data-modal-delete-close-target')
      const modal = document.getElementById(modalId)
      const applicationId = modalId.replace('modal-', '')

      deleteApplication(applicationId).then(() => {
        modal.close()
        window.location.reload()
      }).catch((error) => {
        console.error(error.message)
      })

      modal.close()
    })
  })
}

function closeModal () {
  const closeModals = document.querySelectorAll('[data-modal-close-target]')

  closeModals.forEach((closeModal) => {
    closeModal.addEventListener('click', () => {
      const modalId = closeModal.getAttribute('data-modal-close-target')
      const modal = document.getElementById(modalId)

      modal.close()
    })
  })
}

document.addEventListener('DOMContentLoaded', (e) => {
  const dialog = document.querySelector('dialog')
  if (dialog) initModalDialog()
})

export {
  deleteApplication,
  initModalDialog,
  openModal,
  deleteAppCloseModal,
  closeModal
}
