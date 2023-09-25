import axios from 'axios'
import * as Organisations from './organisations'

jest.mock('axios')

beforeEach(() => jest.resetAllMocks())

afterEach(() => jest.restoreAllMocks())

const StubbedResult = {
  success: true,
  data: [
    {
      name: 'Angus Council',
      ccms_opponent_id: '280361',
      ccms_type_code: 'LA',
      ccms_type_text: 'Local Authority',
      name_headline: '<mark>Angus</mark> Council',
      type_headline: '<mark>Local</mark> Authority'
    }
  ]
}

describe('Organisations.searchResults', () => {
  let result
  const searchTerm = 'irrelevant'
  const host = 'http://example.com'

  beforeEach(async () => {
    axios.mockResolvedValue({ data: { data: [] } })
      .mockResolvedValueOnce({ data: StubbedResult })
  })

  beforeEach(async () => {
    result = await Organisations.searchResults(host, searchTerm)
  })

  it('calls axios.post once', () => {
    expect(axios).toHaveBeenCalledTimes(1)
  })

  it('polls the correct endpoint', () => {
    expect(axios.post.mock.calls).toMatchObject(/\/organisations_searches/)
  })

  it('returns response\'s data element', () => {
    expect(result).toEqual(StubbedResult.data)
  })
})

describe('Organisations.showResults', () => {
  describe('with results', () => {
    const results = StubbedResult.data

    it('displays matching results with highlighted terms', () => {
      document.body.innerHTML =
        '<div>' +
          '<div class="govuk-radios">' +
            '<div id="280361" class="organisation-item" style="display: none;">' +
              '<div>' +
                '<input>' +
                  '<label>Angus Council</label>' +
                  '<div class="govuk-hint">Local Authority</div>' +
              '</div>' +
            '</div>' +
          '</div>' +
        '</div>' +
        '<div class="no-organisation-items" style="display: none;">' +
          '<div>' +
            '<span>No results found.</span>' +
          '</div>' +
        '</div>'

      const inputText = 'Ang'
      const element = document.getElementById('280361')
      const label = element.querySelector('label')
      const hint = element.querySelector('.govuk-hint')
      const noResultsElement = document.querySelector('.no-organisation-items')

      expect(element).not.toBeVisible()
      expect(noResultsElement).not.toBeVisible()
      expect(label.innerHTML).toEqual('Angus Council')
      expect(hint.innerHTML).toEqual('Local Authority')

      Organisations.showResults(results, inputText)

      expect(element).toBeVisible()
      expect(noResultsElement).not.toBeVisible()
      expect(label.innerHTML).toEqual('<mark>Angus</mark> Council')
      expect(hint.innerHTML).toEqual('<mark>Local</mark> Authority')
    })
  })

  describe('with no results', () => {
    const results = []

    it('hides all results', () => {
      document.body.innerHTML =
        '<div>' +
          '<div class="govuk-radios">' +
            '<div id="280361" class="organisation-item" style="display: none;">' +
              '<div>' +
                '<input>' +
                  '<label>Angus Council</label>' +
                  '<div class="govuk-hint">Local Authority</div>' +
              '</div>' +
            '</div>' +
          '</div>' +
        '</div>' +
        '<div class="no-organisation-items" style="display: none;">' +
          '<div>' +
            '<span>No results found.</span>' +
          '</div>' +
        '</div>'

      const inputText = 'Ang'
      const element = document.getElementById('280361')
      const label = element.querySelector('label')
      const hint = element.querySelector('.govuk-hint')
      const noResultsElement = document.querySelector('.no-organisation-items')

      expect(element).not.toBeVisible()
      expect(noResultsElement).not.toBeVisible()
      expect(label.innerHTML).toEqual('Angus Council')
      expect(hint.innerHTML).toEqual('Local Authority')

      Organisations.showResults(results, inputText)

      expect(element).not.toBeVisible()
      expect(noResultsElement).toBeVisible()
      expect(label.innerHTML).toEqual('Angus Council')
      expect(hint.innerHTML).toEqual('Local Authority')
    })
  })
})
