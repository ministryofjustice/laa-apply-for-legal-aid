import axios from 'axios'

async function updateAttachment (attachmentId, attachmentType) {
  const url = `/v1/attachments/${attachmentId}`

  const response = await axios({
    accept: 'application/json',
    responseType: 'json',
    method: 'patch',
    url,
    data: {
      attachment: { type: attachmentType }
    }
  })

  return response.status
}

function addCategorisationEventListener (categorisationSelectLists) {
  categorisationSelectLists.forEach((select) => {
    select.addEventListener('change', (e) => {
      /*
        extract attachment id and name/type from select list
        and use to update attachment asynchronously
      */
      const attachmentId = e.target.dataset.attachmentId
      const attachmentType = e.target.value
      updateAttachment(attachmentId, attachmentType)
    })
  })
}

export function initFileUploadCategorisation () {
  const categorisationSelectLists = document.querySelectorAll('[data-categorisation-select]')

  if (categorisationSelectLists.length) {
    addCategorisationEventListener(categorisationSelectLists)
  }
}

document.addEventListener('DOMContentLoaded', event => {
  initFileUploadCategorisation()
})
