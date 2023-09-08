import axios from 'axios'
import { hide, show, pluralize } from '../helpers'

const doneTypingInterval = 500 // time in ms, 500ms to make search work fairly quickly but avoid too many DB requests
const screenReaderMessageDelay = 1000 // wait before updating the screenreader message, to avoid interrupting queue
let typingTimer
let ariaText
let organisationMatches = []
let noMatchCount = 0
let previousSearchTerm = null
let containSimilarWords = false

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
  return updateMatchCounters(data, searchTerm)
}

function setMatchAndCount (data = [], searchTerm = null) {
  noMatchCount = 0
  organisationMatches = data
  previousSearchTerm = searchTerm
}

function substrInArrayOfWords (wordArray1, wordArray2) {
  const matches1 = wordArray1.map(substr => !!wordArray2.find(w => w.includes(substr)))
  const matches2 = wordArray2.map(substr => !!wordArray1.find(w => w.includes(substr)))
  return matches1.includes(true) || matches2.includes(true)
}

function checkSimilarWords (searchTerm) {
  if (searchTerm && previousSearchTerm) {
    const inputLower = searchTerm.toLowerCase().split(/\s+/)
    const previousLower = previousSearchTerm.toLowerCase().split(/\s+/)
    containSimilarWords = substrInArrayOfWords(inputLower, previousLower)
  }
}

function updateMatchCounters (data, searchTerm) {
  checkSimilarWords(searchTerm)

  if (data && data.length) {
    setMatchAndCount(data, searchTerm)
  } else if (!data || !containSimilarWords) {
    setMatchAndCount()
  } else if (organisationMatches.length) {
    noMatchCount++
    if (noMatchCount > 3) setMatchAndCount()
  }

  return organisationMatches
}

// Calls search only when the typing timer expires
async function doneTyping () {
  const host = document.querySelector('#legal-framework-api-host').getAttribute('data-uri').trim()
  const inputText = document.querySelector('#organisation-search-input').value.trim()

  if (inputText.length > 2) {
    hideOrganisationItems()
    const results = await searchResults(host, inputText)
    showResults(results, inputText)
  } else {
    ariaText = 'No text entered.'
    updateMatchCounters()
    hideOrganisationItems()
  }
  setTimeout(() => { document.querySelector('#screen-reader-messages').innerHTML = ariaText }, screenReaderMessageDelay)
}

// Add event listeners for the user typing in the search box and clearing the search
function searchOnUserInput (searchInputBox) {
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

function removeMatchingHtml (obj, regexpsForReplacment) {
  regexpsForReplacment.forEach(function (regExp) {
    obj.innerHTML = obj.innerHTML.replace(regExp, '')
  })
}

// Find the existing hidden organisation items
// If they are one of the search matches returned from the V1 api, remove the hidden class
// and highlight the search terms in the item text
function showResults (results, inputText) {
  if (results.length > 0) {
    deselectPreviousOrganisationItem()
    const codes = results.map(obj => obj.ccms_opponent_id)
    let organisationsContainer = document.querySelector('.govuk-radios') // with MP flag on
    if (organisationsContainer == null) { organisationsContainer = document.querySelector('#organisation-list') } // with MP flag off
    codes.forEach((code, idx) => {
      const element = document.getElementById(code)

      // We want to highlight anything in the label or hint text that
      // matches the user's search criteria
      const label = element.querySelector('label')
      const hint = element.querySelector('.govuk-hint')
      const highlightTagStart = '<mark class="highlight">'
      const highlightTagEnd = '</mark>'
      const highlightStartRegExp = RegExp(highlightTagStart, 'gi')
      const highlightEndRegExp = RegExp(highlightTagEnd, 'gi')

      // Remove existing highlighting
      removeMatchingHtml(label, [highlightStartRegExp, highlightEndRegExp])
      removeMatchingHtml(hint, [highlightStartRegExp, highlightEndRegExp])

      // Highlight text that matches the user's input
      const terms = inputText.split(' ')
      terms.forEach((term) => {
        // Negative lookahead conjuction AND negative lookbehind conjuction (non-capturing)
        // required to exclude any previous search term highlighting which can result in partial HTML
        // being output to the screen.
        //
        // However, this means only the first matched term will be highlighted per object/string/phrase
        // and this puts it out of sync with the actual fuzzy search matching which works and matches
        // on a second term even if it is only 1 character.
        // example: try searching for "ri prison" and only "ri" will be highlighted, despite "prison"
        // being the type.
        //
        // TODO: regex that does not highlight inside a highlight, thereby allowing displaying all matching uniq terms per phrase
        //
        const regExp = RegExp('(?!.*' + highlightTagStart + '.*)' + '(?!.*' + highlightTagEnd + '.*)' + '(' + term.trim() + ')' + '(?<!.*' + highlightTagStart + '.*)' + '(?<!.*' + highlightTagEnd + '.*)', 'gi')
        label.innerHTML = label.innerHTML.replace(regExp, highlightTagStart + '$&' + highlightTagEnd)
        hint.innerHTML = hint.innerHTML.replace(regExp, highlightTagStart + '$&' + highlightTagEnd)
      })

      // move to top of list, but after previously added elements
      organisationsContainer.insertBefore(element, organisationsContainer.children[idx])
      // show hidden organisations item
      show(element)
      hide(document.querySelector('.no-organisation-items'))
    })
    // the below alerts screen reader users that results appeared on the page
    const pluralizedMatches = pluralize(codes.length, 'match', 'matches')
    ariaText = `${codes.length} ${pluralizedMatches} found for ${inputText}, use tab to move through options`
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

function disableBackButton () {
  window.history.pushState(null, document.title, window.location.href)
  window.addEventListener('popstate', function (event) {
    window.history.pushState(null, document.title, window.location.href)
  })
}

if (window.location.href.includes('organisations_types')) {
  disableBackButton()
}

// If the organisations type search box appears on the page, call the searchOnUserInput function
document.addEventListener('DOMContentLoaded', event => {
  const searchInputBox = document.querySelector('#organisation-search-input')
  if (searchInputBox) searchOnUserInput(searchInputBox)
})

export { searchResults, searchOnUserInput, showResults }
