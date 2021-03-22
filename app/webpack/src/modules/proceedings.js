import axios from 'axios';
import { hide, show, pluralize } from '../helpers';

const doneTypingInterval = 500; // time in ms, 500ms to make search work fairly quickly but avoid too many DB requests
let typingTimer,
  ariaText,
  proceedingMatches = [],
  noMatchCount = 0,
  previousSearchTerm = null,
  containSimilarWords = false;


async function searchResults (searchTerm) {
  const currentUrl = window.location.href;
  const url = `/v1/proceeding_types?search_term=${searchTerm}&sourceUrl=${currentUrl}`;
  const response = await axios.get(url);
  const data = response.data;
  return updateMatchCounters(data, searchTerm);
}

function setMatchAndCount (data = [], searchTerm = null) {
  noMatchCount = 0;
  proceedingMatches = data;
  previousSearchTerm = searchTerm;
}

function substrInArrayOfWords (wordArray1, wordArray2) {
  const matches1 = wordArray1.map(substr => !!wordArray2.find(w => w.includes(substr)));
  const matches2 = wordArray2.map(substr => !!wordArray1.find(w => w.includes(substr)));
  return matches1.includes(true) || matches2.includes(true);
}

function checkSimilarWords (searchTerm) {
  if (searchTerm && previousSearchTerm) {
    const inputLower = searchTerm.toLowerCase().split(/\s+/);
    const previousLower = previousSearchTerm.toLowerCase().split(/\s+/);
    containSimilarWords = substrInArrayOfWords(inputLower, previousLower);
  }
}

function updateMatchCounters (data, searchTerm) {
  checkSimilarWords(searchTerm);

  if (data && data.length) {
    setMatchAndCount(data, searchTerm);
  } else if (!data || !containSimilarWords) {
    setMatchAndCount();
  } else if (proceedingMatches.length) {
    noMatchCount++;
    if (noMatchCount > 3) setMatchAndCount();
  }

  return proceedingMatches;
}

// Calls search only when the typing timer expires
async function doneTyping () {
  document.querySelector('#screen-reader-messages').innerHTML = ariaText;
  const inputText = document.querySelector('#proceeding-search-input').value.trim();

  if (inputText.length > 2) {
    hideProceeedingsItems();
    const results = await searchResults(inputText);
    showResults(results, inputText);
  } else {
    updateMatchCounters();
    hideProceeedingsItems();
  }
}

// Add event listeners for the user typing in the search box and clearing the search
function searchOnUserInput (searchInputBox) {
  searchInputBox.addEventListener('keyup', (event) => {
    clearTimeout(typingTimer);
    typingTimer = setTimeout(doneTyping, doneTypingInterval);
  });

  searchInputBox.addEventListener('keydown', () => clearTimeout(typingTimer));

  document
    .querySelector('#clear-proceeding-search')
    .addEventListener('click', () => {
      searchInputBox.value = '';
      hideProceeedingsItems();
    });

  // TODO: remove this when the multiple proceedings feature flag is removed
  const proceedingItems = document.querySelectorAll('.proceeding-item');

  if (proceedingItems.length) {
    proceedingItems.forEach((item) => {
      item.addEventListener('mouseover', () => item.classList.add('hover'));
      item.addEventListener('mouseout', () => item.classList.remove('hover'));
      item.addEventListener('click', () => submitForm(item));
      item.addEventListener('keydown', event => {
        if (event.which === 13) {
          return submitForm(item);
        }
      });
    });
  }
}

// Find the existing hidden proceeding type items
// If they are one of the search matches returned from the V1 api, remove the hidden class
// and highlight the search terms in the item text
function showResults (results, inputText) {
  if (results.length > 0) {
    const codes = results.map(obj => obj.code);
    codes.forEach(code => {
      // const element = $('#' + code)
      const element = document.getElementById(code);

      // We want to highlight anything text in <main> or <span> tags that
      // matches the user's search criteria
      const span = element.querySelector('span');
      // TODO: remove h3 when the multiple proceedings feature flag is removed
      const main = element.querySelectorAll('h3, label')[0];

      // Remove any existing highlighting
      main.innerHTML = main.innerHTML.replace(/<mark class="highlight">/gi, '');
      main.innerHTML = main.innerHTML.replace(/<\/mark>/gi, '');
      span.innerHTML = span.innerHTML.replace(/<mark class="highlight">/gi, '');
      span.innerHTML = span.innerHTML.replace(/<\/mark>/gi, '');

      // Highlight any text that matches the user's input
      let terms = inputText.split(' ')
      terms.forEach(term => {
        if (term.length > 2) {
          const regExp = RegExp(term.trim(), 'gi');
          main.innerHTML = main.innerHTML.replace(regExp, '<mark class="highlight">$&</mark>');
          span.innerHTML = span.innerHTML.replace(regExp, '<mark class="highlight">$&</mark>');
        }
      })
      // show hidden proceedings item
      show(element);
      hide(document.querySelector('.no-proceeding-items'));
      // the below alerts screen reader users that results appeared on the page
      const pluralizedMatches = pluralize(codes.length, 'match', 'matches');
      ariaText = `${codes.length} ${pluralizedMatches} found for ${inputText}, use tab to move through options`;
    })
  } else {
    show(document.querySelector('.no-proceeding-items'));
    ariaText = `No results found matching ${inputText}`;
  }
}

// Hide any search results and the 'no results found' text
function hideProceeedingsItems () {
  document
    .querySelectorAll('.proceeding-item')
    .forEach(item => hide(item));

  hide(document.querySelector('.no-proceeding-items'));
}

// TODO: remove this when the multiple proceedings feature flag is removed
const submitForm = proceedingItem => {
  const form = proceedingItem.querySelector('form');
  if (form) form.submit();
  return false;
}

// If the proceedings type search box appears on the page, call the searchOnUserInput function
document.addEventListener('DOMContentLoaded', event => {
  const searchInputBox = document.querySelector('#proceeding-search-input');
  if (searchInputBox) searchOnUserInput(searchInputBox);
})

export { searchResults, searchOnUserInput, showResults }
