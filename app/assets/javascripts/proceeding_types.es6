if ($("#proceeding-search-input").length){

  var submitForm = proceedingItem => {
    $(proceedingItem).find('form').submit();
  }

  $.getJSON("/v1/proceeding_types", function (proceedings_data) {

    $("#proceeding-list .proceeding-item").hide();
    $(".no-proceeding-items").hide();

    // For docs see: https://github.com/bvaughn/js-search
    const search = new JsSearch.Search("code");
    search.addIndex("meaning");
    search.addIndex("description");
    search.addIndex("category_law");
    search.addIndex("matter");
    search.addDocuments(proceedings_data);

    $("#proceeding-search-input").keyup(function(){
      $("#proceeding-list .proceeding-item").hide();
      $(".no-proceeding-items").hide();

      // Get user input and filter on it.
      const inputText = $(this).val();

      if (inputText.length > 2) {
        const codes = search.search(inputText).map(function(obj) {return obj["code"];});

        if (codes.length > 0) {
          // Iterate through each code, find the matching element, move it to the
          // top and display it
          $.each(codes.reverse(), function(_i, code){
            const element = $('#' + code);

            // We want to highlight anything text in <h3> or <span> tags that
            // matches the user's search criteria
            const span = element.find("span")
            const h3 = element.find("h3")

            // Remove any existing highlighting
            h3.html(h3.html().replace(/<mark class="highlight">(.*)<\/mark>/, '$1'));
            span.html(span.html().replace(/<mark class="highlight">(.*)<\/mark>/, '$1'));

            // Highlight any text that matches the user's input
            const regExp = RegExp(inputText, 'gi');
            h3.html(h3.html().replace(regExp, '<mark class="highlight">$&</mark>'));
            span.html(span.html().replace(regExp, '<mark class="highlight">$&</mark>'));

            const parent = $('#proceeding-list');
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

    $('.proceeding-item').on('mouseover', function(e){
      $(this).addClass('hover');
    });

    $('.proceeding-item').on('mouseout', function(e){
      $(this).removeClass('hover');
    });

    $('.proceeding-item').on('click', function(e){
      submitForm(this);
    });

    $('.proceeding-item').on('keydown', function(e){
      if (e.which == 13) {
        submitForm(this);
      }
    });
  });
}
