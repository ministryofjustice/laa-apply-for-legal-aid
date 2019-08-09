import axios from 'axios'
import * as ProceedingTypes from 'proceedings'
import { searchProceedingTypes } from 'proceeding_types'

jest.mock('axios')

beforeEach(() => jest.resetAllMocks())

afterEach(() => {
  jest.restoreAllMocks();
});

describe('calls ProceedingTypes module', () => {
  beforeEach(() => {
    axios.get.mockResolvedValueOnce({ data: { code: 'data' } })
    jest.spyOn(ProceedingTypes, 'getAll')
    jest.spyOn(ProceedingTypes, 'filterSearch')
    searchProceedingTypes()
  })

  it('calls ProceedingTypes.getAll', done => {
    expect(ProceedingTypes.getAll).toHaveBeenCalled()
    done()
  })

  it('calls ProceedingTypes.filterSearch', done => {
    expect(ProceedingTypes.filterSearch).toHaveBeenCalledWith({ code: 'data' })
    done()
  })
})
