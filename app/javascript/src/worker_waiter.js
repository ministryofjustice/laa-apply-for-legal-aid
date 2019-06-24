$(function() {
  if ($(".worker-waiter").length){ waitForWorker() };
});

function waitForWorker() {
  const worker_id = $(".worker-waiter").data('worker-id');
  const working_statuses = ['queued', 'working'];

  $.getJSON(`/v1/workers/${worker_id}`, function (worker) {
    if(working_statuses.includes(worker.status)) {
      setTimeout(waitForWorker, 1000);
    } else {
      location.reload();
    }
  });
}
