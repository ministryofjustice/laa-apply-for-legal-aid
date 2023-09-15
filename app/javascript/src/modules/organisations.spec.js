import axios from 'axios'
import * as Organisations from './organisations'

jest.mock('axios')

beforeEach(() => jest.resetAllMocks())

afterEach(() => jest.restoreAllMocks())

describe('Organisations.searchResults', () => {
  let result

  beforeEach(async () => {
    axios.mockResolvedValue({ data: { data: [] } })
      .mockResolvedValueOnce({ data: { data: ['organisation_name_1', 'organisation_name_2'] } })
  })

  describe('searching single word', () => {
    const searchTerm = 'baberg'
    const host = 'hhtp://example.com'
    beforeEach(async () => {
      result = await Organisations.searchResults(host, searchTerm)
    })

    it('calls axios.post once', () => {
      expect(axios).toHaveBeenCalledTimes(1)
    })

    it('polls the correct endpoint that ends with searches', () => {
      expect(axios.post.mock.calls).toMatchObject(/\/organisations_searches/)
    })

    it('returns correct values', () => {
      expect(result).toEqual(['organisation_name_1', 'organisation_name_2'])
    })

    describe.skip('returns successful values for up to 3 failed match attempts before resetting', () => {
      const searchResultValues = [
        [searchTerm, 1, ['organisation_name_1', 'organisation_name_2']],
        [searchTerm, 2, ['organisation_name_1', 'organisation_name_2']],
        [searchTerm, 3, ['organisation_name_1', 'organisation_name_2']],
        [searchTerm, 4, []]
      ]

      test.each(searchResultValues)(
        'Call searchResults %number of times',
        (term, number, expected) => {
          Array.from(Array(number)).forEach(() => {
            result = Organisations.searchResults(term)
          })

          return expect(result).resolves.toEqual(expected)
        }
      )
    })
  })

  describe.skip('searching multiple words', () => {
    describe('returns successful values if no matches and previous search term similar', () => {
      const searchResultValues = [
        ['Loca Auth', 'local auth', ['organisation_name_1', 'organisation_name_2']],
        ['local auth', 'Local', ['organisation_name_1', 'organisation_name_2']],
        ['Local', 'lcl', []]
      ]

      test.each(searchResultValues)(
        'Call searchResults %number of times',
        async (previousSearchTerm, nextSearchTerm, expected) => {
          await Organisations.searchResults('https://fakehost.com', previousSearchTerm)
          result = Organisations.searchResults('https://fakehost.com', nextSearchTerm)
          return expect(result).resolves.toEqual(expected)
        }
      )
    })
  })
})
