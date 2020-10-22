$(document).ready(function() {
  if ($('table.sortable')) {
    let table;
    const endText = {
      asc: {
        date: 'from Oldest to Newest',
        numeric: 'from Smallest to Largest',
        alphabetic: 'from A. to Zed',
        undefined: 'in ascending order' //for when the data-sort-type is not set
      },
      desc: {
        date: 'from Newest to Oldest',
        numeric: 'from Largest to Smallest',
        alphabetic: 'from Zed to A',
        undefined: 'in descending order' //for when the data-sort-type is not set
      }
    }

    $('th.sort')
      .addClass("js-sortable")  //this class used to style as links, if JS not enabled, titles won't look clickable.
      .attr('tabindex', 0)
      .each(function(index) {
        const th = $(this),
          thIndex = $(this).index('th');
        let inverse = false;

        th.click(() => {
          table = th.parents('table');
          th.parent().children().removeClass('header-sort-asc header-sort-desc');
          th.parent().children().removeAttr('aria-sort');
          let sortDirection = inverse ? 'desc' : 'asc';
          let verboseSortDirection = inverse ? 'descending' : 'ascending';
          th.addClass('header-sort-' + sortDirection);
          th[0].setAttribute('aria-sort', verboseSortDirection);
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
});
