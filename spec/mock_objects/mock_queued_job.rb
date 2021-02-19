class MockQueuedJob
  attr_reader :item, :score

  def initialize(klass, at)
    @item = { 'queue' => 'default', 'wrapped' => klass.to_s }
    @score = at.to_i
  end
end
