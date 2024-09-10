import accessibleAutocomplete from 'accessible-autocomplete'

accessibleAutocomplete.enhanceSelectElement({
  defaultValue: '',
  selectElement: document.querySelector('#non-uk-home-address-country-code-field')
})

const screenReaderMessageDelay = 1000 // wait before updating the screen reader message, to avoid interrupting queue
const searchInputBox = document.querySelector('#non-uk-home-address-country-code-field')

document
  .querySelector('#clear-country-search')
  .addEventListener('click', () => {
    searchInputBox.value = ''
    setTimeout(() => { document.querySelector('#screen-reader-messages').innerHTML = 'Search box has been cleared.' }, screenReaderMessageDelay)
  })
