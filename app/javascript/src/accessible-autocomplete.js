import accessibleAutocomplete from 'accessible-autocomplete'

const screenReaderMessageDelay = 1000 // wait before updating the screen reader message, to avoid interrupting queue
const searchSelectItem = document.querySelector('.country-select')

function enhanceSelectElement (searchSelectItem) {
  accessibleAutocomplete.enhanceSelectElement({
    defaultValue: '',
    selectElement: searchSelectItem,
    inputClasses: 'govuk-input',
    name: 'country'
  })

  addSearchInputListeners()

  if (document.querySelector('#non-uk-home-address-country-code-error')) {
    addErrorClasses()
  }
}

function addSearchInputListeners () {
  const searchInputBox = document.querySelector('.autocomplete__input')

  document.querySelector('.clear-search').style.display = 'block'

  document
    .querySelector('#clear-country-search')
    .addEventListener('click', (event) => {
      event.preventDefault()
      searchInputBox.value = ''
      setTimeout(() => { document.querySelector('#screen-reader-messages').innerHTML = 'Search box has been cleared.' }, screenReaderMessageDelay)
    })
}

function addErrorClasses () {
  document.querySelector('.autocomplete__input').classList.add('govuk-input--error')
  document.querySelector('.clear-search').classList.add('clear-search-error')
}

document.addEventListener('DOMContentLoaded', () => {
  if (searchSelectItem) enhanceSelectElement(searchSelectItem)
})
