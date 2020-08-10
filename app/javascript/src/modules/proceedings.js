import $ from 'jquery'
import axios from 'axios'
import * as JsSearch from 'js-search'

async function getAll(){
  const response = await axios.get('/v1/proceeding_types')
  return response.data
}

function filterSearch(proceedings_data) {
  $("#proceeding-list .proceeding-item").hide()
  $(".no-proceeding-items").hide()

  let searchObject = search(proceedings_data)

  $("#proceeding-search-input").keyup((event) => searchCallback(event, searchObject))

  $('#clear-proceeding-search').on("click", () => $("#proceeding-search-input").val("").trigger("keyup"))

  $('.proceeding-item').on('mouseover', function (e) { $(this).addClass('hover') })
    .on('mouseout', function (e) { $(this).removeClass('hover') })
    .on('click', function (e) { return submitForm(this) })
    .on('keydown', function (e) {
      if (e.which == 13) {
        return submitForm(this)
      }
    })
}

function search(proceedings_data) {
  // For docs see: https://github.com/bvaughn/js-search
  const search = new JsSearch.Search("code")
  search.indexStrategy = new JsSearch.AllSubstringsIndexStrategy()

  search.tokenizer = {
    tokenize(text) {
      return text.replace(/[^a-zA-Z\d]/gi, '').split()
    }
  }

  search.addIndex("meaning")
  search.addIndex("description")
  search.addIndex("category_law")
  search.addIndex("matter")
  search.addIndex("additional_search_terms")
  search.addDocuments(proceedings_data)
  return search
}

function searchCallback(event, search) {
  $("#proceeding-list .proceeding-item").hide()
  $(".no-proceeding-items").hide()

  // Get user input and filter on it.
  const inputText = $(event.target).val()
  filterData(inputText, search)
}

function filterData(inputText, search) {
  if (inputText.length > 2) {
    const codes = search.search(inputText).map(obj => obj["code"])

    if (codes.length > 0) {
      // Iterate through each code, find the matching element, move it to the
      // top and display it
      $.each(codes.reverse(), function (_i, code) {
        const element = $('#' + code)

        // We want to highlight anything text in <h3> or <span> tags that
        // matches the user's search criteria
        const span = element.find("span")
        const h3 = element.find("h3")

        // Remove any existing highlighting
        h3.html(h3.html().replace(/<mark class="highlight">(.*)<\/mark>/, '$1'))
        span.html(span.html().replace(/<mark class="highlight">(.*)<\/mark>/, '$1'))

        // Highlight any text that matches the user's input
        const regExp = RegExp(inputText, 'gi')
        h3.html(h3.html().replace(regExp, '<mark class="highlight">$&</mark>'))
        span.html(span.html().replace(regExp, '<mark class="highlight">$&</mark>'))

        const parent = $('#proceeding-list')
        element.detach().prependTo(parent)
        element.show()

        // the below alerts screen reader users that results appeared on the page
        const accessibilityAlertMessage = document.querySelector("#proceedingTypes").dataset.message
        document.querySelector("#proceedingTypes").innerHTML = accessibilityAlertMessage
      })
    }
    else {
      $(".no-proceeding-items").show()
    }
  }
}

let submitForm = proceedingItem => {
  $(proceedingItem).find('form').submit()
  return false
}

export { getAll, filterSearch }
