import axios from 'axios';
import { hide, show } from '../helpers';
var typingTimer;                //timer identifier
var doneTypingInterval = 400;  //time in ms, 1.5 second for example
var ariaText;

async function searchResults(search_term){
  let url = '/v1/proceeding_types?search_term=' + search_term
  const response = await axios.get(url)
  return response.data
}

function doneTyping () {
  document.querySelector('#screen-reader-messages').innerHTML = ariaText
  const inputText = document.querySelector("#proceeding-search-input").value.trim()
  if (inputText.length > 2) {
    hideProceeedingsItems()
    searchResults(inputText).then(results => {
      showResults(results, inputText)
    })
  }
}

function searchOnUserInput(searchInputBox) {

  searchInputBox.addEventListener("keyup", (event) => {
    clearTimeout(typingTimer);
    typingTimer = setTimeout(doneTyping, doneTypingInterval);
  })

  searchInputBox.addEventListener("keydown", () => {
    clearTimeout(typingTimer);
  })

  document.querySelector('#clear-proceeding-search').addEventListener('click', () => {
    searchInputBox.value = ""
    hideProceeedingsItems()
  })

  // TODO: remove this when the multiple proceedings feature flag is removed
  let proceedingItems = document.querySelectorAll('.proceeding-item')
  if (proceedingItems.length) {
    proceedingItems.forEach((item) => {
      item.addEventListener('mouseover', () => { item.classList.add('hover') })
      item.addEventListener('mouseout', () => { item.classList.remove('hover') })
      item.addEventListener('click', () => { return submitForm(item) })
      item.addEventListener('keydown', (e) => {
        if (e.which === 13) {
          return submitForm(item)
        }
      })
    })
  }
}

function showResults(results, inputText) {
  if (results.length > 0) {
    const codes = results.map(obj => obj["code"])
    codes.forEach(code => {
      // const element = $('#' + code)
      var element = document.getElementById(code)

      // We want to highlight anything text in <main> or <span> tags that
      // matches the user's search criteria
      const span = element.querySelector("span")
      // remove h3 when the multiple proceedings feature flag is removed
      const main = element.querySelectorAll("h3, label")[0]

      // Remove any existing highlighting
      main.innerHTML = main.innerHTML.replace(/<mark class="highlight">(.*)<\/mark>/, '$1')
      span.innerHTML = span.innerHTML.replace(/<mark class="highlight">(.*)<\/mark>/, '$1')

      // Highlight any text that matches the user's input
      const regExp = RegExp(inputText, 'gi')
      main.innerHTML = main.innerHTML.replace(regExp, '<mark class="highlight">$&</mark>')
      span.innerHTML = span.innerHTML.replace(regExp, '<mark class="highlight">$&</mark>')

      // show hidden proceedings item
      show(element)
      hide(document.querySelector(".no-proceeding-items"))
      // the below alerts screen reader users that results appeared on the page
      ariaText = codes.length + ' ' + pluralize(codes.length, 'match', 'matches') + ' found for ' + inputText + ', use tab to move through options';
      })
    }
  else {
    show(document.querySelector(".no-proceeding-items"))
    ariaText = 'No results found matching ' + inputText
  }
}

function hideProceeedingsItems() {
  document.querySelectorAll(".proceeding-item").forEach((item) => {
    hide(item)
  })
  hide(document.querySelector(".no-proceeding-items"))
}

const pluralize = (val, word, plural = word + 's') => {
  const _pluralize = (num, word, plural = word + 's') =>
      [1, -1].includes(Number(num)) ? word : plural;
  if (typeof val === 'object') return (num, word) => _pluralize(num, word, val[word]);
  return _pluralize(val, word, plural);
};

let submitForm = proceedingItem => {
  let form = proceedingItem.querySelector('form')
  if (form) { form.submit() }
  return false
}

document.addEventListener('DOMContentLoaded', event => {
  const searchInputBox = document.querySelector("#proceeding-search-input")
  if (searchInputBox) {searchOnUserInput(searchInputBox)}
});

export {searchResults, searchOnUserInput, showResults};
