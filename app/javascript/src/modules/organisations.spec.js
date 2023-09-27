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
  const searchTerm = 'irrelevant due to stubbing'
  const host = 'http://example.com'

  beforeEach(async () => {
    axios
      .mockResolvedValue({ data: { data: [] } })
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
        `<div>
          <div class="govuk-radios">
            <div id="280361" class="organisation-item" style="display: none;">
              <div>
                <input>
                <label class="govuk-label">Angus Council</label>
                <div class="govuk-hint">Local Authority</div>
              </div>
            </div>
          </div>
        </div>
        <div class="no-organisation-items" style="display: none;">
          <div>
            <span>No results found.</span>
          </div>
        </div>`

      const inputText = 'irrelevant due to stubbing'
      const element = document.getElementById('280361')
      const label = element.querySelector('.govuk-label')
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
        `<div>
          <div class="govuk-radios">
            <div id="280361" class="organisation-item" style="display: none;">
              <div>
                <input>
                  <label class="govuk-label">Angus Council</label>
                  <div class="govuk-hint">Local Authority</div>
              </div>
            </div>
          </div>
        </div>
        <div class="no-organisation-items" style="display: none;">
          <div>
            <span>No results found.</span>
          </div>
        </div>`

      const inputText = 'irrelevant due to stubbing'
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

describe('Organisations.addSearchInputListeners', () => {
  describe('clear search event listener', () => {
    it('clears all search result elements', () => {
      document.body.innerHTML =
        `
        <input id="organisation-search-input" name="organisation-search-input" type="text" autocomplete="off" value="ang">
        <a id="clear-organisation-search" href="#">Clear search</a>
        <div>
          <div class="govuk-radios">
            <div id="280361" class="organisation-item" style="display: block;">
              <div>
                  <input type="radio" value="280361" name="id" checked>
                  <label class="govuk-label">Angus Council</label>
                  <div class="govuk-hint">Local Authority</div>
              </div>
            </div>
          </div>
        </div>
        <div class="no-organisation-items" style="display: none;">
          <div>
            <span>No results found.</span>
          </div>
        </div>
        <div id="screen-reader-messages">1 match found for ang, use tab to move to options</div>
        `

      const searchInputBox = document.querySelector('#organisation-search-input')
      const clearSearch = document.getElementById('clear-organisation-search')
      const organisations = document.querySelectorAll('.organisation-item')

      // add event listener
      Organisations.addSearchInputListeners(searchInputBox)

      expect(searchInputBox.value).toEqual('ang')
      organisations.forEach((item) => {
        expect(item).toBeVisible()
        expect(item.querySelector('input')).toBeChecked()
      })

      clearSearch.click()

      expect(searchInputBox.value).toEqual('')
      organisations.forEach((item) => {
        expect(item).not.toBeVisible()
        expect(item.querySelector('input')).not.toBeChecked()
      })
    })
  })
})
