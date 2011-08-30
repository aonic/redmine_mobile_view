class MobileController < ApplicationController
  unloadable

  before_filter :require_login

  def index
  end
end
