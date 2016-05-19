class Api::V1::SportsController < ApplicationController

  # GET /sports
  # GET /sports.json
  def sport_index
    @teams = Team.where(sport: params[:sport].downcase)

    render json: @teams
  end
  
  def team_by_sport
    @teams = Team.where(sport: params[:sport].downcase, espn_abbv: params[:espn_abbv].upcase)
    
    render json: @teams
  end
end