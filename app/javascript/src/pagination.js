function navigateRowPages(rowNumber,direction) {
  
  var numberOfVisibleRows = $("#table-nav-qty select").val(); //get the selected number of visible rows
  //rowNumber is current row
  var newFirstRow;
  var maxRow = document.querySelectorAll("#pagination-table tbody tr").length;
  if (direction == "forward") {
    newFirstRow = parseInt(rowNumber,10) + parseInt(numberOfVisibleRows,10);
  }
  if (direction == "backwards") {
    newFirstRow = rowNumber - numberOfVisibleRows;
  }
  if (direction == "first") {
    newFirstRow = 0;
  }
  if (direction == "last") {
    newFirstRow = maxRow - numberOfVisibleRows;
  }
  if (newFirstRow <= 0) newFirstRow = 0; //if less than one, set to 0
  if (newFirstRow > maxRow) newFirstRow = maxRow - numberOfVisibleRows; //if less than one, set to 0
  pageChange(newFirstRow)
  return newFirstRow;
}

function pageChange(rowNumber) {
  //enable any disabled buttons
  $(".moj-pagination__item--prev>a").css("display","inline");
  $(".moj-pagination__item--next>a").css("display","inline");
  
  if (!rowNumber) rowNumber=0; //resets to first page if unknown
  var numberOfVisibleRows = parseInt($("#table-nav-qty select").val(), 10); 
  var rows = document.querySelectorAll("#pagination-table tbody tr");
  var maxRow = rows.length;
  for(i=0;i<rows.length;i++) {
    rows[i].setAttribute("id", "table-row-"+i);
    rows[i].style.display = "none";
  }
  for(i=rowNumber;i<(parseInt(rowNumber,10)+numberOfVisibleRows);i++) {
    i = parseInt(i,10);
    console.log(i);
    rowId = "#table-row-"+i;
    $(rowId).css("display","table-row");
  }
  var firstRow = i-numberOfVisibleRows + 1;
  if (firstRow < 0) firstRow = 0;
  var lastRow = i;
  if (lastRow > rows.length) lastRow = rows.length;
  
  $(".page-info").html("Showing " + firstRow + "&ndash;" + lastRow + " of " + rows.length);
  
  if (rowNumber <= 0) {
    rowNumber = 0; //if less than one, set to 0
    $(".moj-pagination__item--prev>a").css("display","none"); //disable prev link on first page
  }
  if (parseInt(rowNumber,10) + parseInt(numberOfVisibleRows,10) >= maxRow) {
    $(".moj-pagination__item--next>a").css("display","none"); //disable if on last page
  }
  
}

$(document).ready(function() {
  if ($("#pagination-table").length) {
    var rowQty = document.querySelectorAll("#pagination-table tbody tr").length
    if (rowQty > 5) {
      var rowNumber = 0;
      $(".moj-pagination__item--prev>a").css("display","none"); //start on page 1, so hide previous link
        
      pageNavControls = '<nav class="moj-pagination" id="table-page-nav"><p class="govuk-visually-hidden" aria-labelledby="pagination-label">Pagination navigation</p><ul class="moj-pagination__list"><li class="moj-pagination__item  moj-pagination__item--prev"><a class="moj-pagination__link" href="#">Previous<span class="govuk-visually-hidden"> set of pages</span></a></li><li class="moj-pagination__item  moj-pagination__item--next"><a class="moj-pagination__link" href="#">Next<span class="govuk-visually-hidden"> set of pages</span></a></li></ul></nav>';
      if (!$("#table-page-nav").length) {
        if ($(".pagination-container").length) {
          $(pageNavControls).insertAfter(".pagination-container");
        } else {
          $(pageNavControls).insertAfter("#pagination-table");
        }
      }
      numberPerPage = '<div class="govuk-form-group" id="table-nav-qty"><label class="govuk-label" for="sort">Results per page</label><select class="govuk-select" id="sort" name="sort"><option value="5">5</option>';
      if (rowQty > 10) numberPerPage += '<option value="10" selected="">10</option>';
      if (rowQty > 25) numberPerPage += '<option value="25">25</option>';
      if (rowQty > 50) numberPerPage += '<option value="50">50</option>';
      if (rowQty > 75) numberPerPage += '<option value="75">75</option>';
      if (rowQty > 100) numberPerPage += '<option value="100">100</option>';
      if (rowQty > 150) numberPerPage += '<option value="150">150</option>';
      if (rowQty > 200) numberPerPage += '<option value="200">200</option>';
      numberPerPage += '<option value="' + rowQty + '">All</option></select></div>';
      if (!$("#table-nav-qty").length) {
        $(numberPerPage).insertAfter("#table-page-nav");
      }
      pageChange(rowNumber); //run initial page function to get first page
      


      $(".moj-pagination__item--prev>a").click(function(){
        rowNumber = navigateRowPages(rowNumber,"backwards")
        return false;
      });
      $(".moj-pagination__item--next>a").click(function(){
        rowNumber = navigateRowPages(rowNumber,"forward")
        return false;
      });
      $("#table-nav-qty select").change(function(){
        pageChange(rowNumber);
      });
    }
  }

});