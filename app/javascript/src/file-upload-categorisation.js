import axios from 'axios'

async function updateAttachment (attachmentId, attachmentType) {
  const url = `/v1/attachments/${attachmentId}`

  const response = await axios({
    accept: 'application/json',
    responseType: 'json',
    method: 'patch',
    url,
    data: {
      attachment_id: attachmentId,
      attachment_type: attachmentType
    }
  })

  return response.data.data
}

export function initFileUploadCategorisation (categorisationSelectLists) {
  categorisationSelectLists.forEach((select) => {
    select.addEventListener('change', (e) => {
      /*
        extract attachment id and name/type from select list
        and use to update attachment asynchronously
      */
      const attachmentId = e.target.name.match(/\[(.*)\]/)[1]
      const attachmentType = e.target.value
      updateAttachment(attachmentId, attachmentType)
    })
  })
}

document.addEventListener('DOMContentLoaded', event => {
  const categorisationSelectLists = document.querySelectorAll('select[id^="uploaded-evidence-collection-"]')

  if (categorisationSelectLists.length) {
    initFileUploadCategorisation(categorisationSelectLists)
  }
})
