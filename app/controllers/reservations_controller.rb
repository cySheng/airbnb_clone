class ReservationsController < ApplicationController
  before_action :set_reservation, only: [:show, :edit, :update, :destroy]

  def index
    @reservations = Reservation.where(user_id:params[:user_id])
  end

  def create
    @reservation = Reservation.new(reservation_params)
      if @reservation.save
        flash.now[:success] = "You have successfully created a reservation"
        render template: "reservations/show"
      else
        flash.now[:failure] = "There was an error creating your reservation"
        render template: "listings/show"
      end
  end

  def show
  end

  private
  def reservation_params
    params.require(:reservation).permit(:user_id,:listing_id,:guest_pax,:check_in,:check_out)
  end

  def set_reservation
    @reservation = Reservation.find(params[:id])
  end
end