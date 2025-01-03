import accessibleAutocomplete from 'accessible-autocomplete'

const screenReaderMessageDelay = 1000 // wait before updating the screen reader message, to avoid interrupting queue

function enhanceSelectElement (autocompleteComponent) {
  const searchSelectItem = autocompleteComponent.querySelector('.country-select')
  const clearSearchButton = autocompleteComponent.querySelector('.clear-search')
  const selectName = searchSelectItem.getAttribute('name')

  accessibleAutocomplete.enhanceSelectElement({
    defaultValue: '',
    selectElement: searchSelectItem,
    inputClasses: 'govuk-input',
    name: selectName
  })

  addSearchInputListeners(autocompleteComponent, clearSearchButton)

  if (autocompleteComponent.querySelector('.govuk-error-message')) {
    addErrorClasses(autocompleteComponent, clearSearchButton)
  }
}

function addSearchInputListeners (autocompleteComponent, clearSearchButton) {
  const searchInputBox = autocompleteComponent.querySelector('.autocomplete__input')
  clearSearchButton.classList.remove('hidden')

  clearSearchButton
    .addEventListener('click', (event) => {
      event.preventDefault()
      searchInputBox.value = ''
      clearSearch(autocompleteComponent)
      setTimeout(() => { autocompleteComponent.querySelector('.screen-reader-messages').innerHTML = 'Search box has been cleared.' }, screenReaderMessageDelay)
    })
}

function clearSearch (autocompleteComponent) {
  const selectedItem = autocompleteComponent.querySelector('.country-select option[selected]')
  if (selectedItem) selectedItem.removeAttribute('selected')
}

function addErrorClasses (autocompleteComponent, clearSearchButton) {
  autocompleteComponent.querySelector('.autocomplete__input').classList.add('govuk-input--error')
  clearSearchButton.classList.add('clear-search-error')
}

document.addEventListener('DOMContentLoaded', () => {
  const autocompleteComponent = document.querySelector('.autocomplete-component')

  if (autocompleteComponent) enhanceSelectElement(autocompleteComponent)
})
