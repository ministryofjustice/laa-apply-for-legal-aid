# Allows one layout to be nested within another
# See: https://mattbrictson.com/easier-nested-layouts-in-rails
# @parent_layouts_used added to catch infinite loop that develops if you set parent_layout
#   to current layout.
module LayoutsHelper
  def parent_layout(layout)
    raise "Possible loop detected - Parent layout '#{layout}' already used" if @parent_layouts_used&.include?(layout.to_sym)

    @parent_layouts_used ||= []
    @parent_layouts_used << layout.to_sym

    @view_flow.set(:layout, output_buffer)
    output = render(template: "layouts/#{layout}")
    self.output_buffer = ActionView::OutputBuffer.new(output)
  end
end
