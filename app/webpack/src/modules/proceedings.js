import $ from 'jquery'
import axios from 'axios'
import * as JsSearch from 'js-search'
var typingTimer;                //timer identifier
var doneTypingInterval = 1500;  //time in ms, 1.5 second for example
var ariaText;

async function searchResults(search_term){
  let url = '/v1/proceeding_types?search_term=' + search_term
  const response = await axios.get(url)
  return response.data
}

function searchOnUserInput() {
  const searchInputBox = $("#proceeding-search-input")

  searchInputBox.keyup((event) => {
    $("#proceeding-list .proceeding-item").hide()
    $(".no-proceeding-items").hide()
    const inputText = $(event.target).val()
    if (inputText.length > 2) {
      searchResults(inputText).then(results => {
        showResults(results, inputText)
      })
    }
    clearTimeout(typingTimer);
    typingTimer = setTimeout(doneTyping, doneTypingInterval);
  })

  searchInputBox.keydown(() => {
    clearTimeout(typingTimer);
  })

  $('#clear-proceeding-search').on("click", () => searchInputBox.val("").trigger("keyup"))

  // TODO: remove this when the multiple proceedings feature flag is removed
  $('li.proceeding-item').on('mouseover', function (e) { $(this).addClass('hover') })
    .on('mouseout', function (e) { $(this).removeClass('hover') })
    .on('click', function (e) { return submitForm(this) })
    .on('keydown', function (e) {
      if (e.which == 13) {
        return submitForm(this)
      }
    })
}

function showResults(results, inputText) {
  if (results.length > 0) {
    const codes = results.map(obj => obj["code"])
    console.log(codes)
    codes.forEach(code => {
      // const element = $('#' + code)
      var element = document.getElementById(code)
      console.log(element)

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
      main.innerHTML = main.innerHTML.replace(regExp, '<mark class="highlight">$&</mark>')

      const parent = document.querySelector('#proceeding-list')
      element.style.display = "block"

      // the below alerts screen reader users that results appeared on the page
      ariaText = codes.length + ' ' + pluralize(codes.length, 'match', 'matches') + ' found for ' + inputText + ', use tab to move through options';
      })
    }
  else {
    $(".no-proceeding-items").show()
    ariaText = 'No results found matching ' + inputText
  }
}

function doneTyping () {
  $('#screen-reader-messages').html(ariaText)
}

const pluralize = (val, word, plural = word + 's') => {
  const _pluralize = (num, word, plural = word + 's') =>
      [1, -1].includes(Number(num)) ? word : plural;
  if (typeof val === 'object') return (num, word) => _pluralize(num, word, val[word]);
  return _pluralize(val, word, plural);
};

let submitForm = proceedingItem => {
  $(proceedingItem).find('form').submit()
  return false
}

$(document).ready(function() {
  searchOnUserInput()
})
// export { getAll, filterSearch }
