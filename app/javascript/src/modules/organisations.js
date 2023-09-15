import axios from 'axios'
import { hide, show, pluralize } from '../helpers'

const doneTypingInterval = 500 // time in ms, 500ms to make search work fairly quickly but avoid too many DB requests
const screenReaderMessageDelay = 1000 // wait before updating the screenreader message, to avoid interrupting queue
let typingTimer
let ariaText

async function searchResults (host, searchTerm) {
  const url = `${host}/organisation_searches`
  const response = await axios({
    accept: 'application/json',
    responseType: 'json',
    method: 'post',
    url,
    data: {
      search_term: searchTerm
    }
  })
  const data = response.data.data
  return data
}

// Calls search only when the typing timer expires
async function doneTyping () {
  const host = document.querySelector('#legal-framework-api-host').getAttribute('data-uri').trim()
  const inputText = document.querySelector('#organisation-search-input').value.trim()

  hideOrganisationItems()
  deselectPreviousOrganisationItem()

  if (inputText.length > 2) {
    const results = await searchResults(host, inputText)
    showResults(results, inputText)
  } else {
    ariaText = 'No text entered.'
  }

  setTimeout(() => { document.querySelector('#screen-reader-messages').innerHTML = ariaText }, screenReaderMessageDelay)
}

// Add event listeners for the user typing in the search box and clearing the search
function addSearchInputListeners (searchInputBox) {
  searchInputBox.addEventListener('keyup', (event) => {
    clearTimeout(typingTimer)
    typingTimer = setTimeout(doneTyping, doneTypingInterval)
  })

  searchInputBox.addEventListener('keydown', () => clearTimeout(typingTimer))

  document
    .querySelector('#clear-organisation-search')
    .addEventListener('click', () => {
      searchInputBox.value = ''
      hideOrganisationItems()
      setTimeout(() => { document.querySelector('#screen-reader-messages').innerHTML = 'Search box has been cleared.' }, screenReaderMessageDelay)
    })
}

function deselectPreviousOrganisationItem () {
  const selected = document.querySelector('input:checked')
  if (selected !== null) { selected.checked = false }
}

// 1. Find the existing hidden organisation items by their `ccms_opponent_id`
// 2. replace their label and hint with highlighted/match markup from results
// 3. show the item
function showResults (results, inputText) {
  if (results.length > 0) {
    // const codes = results.map(obj => { id: obj.ccms_opponent_id,)
    let organisationsContainer = document.querySelector('.govuk-radios') // with MP flag on
    if (organisationsContainer == null) { organisationsContainer = document.querySelector('#organisation-list') } // with MP flag off

    results.forEach((result, idx) => {
      const element = document.getElementById(result.ccms_opponent_id)
      const label = element.querySelector('label')
      const hint = element.querySelector('.govuk-hint')

      // Replace option text value with "headlines" from result/data payload
      label.innerHTML = result.name_headline
      hint.innerHTML = result.type_headline

      // move to top of list, but after previously added elements
      organisationsContainer.insertBefore(element, organisationsContainer.children[idx])

      // show hidden organisations item
      show(element)
      hide(document.querySelector('.no-organisation-items'))
    })

    // the below alerts screen reader users that results appeared on the page
    const pluralizedMatches = pluralize(results.length, 'match', 'matches')
    ariaText = `${results.length} ${pluralizedMatches} found for ${inputText}, use tab to move to options`
  } else {
    show(document.querySelector('.no-organisation-items'))
    ariaText = `No results found matching ${inputText}`
  }
}

// Hide any search results and the 'no results found' text
function hideOrganisationItems () {
  document
    .querySelectorAll('.organisation-item')
    .forEach(item => hide(item))

  hide(document.querySelector('.no-organisation-items'))
}

// If the organisations search box appears on the page, then Event listenrs to it
document.addEventListener('DOMContentLoaded', event => {
  const searchInputBox = document.querySelector('#organisation-search-input')
  if (searchInputBox) addSearchInputListeners(searchInputBox)
})

export { searchResults, addSearchInputListeners, showResults }
