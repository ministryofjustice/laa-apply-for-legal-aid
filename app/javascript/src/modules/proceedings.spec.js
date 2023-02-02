import axios from 'axios'
import * as ProceedingsTypes from './proceedings'

jest.mock('axios')

beforeEach(() => jest.resetAllMocks())

afterEach(() => jest.restoreAllMocks())

describe('ProceedingsTypes.searchResults', () => {
  let result

  beforeEach(async () => {
    axios.mockResolvedValue({ data: { data: [] } })
      .mockResolvedValueOnce({ data: { data: ['proceeding_type1', 'proceeding_type2'] } })
  })

  describe('searching single word', () => {
    const searchTerm = 'family'
    const excludeCodes = ''
    const host = 'hhtp://example.com'
    beforeEach(async () => {
      result = await ProceedingsTypes.searchResults(host, searchTerm, excludeCodes)
    })

    it('calls axios.post once', () => {
      expect(axios).toHaveBeenCalledTimes(1)
    })

    it.skip('polls the correct endpoint that ends with searches', () => {
      expect(axios.post.mock.calls).toMatchObject(/\/proceeding_types\/searches/)
    })

    it('returns correct values', () => {
      expect(result).toEqual(['proceeding_type1', 'proceeding_type2'])
    })

    describe('returns successful values for up to 3 failed match attempts before resetting', () => {
      const searchResultValues = [
        [searchTerm, 1, ['proceeding_type1', 'proceeding_type2']],
        [searchTerm, 2, ['proceeding_type1', 'proceeding_type2']],
        [searchTerm, 3, ['proceeding_type1', 'proceeding_type2']],
        [searchTerm, 4, []]
      ]

      test.each(searchResultValues)(
        'Call searchResults %number of times',
        (term, number, expected) => {
          Array.from(Array(number)).forEach(() => {
            result = ProceedingsTypes.searchResults(term)
          })

          return expect(result).resolves.toEqual(expected)
        }
      )
    })
  })

  describe('searching multiple words', () => {
    describe('returns successful values if no matches and previous search term similar', () => {
      const searchResultValues = [
        ['Domesti Abu', 'domes abuse', ['proceeding_type1', 'proceeding_type2']],
        ['domes abuse', 'domestic', ['proceeding_type1', 'proceeding_type2']],
        ['domestic', 'sid', []]
      ]

      test.each(searchResultValues)(
        'Call searchResults %number of times',
        async (previousSearchTerm, nextSearchTerm, expected) => {
          const excludedCodes = '' // not needed for this test
          await ProceedingsTypes.searchResults('http://fakehost.com', previousSearchTerm, excludedCodes)
          result = ProceedingsTypes.searchResults('http://fakehost.com', nextSearchTerm, excludedCodes)
          return expect(result).resolves.toEqual(expected)
        }
      )
    })
  })
})
