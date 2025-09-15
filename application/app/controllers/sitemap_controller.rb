class SitemapController < ApplicationController
  def index
    @navigation = ::Configuration.navigation
  end
end