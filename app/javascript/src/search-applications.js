$("#search-for-applications").ready(function(){
  // NEW selector (case insensitive)
  jQuery.expr[':'].Contains = function(a, i, m) {
    return jQuery(a).text().toUpperCase()
        .indexOf(m[3].toUpperCase()) >= 0;
  };

  // OVERWRITES old selecor
  jQuery.expr[':'].contains = function(a, i, m) {
    return jQuery(a).text().toUpperCase()
        .indexOf(m[3].toUpperCase()) >= 0;
  };

  $("#search-for-applications").keyup(function(){
    var searchPhrase = $(this).val();
    $("tbody tr").css("display","none");
    $("tbody tr:contains('"+searchPhrase+"')").css("display","table-row");
    $('td[data-altsearch*="' + searchPhrase + '"]').parents("tr").css("display","none");
  });
});