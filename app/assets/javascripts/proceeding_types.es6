$.getJSON("/v1/proceeding_types", function (proceedings_data) {

  $("#proceeding-list .proceeding-item").hide();
  $(".no-proceeding-items").hide();

  // For docs see: https://github.com/bvaughn/js-search
  let search = new JsSearch.Search("code");
  search.addIndex("meaning");
  search.addIndex("description");
  search.addIndex("category_law");
  search.addIndex("matter");
  search.addDocuments(proceedings_data);

  $("#proceeding-search-input").keyup(function(){
    $("#proceeding-list .proceeding-item").hide();
    $(".no-proceeding-items").hide();

    // Get user input and filter on it.
    let inputText = $(this).val();

    if (inputText.length > 2) {
      let codes = search.search(inputText).map(function(obj) {return obj["code"];});

      if (codes.length > 0) {
        // Iterate through each code, find the matching element, move it to the
        // top and display it
        $.each(codes.reverse(), function(_i, code){
          let element = $('#' + code);
          let parent = $('#proceeding-list');
          element.detach().prependTo(parent);
          element.show();
        });
      }
      else {
        $(".no-proceeding-items").show();
      }
    }
  });

  $('#clear-proceeding-search').on("click", function() {
    $("#proceeding-search-input").val("").trigger("keyup");
  });
});
