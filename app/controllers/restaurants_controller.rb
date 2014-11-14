class RestaurantsController < ApplicationController
  def index
    if current_user
      @restaurants = current_user.restaurants
    else
      redirect_to root_path
    end
  end

  def new
    if current_user
      @restaurant = Restaurant.new :name => params[:name], :category => params[:category], :venue_id => params[:id]
      if current_user.restaurants.find_by(venue_id: params[:id])
        redirect_to restaurants_path, alert: 'You already have this restaurant in your list of favorites.'
      end
    else
      redirect_to root_path
    end
  end

  def create
    @restaurant = Restaurant.new(restaurant_params)
    url = "https://api.foursquare.com/v2/venues/#{params[:restaurant][:venue_id]}?client_id=#{ENV['CLIENT_ID']}&client_secret=#{ENV['CLIENT_SECRET']}&v=20140815"
    response = RestClient.get(url)
    parsed_response = JSON.parse(response)
    address_base = parsed_response["response"]["venue"]["location"]["formattedAddress"]
    @restaurant.address = "#{address_base[0]}, #{address_base[1]}"
    if parsed_response["response"]["venue"]["contact"]["formattedPhone"]
      @restaurant.phone_number = parsed_response["response"]["venue"]["contact"]["formattedPhone"]
    end
    if parsed_response["response"]["venue"]["url"]
      @restaurant.url = parsed_response["response"]["venue"]["url"]
    end
    @restaurant.user_id = current_user.id
    @restaurant.save
    redirect_to restaurants_path, notice: 'Restaurant successfully added.'
  end

  def show
    if current_user
      redirect_to restaurants_path
    else
      redirect_to root_path
    end
  end

  def edit
    if current_user
      @restaurant = Restaurant.find(params[:id])
      if @restaurant.user_id != current_user.id
        redirect_to restaurants_path, notice: "You cannot edit this restaurant's information because it is not in your list of favorites."
      end
    else
      redirect_to root_path
    end
  end

  def update
    @restaurant = Restaurant.find(params[:id])
    if @restaurant.update(update_params)
      redirect_to restaurants_path, notice: 'Restaurant info successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @restaurant = Restaurant.find(params[:id])
    @restaurant.destroy
    redirect_to restaurants_path, notice: 'Restaurant successfully removed from your list.'
  end

private

  def restaurant_params
    params.require(:restaurant).permit(:name, :category, :venue_id)
  end
  def update_params
    params.require(:restaurant).permit(:name, :category, :venue_id, :address, :phone_number, :url)
  end
end
