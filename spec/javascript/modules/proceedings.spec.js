import axios from 'axios';
import * as ProceedingsTypes from 'proceedings';

jest.mock('axios');

beforeEach(() => jest.resetAllMocks());

afterEach(() => {
  jest.restoreAllMocks();
})

describe('ProceedingsTypes.searchResults', () => {
  const searchTerm = 'family';

  beforeEach(() => {
    axios.get.mockResolvedValueOnce({ data: { code: 'data' } })
    ProceedingsTypes.searchResults(searchTerm);
  })

  it('calls axios.get once', done => {
    expect(axios.get).toHaveBeenCalledTimes(1);
    done();
  })

  it('polls the correct endpoint', done => {
    let endpoint = '/v1/proceeding_types?search_term=' + searchTerm + '&sourceUrl=http://localhost/';
    expect(axios.get.mock.calls).toEqual([[endpoint]]);
    done();
  })

  it('returns correct values', () => {
    axios.get.mockResolvedValueOnce({ data: { code: 'data' } })
    return ProceedingsTypes.searchResults().then((result) => {
      expect(result).toEqual({ code: 'data' });
    })
  })
})
