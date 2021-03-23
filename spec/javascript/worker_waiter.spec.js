import axios from 'axios'
import * as Worker from 'worker_waiter';

jest.mock('axios')

beforeAll(() => {
  Object.defineProperty(window, 'location', {
    value: { reload: jest.fn() }
  })
});

beforeEach(() => jest.resetAllMocks() )

afterEach(() => {
  jest.restoreAllMocks();
});

describe('worker is complete after 2 API calls', () => {
  const worker_id = Math.random().toString(36).slice(-5) // random string

  beforeEach(() => {
    axios.get
    .mockResolvedValueOnce({ data: { status: 'working' } })
    .mockResolvedValueOnce({ data: { status: 'complete' } })
    jest.spyOn(Worker, 'checkWorkerStatus');
    document.body.innerHTML = `<div class="worker-waiter" data-worker-id="${worker_id}"></div>`
  })

  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('polls the correct endpoint twice', async() => {
    const endpoint = `/v1/workers/${worker_id}`

    await Worker.checkWorkerStatus().then((data) => {
      expect(axios.get.mock.calls).toMatchObject([[endpoint]])
      expect(data).toMatchObject({"status": "working"})
    })
    await Worker.checkWorkerStatus().then((data) => {
      expect(axios.get.mock.calls).toMatchObject([[endpoint],[endpoint]])
      expect(data).toMatchObject({"status": "complete"})
    })
  })
})

describe('workerResponse', () => {
  beforeEach(() => {
    jest.spyOn(Worker, 'waitForWorker')
  })

  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('calls worker again when status is working', () => {
    Worker.workerResponse({
      status: 'working'
    }, Worker.waitForWorker)
    expect(Worker.waitForWorker).toHaveBeenCalledTimes(1)
  })

  it('calls worker again when status is queued', () => {
    Worker.workerResponse({
      status: 'queued'
    }, Worker.waitForWorker)
    expect(Worker.waitForWorker).toHaveBeenCalledTimes(1)
  })

  it('reloads the page when status complete', () => {
    Worker.workerResponse({
      status: 'complete'
    }, Worker.waitForWorker)
    expect(window.location.reload).toHaveBeenCalledTimes(1)
  })
})

describe('page does not have any worker-waiter component', () => {
  beforeEach(() => {
    axios.get.mockImplementation()
    jest.spyOn(Worker, 'checkWorkerStatus')
    document.body.innerHTML = '<div></div>'
  })

  it('does not poll the endpoint', () => {
    Worker.waitForWorker()
    expect(Worker.checkWorkerStatus).toHaveBeenCalledTimes(0)
  })
})
