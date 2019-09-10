$(document).ready(function() {
  if ($('table.sortable')) {
    let table;
    const endText = {
      //em tags are here to add emphasis to screen reader voice, rather than add italics
      asc: {
        date: 'from <em>oldest</em> to <em>newest</em>',
        numeric: 'from <em>smallest</em> to <em>largest</em>',
        alphabetic: 'from <em>A.</em> to <em>Zed</em>',
        undefined: 'in <em>ascending</em> order' //for when the data-sort-type is not set
      },
      desc: {
        date: 'from <em>newest</em> to <em>oldest</em>',
        numeric: 'from <em>largest</em> to <em>smallest</em>',
        alphabetic: 'from <em>Zed</em> to <em>A</em>',
        undefined: 'in <em>descending</em> order' //for when the data-sort-type is not set
      }
    }

    $('th.sort')
      .addClass("js-sortable")  //this class used to style as links, if JS not enabled, titles won't look clickable.
      .attr('tabindex', 0)
      .wrapInner('<span class="sortable-column" title="sort this column"/>')
      .each(function(index) {
        const th = $(this),
          thIndex = $(this).index('th');
        let inverse = false;

        th.click(() => {
          table = th.parents('table');
          th.parent().children().removeClass('header-sort-asc header-sort-desc')
          let sortDirection = inverse ? 'desc' : 'asc';
          th.addClass('header-sort-' + sortDirection);
          table.find('td').filter(function() {
            return $(this).index() === thIndex;
          }).sortElements((a, b) => (
            $(a).sortableValue() > $(b).sortableValue() ?
              inverse ? -1 : 1 :
              inverse ? 1 : -1
          ), function() {
            // parentNode is the element we want to move
            return this.parentNode;
          });

          //this adds a message to the message div, stating what it is sorted by
          $("#screen-reader-messages").html("Sorted by " + th.find(".aria-sort-description").text() + " " + endText[sortDirection][th.attr("data-sort-type")]);
          $(".screen-reader-sort-indicator").html("");
          th.find(".screen-reader-sort-indicator").html(" (currently sorted " + endText[sortDirection][th.attr("data-sort-type")] + ").");

          inverse = !inverse;

          if (typeof pageChange == 'function') { 
            //if the page change function exists, it is involked to return to the first page
            pageChange(0); 
          }

          return false;
        });
        th.keypress(function(ev) {
          const spaceBarCode = 32;
          const returnKeyCode = 13;
          if (ev.which==returnKeyCode || ev.which==spaceBarCode)  { //on space or return, the column is sorted
            $(this).click();
            return false;
          }
        });
      });

    jQuery.fn.sortableValue = function() {
      let value = $(this).data('sort-value');
      if (value === undefined) value = $(this).text().trim();

      if ($(this).data('sort-type') === 'number')
        value = +value;

      return value;
    };

    jQuery.fn.sortElements = (function() {
      const sort = [].sort;
      return function(comparator, getSortable) {
        getSortable = getSortable || function() {
          return this;
        };

        const placements = this.map(function() {
          const sortElement = getSortable.call(this),
            parentNode = sortElement.parentNode,

          // Since the element itself will change position, we have
          // to have some way of storing it's original position in
          // the DOM. The easiest way is to have a 'flag' node:
          nextSibling = parentNode.insertBefore(
            document.createTextNode(''),
            sortElement.nextSibling
          );

          return function() {
            if (parentNode === this)
              throw new Error("You can't sort elements if any one is a descendant of another.");

            // Insert before flag:
            parentNode.insertBefore(this, nextSibling);
            // Remove flag:
            parentNode.removeChild(nextSibling);
          };
        });
        
        return sort.call(this, comparator).each(function(i) {
          placements[i].call(getSortable.call(this));
        });
      };
      
    })();
  }
  
  /*multi page stuff*/
  //if pagination-table exists, then we add the functions and set to page 1 on document ready
  if ($("#pagination-table").length) {
    var rowQty = document.querySelectorAll("#pagination-table tbody tr").length; //total number of rows

    //we only do this if there are more than 5 rows
    if (rowQty > 5) {

      //function for going backwards and forwards
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

      //function for changing the visible records (page change)
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
          rows[i].style.display = "none"; //hide all rows - will only shew the ones we want to
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

        //change the text of the sentence telling the user how many are shewing out of how many total
        $(".page-info").html("Showing " + firstRow + "&ndash;" + lastRow + " of " + rows.length);
        
        if (rowNumber <= 0) {
          rowNumber = 0; //if less than one, set to 0
          $(".moj-pagination__item--prev>a").css("display","none"); //disable prev link on first page
        }
        if (parseInt(rowNumber,10) + parseInt(numberOfVisibleRows,10) >= maxRow) {
          $(".moj-pagination__item--next>a").css("display","none"); //disable if on last page
        }
      }

      var rowNumber = 0; //set current row to 0
      pageChange(0); //initially set to page 1 (row 0)

      //this is the next and previous controls
      pageNavControls = '<nav class="moj-pagination" id="table-page-nav"><p class="govuk-visually-hidden" aria-labelledby="pagination-label">Pagination navigation</p><ul class="moj-pagination__list"><li class="moj-pagination__item  moj-pagination__item--prev"><a class="moj-pagination__link" href="#">Previous<span class="govuk-visually-hidden"> set of pages</span></a></li><li class="moj-pagination__item  moj-pagination__item--next"><a class="moj-pagination__link" href="#">Next<span class="govuk-visually-hidden"> set of pages</span></a></li></ul></nav>';
      if (!$("#table-page-nav").length) {
        if ($(".pagination-container").length) {
          $(pageNavControls).insertAfter(".pagination-container");
        } else {
          $(pageNavControls).insertAfter("#pagination-table");
        }
      }
      
      //this is the qty per page control, we only show numbers below the total count
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
        $(numberPerPage).insertAfter("#table-page-nav"); //this inserts the qty per page control
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
        if ($(this).val() == rowQty) rowNumber = 0; //this moves to the first page if All are selected (otherwise it'll start at the current row 1)
        pageChange(rowNumber);
      });
    }
  }

});
