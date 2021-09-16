module Test
  class GeneratedErrorController < ApplicationController
    def show
      raise 'boom!'
    end
  end
end
