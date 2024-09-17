import accessibleAutocomplete from 'accessible-autocomplete'

const screenReaderMessageDelay = 1000 // wait before updating the screen reader message, to avoid interrupting queue
const searchInputBox = document.querySelector('.country-select')

accessibleAutocomplete.enhanceSelectElement({
  defaultValue: '',
  selectElement: searchInputBox
})

document
  .querySelector('#clear-country-search')
  .addEventListener('click', () => {
    searchInputBox.value = ''
    setTimeout(() => { document.querySelector('#screen-reader-messages').innerHTML = 'Search box has been cleared.' }, screenReaderMessageDelay)
  })
