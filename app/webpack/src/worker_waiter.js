import axios from 'axios'

async function checkWorkerStatus () {
  const workerId = document.querySelector('.worker-waiter').getAttribute('data-worker-id')
  const response = await axios.get(`/v1/workers/${workerId}`)
  return response.data
}

function waitForWorker () {
  if (!document.querySelectorAll('.worker-waiter').length) {
    return
  }

  checkWorkerStatus().then(data => {
    // delay next action by 1 second e.g. calling api again
    return new Promise(resolve => setTimeout(() => resolve(data), 1000))
  }).then(data => workerResponse(data, waitForWorker)).catch(() => {
    window.location.reload()
  })
}

function workerResponse (data, waitForWorker) {
  const workingStatuses = ['queued', 'working']
  if (data && workingStatuses.includes(data.status)) {
    waitForWorker()
  } else {
    window.location.reload()
  }
}

function accessibilityAlert () {
  setTimeout(() => {
    const accessibilityMessage = document.querySelector('#accessibilityMessageUpdate')
    if (accessibilityMessage !== null) {
      accessibilityMessage.innerHTML = accessibilityMessage.dataset.message
    }
  }, 5000)
}

export {
  waitForWorker,
  checkWorkerStatus,
  workerResponse
}

if (process.env.NODE_ENV !== 'test') {
  document.addEventListener('DOMContentLoaded', () => {
    waitForWorker()
    accessibilityAlert()
  })
}
