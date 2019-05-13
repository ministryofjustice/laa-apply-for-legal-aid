$(document).ready(function() {
  if ($('table.sortable')) {
    let table;
    $('th.sort')
      .addClass("js-sortable")
        //this class used to style as links, if JS not enabled, titles won't look clickable.
      .attr('tabindex', 0)
      .wrapInner('<span class="sortable-column" title="sort this column"/>')
      .each(function(index) {
        const th = $(this),
          thIndex = index + 1;
        let inverse = false;

        th.click(() => {
          table = th.parents('table');
          th.parent().children().removeClass('header-sort-asc header-sort-desc')
          th.addClass(inverse ? 'header-sort-asc' : 'header-sort-desc')

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
          inverse = !inverse;

          return false;
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
