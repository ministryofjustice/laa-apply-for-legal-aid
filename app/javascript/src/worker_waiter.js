const $ = require('jquery')
const axios = require('axios')

function waitForWorker({ poll_interval = 1000, callback = null }) {
  if (!$('.worker-waiter').length) {
    callback && callback()
    return
  }

  const worker_id = $(".worker-waiter").data('worker-id')
  const working_statuses = ['queued', 'working']

  axios.get(`/v1/workers/${worker_id}`).then(worker_response => {
    if(working_statuses.includes(worker_response.data.status)) {
      setTimeout(
        () => waitForWorker({ poll_interval, callback }),
        poll_interval
      )
    } else {
      window.location.reload()
      callback && callback()
    }
  })
}

module.exports = waitForWorker

if (process.env.NODE_ENV !== 'test') $(waitForWorker)
