// import axios from 'axios'
import accessibleAutocomplete from 'accessible-autocomplete'

// async function getProceedings () {
//   const host = document.querySelector('#exclude_codes').getAttribute('data-uri').trim()
//   const response = await axios.get(`${host}/proceeding_types/all`)
//   // const proceedings = response.data.map((item) => `${item.meaning} <br> ${item.ccms_category_law} (${item.ccms_matter})`)
//   const proceedings = response.data
//   console.log(proceedings)

// }

// const getProceedings = async () => {
//   const host = document.querySelector('#exclude_codes').getAttribute('data-uri').trim()
//   const url = `${host}/proceeding_types/all`
//   return await fetch(url)
//     .then(response => (response.json()))
//     .then(data => {
//       return data
//     })
//   }
// function inputValue (result) {
//   return result
// }

// function suggestionValue (result) {
//   return result
// }

// console.log(getProceedings())

// accessibleAutocomplete({
//   element: document.querySelector('#autocomplete-container'),
//   id: 'proceeding-search-input', // To match it to the existing <label>.
//   source: proceedings,
//   templates: {
//     inputValue: inputValue,
//     suggestion: suggestionValue,
//   }
// })
// getProceedings()

// function suggestionValue(result) {
//   return result + "!"
// }

// function inputValue (result) {
//   return result && result.replace('/', '').replace("*", "")
// }

accessibleAutocomplete.enhanceSelectElement({
  selectElement: document.querySelector('#legal-aid-application-proceeding-field'),
  templates: {
    suggestion: suggestionValue,
    // inputValue: inputValue,
  }
})
