$("#search-for-applications").ready(function(){ //only adds code when the search box is loaded on the page
  $("#search-for-applications").on("keyup paste click", function(){ //every time a new letter is entered
    $("tbody tr").css("display","none"); //hides all rows - we re-display applicable rows later
    var searchPhrase = $(this).val().toUpperCase().replace(/[.,\/\s\\#£!$%\^&\*;:{}=\-_`~()]/g,""); //gets the search phrase without any punctuation or spaces
    $("tbody tr").each(function(){ //for each row in the table
      var rowcontent = $(this).text().toUpperCase().replace(/[.,\/\s\\#£!$%\^&\*;:{}=\-_`~()]/g,""); //gets the content phrase without any punctuation or spaces
      if (rowcontent.indexOf(searchPhrase) > -1 ) { //if the search phrase is found
        $(this).css("display","table-row"); //display this row
      }
    });
    $(".page-info").text("Showing " + $("tbody tr:visible").length + " of " + $("tbody tr").length); //this changes the page-info text to say "showing x of y" (x = visible rows, y = total rows)
  });
});
