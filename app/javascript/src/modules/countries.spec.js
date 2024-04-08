import axios from 'axios'
import * as Countries from './countries'

jest.mock('axios')

beforeEach(() => jest.resetAllMocks())

afterEach(() => jest.restoreAllMocks())

const StubbedResult = {
  success: true,
  data: [
    {
      code: 'GBR',
      description: 'United Kingdom',
      description_headline: '<mark>United</mark> Kingdom'
    }
  ]
}

describe('Countries.searchResults', () => {
  let result
  const searchTerm = 'irrelevant due to stubbing'
  const host = 'http://example.com'

  beforeEach(async () => {
    axios
      .mockResolvedValue({ data: { data: [] } })
      .mockResolvedValueOnce({ data: StubbedResult })
  })

  beforeEach(async () => {
    result = await Countries.searchResults(host, searchTerm)
  })

  it('calls axios.post once', () => {
    expect(axios).toHaveBeenCalledTimes(1)
  })

  it('returns response\'s data element', () => {
    expect(result).toEqual(StubbedResult.data)
  })
})

describe('Countries.showResults', () => {
  describe('with results', () => {
    const results = StubbedResult.data

    it('displays matching results with highlighted terms', () => {
      document.body.innerHTML =
        `<div>
          <div class="govuk-radios">
            <div id="GBR" class="country-item" style="display: none;">
              <div>
                <input>
                <label class="govuk-label">United Kingdom</label>
              </div>
            </div>
          </div>
        </div>
        <div class="no-country-items" style="display: none;">
          <div>
            <span>No results found.</span>
          </div>
        </div>`

      const inputText = 'irrelevant due to stubbing'
      const element = document.getElementById('GBR')
      const label = element.querySelector('.govuk-label')
      const noResultsElement = document.querySelector('.no-country-items')

      expect(element).not.toBeVisible()
      expect(noResultsElement).not.toBeVisible()
      expect(label.innerHTML).toEqual('United Kingdom')

      Countries.showResults(results, inputText)

      expect(element).toBeVisible()
      expect(noResultsElement).not.toBeVisible()
      expect(label.innerHTML).toEqual('<mark>United</mark> Kingdom')
    })
  })

  describe('with no results', () => {
    const results = []

    it('hides all results', () => {
      document.body.innerHTML =
        `<div>
          <div class="govuk-radios">
            <div id="GBR" class="country-item" style="display: none;">
              <div>
                <input>
                <label class="govuk-label">United Kingdom</label>
              </div>
            </div>
          </div>
        </div>
        <div class="no-country-items" style="display: none;">
          <div>
            <span>No results found.</span>
          </div>
        </div>`

      const inputText = 'irrelevant due to stubbing'
      const element = document.getElementById('GBR')
      const label = element.querySelector('label')
      const noResultsElement = document.querySelector('.no-country-items')

      expect(element).not.toBeVisible()
      expect(noResultsElement).not.toBeVisible()
      expect(label.innerHTML).toEqual('United Kingdom')

      Countries.showResults(results, inputText)

      expect(element).not.toBeVisible()
      expect(noResultsElement).toBeVisible()
      expect(label.innerHTML).toEqual('United Kingdom')
    })
  })
})

describe('Countries.addSearchInputListeners', () => {
  describe('clear search event listener', () => {
    it('clears all search result elements', () => {
      document.body.innerHTML =
        `
        <input id="country-search-input" name="country-search-input" type="text" autocomplete="off" value="united">
        <a id="clear-country-search" href="#">Clear search</a>
        <div>
          <div class="govuk-radios">
            <div id="GBR" class="country-item" style="display: block;">
              <div>
                  <input type="radio" value="GBR" name="id" checked>
                  <label class="govuk-label">United Kingdom</label>
              </div>
            </div>
          </div>
        </div>
        <div class="no-country-items" style="display: none;">
          <div>
            <span>No results found.</span>
          </div>
        </div>
        <div id="screen-reader-messages">5 matches found for united, use tab to move to options</div>
        `

      const searchInputBox = document.querySelector('#country-search-input')
      const clearSearch = document.getElementById('clear-country-search')
      const countries = document.querySelectorAll('.country-item')

      // add event listener
      Countries.addSearchInputListeners(searchInputBox)

      expect(searchInputBox.value).toEqual('united')
      countries.forEach((item) => {
        expect(item).toBeVisible()
        expect(item.querySelector('input')).toBeChecked()
      })

      clearSearch.click()

      expect(searchInputBox.value).toEqual('')
      countries.forEach((item) => {
        expect(item).not.toBeVisible()
        expect(item.querySelector('input')).not.toBeChecked()
      })
    })
  })
})
