// Based on: https://stackoverflow.com/questions/6957949/jquery-make-contains-case-insensitive
$.extend($.expr[":"], {
  "contains-ci": function(elem, i, match, array) {
    return (elem.textContent || elem.innerText || $(elem).text() || "").toLowerCase().indexOf((match[3] || "").toLowerCase()) >= 0;
  }
});

const Fuse = require('fuse.js/src');
$.getJSON("/v1/proceeding_types", function (proceedings_data) {

  $("#proceeding-list .proceeding-item").hide();
  $(".no-proceeding-items").hide();

  let searchOptions = {
    id: "code",
    shouldSort: true,
    threshold: 0.4,
    location: 0,
    distance: 100,
    maxPatternLength: 32,
    minMatchCharLength: 3,
    keys: [
      "meaning"
    ]
  };

  let fuse = new Fuse(proceedings_data, searchOptions);

  $("#proceeding-search-input").keyup(function(){
    $("#proceeding-list .proceeding-item").hide();
    let inputText = $(this).val();
    let codes = fuse.search(inputText);
    console.log(codes);
    $.each(codes, function(_i, code){
      $('#' + code).show();
    });
  });

});

//$(function(){
//  $("#proceeding-list .proceeding-item").hide();
//  $(".no-proceeding-items").hide();
//
//  $("#proceeding-search-input").keyup(function(){
//    let inputText = $(this).val();
//    if(inputText.length > 3){
//      $("#proceeding-list .proceeding-item").hide();
//
//      let foundItems = $("#proceeding-list .proceeding_type_description:contains-ci('" + inputText + "')").parent(".proceeding-item");
//
//      if(foundItems && foundItems.length > 0) {
//        foundItems.show();
//      }
//      else {
//        $(".no-proceeding-items").show();
//      }
//    }
//    else {
//      // If nothing to show
//      $("#proceeding-list .proceeding-item").hide();
//    }
//  });
//
//  $('#clear-proceeding-search').on('click', function(){
//    $("#proceeding-search-input").val('').trigger('keyup');
//  });
//});
