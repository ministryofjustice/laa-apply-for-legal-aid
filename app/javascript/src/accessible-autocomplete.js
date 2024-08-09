import axios from 'axios'
import accessibleAutocomplete from 'accessible-autocomplete'

async function getProceedings () {
  const host = document.querySelector('#exclude_codes').getAttribute('data-uri').trim()
  const response = await axios.get(`${host}/proceeding_types/all`)
  const proceedings = response.data.map((item) => `${item.meaning} <br> ${item.ccms_category_law} (${item.ccms_matter})`)

  accessibleAutocomplete({
    element: document.querySelector('#autocomplete-container'),
    id: 'proceeding-search-input', // To match it to the existing <label>.
    source: proceedings.sort()
  })
}
getProceedings()
