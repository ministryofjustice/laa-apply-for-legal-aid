import axios from 'axios'
import * as ProceedingTypes from 'proceedings'

jest.mock('axios')

beforeEach(() => jest.resetAllMocks())

afterEach(() => {
  jest.restoreAllMocks();
});

describe('ProceedingTypes.getAll', () => {

  beforeEach(() => {
    axios.get.mockResolvedValueOnce({ data: { code: 'data' } })
    ProceedingTypes.getAll()
  })

  it('calls axios once', done => {
    expect(axios.get).toHaveBeenCalledTimes(1)
    done();
  })

  it('polls the correct endpoint', done => {
    let endpoint = '/v1/proceeding_types'
    expect(axios.get.mock.calls).toEqual([[endpoint]])
    done()
  })

  it('calls a get request', done => {
    expect(axios.get).toHaveBeenCalled()
    done()
  })

  it('returns correct values', () => {
    axios.get.mockResolvedValueOnce({ data: { code: 'data' } })
    return ProceedingTypes.getAll().then((result) => {
      expect(result).toEqual({ code: 'data' })
    })
  })
})

describe('ProceedingTypes.filterSearch', () => {

  beforeEach(() => {
    axios.get.mockResolvedValueOnce({ data: { code: 'data' } })
  })

  // can this be tested with jest? or should it be left to capybara to test the page

})
