
const Fuse = require('fuse.js/src');
$.getJSON("/v1/proceeding_types", function (proceedings_data) {

  $("#proceeding-list .proceeding-item").hide();
  $(".no-proceeding-items").hide();

  let searchOptions = {
    id: "code",
    shouldSort: true,
    minMatchCharLength: 4,
    threshold: 0.3,
    keys: [
      "meaning",
      "code"
    ]
  };

  let fuse = new Fuse(proceedings_data, searchOptions);

  $("#proceeding-search-input").keyup(function(){
    $("#proceeding-list .proceeding-item").hide();

    // Get user input and filter on it.
    let inputText = $(this).val();
    let codes = fuse.search(inputText);
    console.log(codes);

    // Iterate through each code, find the matching element, move it to the
    // top and display it
    $.each(codes.reverse(), function(_i, code){
      let element = $('#' + code);
      let parent = element.parent("div");
      element.detach().prependTo(parent);
      element.show();
    });
  });

  $('#clear-proceeding-search').on('click', function() {
    $("#proceeding-search-input").val('').trigger('keyup');
  });
});


