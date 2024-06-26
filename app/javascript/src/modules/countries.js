import axios from 'axios'
import { hide, show, pluralize } from '../helpers'

const doneTypingInterval = 500 // time in ms, 500ms to make search work fairly quickly but avoid too many DB requests
const screenReaderMessageDelay = 1000 // wait before updating the screen reader message, to avoid interrupting queue
let typingTimer
let ariaText

async function searchResults (host, searchTerm) {
  const url = `${host}/countries/search`
  const response = await axios({
    accept: 'application/json',
    responseType: 'json',
    method: 'post',
    url,
    data: {
      search_term: searchTerm
    }
  })
  return response.data.data
}

function showResults (results, inputText) {
  if (results.length > 0) {
    const countriesContainer = document.querySelector('.govuk-radios') // generated by https://govuk-form-builder.netlify.app/form-elements/radios/

    results.forEach((result, idx) => {
      const element = document.getElementById(result.code)
      const label = element.querySelector('.govuk-label')

      // Replace text values with "headlines" from result/data payload
      label.innerHTML = result.description_headline

      // move to top of list, but after previously added results
      countriesContainer.insertBefore(element, countriesContainer.children[idx])

      // show the countries item
      show(element)
      hide(document.querySelector('.no-country-items'))
    })

    // the below alerts screen reader users that results appeared on the page
    const pluralizedMatches = pluralize(results.length, 'match', 'matches')
    ariaText = `${results.length} ${pluralizedMatches} found for ${inputText}, use tab to move to options`
  } else {
    show(document.querySelector('.no-country-items'))
    ariaText = `No results found matching ${inputText}`
  }
}

// Calls search only when the typing timer expires
async function doneTyping () {
  const host = document.querySelector('#legal-framework-api-host').getAttribute('data-uri').trim()
  const inputText = document.querySelector('input[name="non_uk_home_address[country_name]"]').value.trim()

  hideCountryItems()
  deselectPreviousCountryItem()

  if (inputText.length > 2) {
    const results = await searchResults(host, inputText)
    showResults(results, inputText)
  } else {
    ariaText = 'No text entered.'
  }

  setTimeout(() => { document.querySelector('#screen-reader-messages').innerHTML = ariaText }, screenReaderMessageDelay)
}

function addSearchInputListeners (searchInputBox) {
  searchInputBox.addEventListener('keyup', (event) => {
    clearTimeout(typingTimer)
    typingTimer = setTimeout(doneTyping, doneTypingInterval)
  })

  searchInputBox.addEventListener('keydown', () => clearTimeout(typingTimer))

  document
    .querySelector('#clear-country-search')
    .addEventListener('click', () => {
      searchInputBox.value = ''
      hideCountryItems()
      deselectPreviousCountryItem()
      setTimeout(() => { document.querySelector('#screen-reader-messages').innerHTML = 'Search box has been cleared.' }, screenReaderMessageDelay)
    })
}

function hideCountryItems () {
  document
    .querySelectorAll('.country-item')
    .forEach(item => hide(item))

  hide(document.querySelector('.no-country-items'))
}

function deselectPreviousCountryItem () {
  const selected = document.querySelector('input:checked')
  if (selected !== null) { selected.checked = false }
}

document.addEventListener('DOMContentLoaded', event => {
  const searchInputBox = document.querySelector('input[name="non_uk_home_address[country_name]"]')
  if (searchInputBox) addSearchInputListeners(searchInputBox)
})

export { addSearchInputListeners, searchResults, showResults }
