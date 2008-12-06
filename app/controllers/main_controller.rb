class MainController < ApplicationController
  before_filter :require_user, :except => [:index]
    
  def index
  end
end