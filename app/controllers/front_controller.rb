class FrontController < ApplicationController
  layout 'front'
  def front_1
  end

  def front_2
  end

  def front_3
  end

  def mail1
    render layout: false
  end

  def mail2
    render layout: false
  end

  def mail3
    render layout: false
  end
end