import axios from 'axios'
jest.mock('axios')

beforeAll(() => {
  Object.defineProperty(window, 'location', {
    value: { reload: jest.fn() }
  })
});

beforeEach(() => jest.resetAllMocks() )

describe('worker is complete after 2 API calls', () => {
  const worker_id = Math.random().toString(36).slice(-5) // random string

  beforeEach(() => {
    axios.get
      .mockResolvedValueOnce({ data: { status: 'working' } })
      .mockResolvedValueOnce({ data: { status: 'complete' } })

    document.body.innerHTML = `<div class="worker-waiter" data-worker-id="${worker_id}"></div>`
  })

  it('polls the correct endpoint twice', done => {
    require('worker_waiter')({
      poll_interval: 0,
      callback: () => {
        const endpoint = `/v1/workers/${worker_id}`
        expect(axios.get.mock.calls).toEqual([[endpoint], [endpoint]])
        done()
      }
    })
  })

  it('reloads the page', done => {
    require('worker_waiter')({
      poll_interval: 0,
      callback: () => {
        expect(window.location.reload).toBeCalled()
        done()
      }
    })
  })
})

describe('worker is complete after only 1 API call', () => {
  const worker_id = Math.random().toString(36).slice(-5) // random string

  beforeEach(() => {
    axios.get.mockResolvedValueOnce({ data: { status: 'complete' } })

    document.body.innerHTML = `<div class="worker-waiter" data-worker-id="${worker_id}"></div>`
  })

  it('polls the correct endpoint once', done => {
    require('worker_waiter')({
      poll_interval: 0,
      callback: () => {
        const endpoint = `/v1/workers/${worker_id}`
        expect(axios.get.mock.calls).toEqual([[endpoint]])
        done()
      }
    })
  })

  it('reloads the page', done => {
    require('worker_waiter')({
      poll_interval: 0,
      callback: () => {
        expect(window.location.reload).toBeCalled()
        done()
      }
    })
  })
})

describe('page does not have any worker-waiter component', () => {
  beforeEach(() => {
    axios.get.mockImplementation()
    document.body.innerHTML = '<div></div>'
  })

  it('does not poll the endpoint', done => {
    require('worker_waiter')({
      callback: () => {
        expect(axios.get.mock.calls.length).toBe(0)
        done()
      }
    })
  })

  it('does not reloads the page', done => {
    require('worker_waiter')({
      poll_interval: 0,
      callback: () => {
        expect(window.location.reload).not.toBeCalled()
        done()
      }
    })
  })
})
