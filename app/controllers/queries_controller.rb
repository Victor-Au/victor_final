class QueriesController < ApplicationController
  def index
    redirect_to root_path
  end

  def new
    if current_user
      @query = Query.new
    else
      redirect_to root_path
    end
  end

  def create
    @query = Query.new
    if request.location.data["ip"] == "127.0.0.1"
      current_location = "40.769152,-73.984944"
    else
      geocode_result = request.location
      user_latitude = geocode_result.data["latitude"]
      user_longitude = geocode_result.data["longitude"]
      current_location = "#{user_latitude},#{user_longitude}"
    end
    current_query = params[:query][:name]
    if current_query.include? ' '
      current_query = current_query.sub(' ','%20')
    end
    url = "https://api.foursquare.com/v2/venues/search?client_id=#{ENV['CLIENT_ID']}&client_secret=#{ENV['CLIENT_SECRET']}&v=20140815&m=foursquare&section=food&openNow=1&ll=#{current_location}&query=#{current_query}&radius=1200&limit=20"
    response = RestClient.get(url)
    @parsed_query = JSON.parse(response)
  end

  def show
    redirect_to root_path
  end

end
