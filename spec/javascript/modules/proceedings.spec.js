import axios from 'axios';
import * as ProceedingsTypes from 'proceedings';

jest.mock('axios');

beforeEach(() => jest.resetAllMocks());

afterEach(() => jest.restoreAllMocks());

describe('ProceedingsTypes.searchResults', () => {
  const searchTerm = 'family';
  let result;

  beforeEach(async () => {
    axios.get
      .mockResolvedValue({ data: [] })
      .mockResolvedValueOnce({ data: ['proceeding_type1', 'proceeding_type2'] });

    result = await ProceedingsTypes.searchResults(searchTerm);
  });

  it('calls axios.get once', () => {
    expect(axios.get).toHaveBeenCalledTimes(1);
  });

  it('polls the correct endpoint', () => {
    let endpoint = `/v1/proceeding_types?search_term=${searchTerm}&sourceUrl=http://localhost/`;
    expect(axios.get.mock.calls).toEqual([[endpoint]]);
  });

  it('returns correct values', () => {
    expect(result).toEqual(['proceeding_type1', 'proceeding_type2']);
  });

  describe('returns successful values for up to 3 failed match attempts before resetting', () => {
    const searchResultValues = [
      [searchTerm, 1, ['proceeding_type1', 'proceeding_type2']],
      [searchTerm, 2, ['proceeding_type1', 'proceeding_type2']],
      [searchTerm, 3, ['proceeding_type1', 'proceeding_type2']],
      [searchTerm, 4, []]
    ];

    test.each(searchResultValues)(
      'Call searchResults %number of times',
      (term, number, expected) => {
        Array.from(Array(number)).forEach(() => {
          result = ProceedingsTypes.searchResults(term);
        });

        return expect(result).resolves.toEqual(expected);
      }
    );
  });
});
