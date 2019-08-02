import $ from 'jquery'
import * as JsSearch from 'js-search';
jest.mock('js-search', () => { })

global.$ = global.jQuery = $;
const proceedingTypes = require('proceeding_types');

beforeEach(() => {
  jest.resetAllMocks()
})

describe('calls API to get a list of proceeding types', () => {

  beforeEach(() => {
    $.getJSON = jest.fn()
    search.mockImplementation(() => {
      return {
        Search: mMock
      }
    })
    proceedingTypes()
  })

  it('calls getJSON', () => {
    expect($.getJSON).toHaveBeenCalled();
  })

  it('polls the correct endpoint', () => {
    let endpoint = "/v1/proceeding_types"
    expect($.getJSON).toHaveBeenCalledWith(endpoint, expect.any(Function))
  })

  test("returns list of proceeding types", () => {
    $.getJSON.mockImplementationOnce(() =>
      Promise.resolve(dummy_response_data_here)
    );
    return search.fetchBooks().then(response => {
      expect(response).toEqual();
    });
  });


})
