require './cfb.rb'
require 'faraday'


class WrUsage
  attr_reader :year, :team, :exclude_garbage_time

  def initialize(year: 2019, team: 'Ohio State', exclude_garbage_time: false)
    @year = year
    @team = team
    @exclude_garbage_time = exclude_garbage_time
  end

  def perform
    puts "Grabbing usage rates for #{year} #{team}"

    games = Cfb.api.get_games(year, options)
    puts "Found #{games.length} games"

    usages_by_player = {}


    games.each do |game|
      week = game.week
      puts "Week #{week}"

      box_scores = Faraday.get "https://api.collegefootballdata.com/game/box/advanced?gameId=#{game.id}&exclude_garbage_time=true"
      JSON.parse(box_scores.body)['players']['usage'].select{|h| h['team'] == team}.each do |h|
        if usages_by_player[h['player']]
          usages_by_player[h['player']] << {:data => h, :week => week}
        else
          usages_by_player[h['player']] = [{:data => h, :week => week}]
        end
      end
    end

    weighted_usages = []

    usages_by_player.each do |k, v|
      sum = v.map{|x| x[:week] * x[:data]['passing']}.sum
      weighted_usages << {:weighted_sum => sum, :player => k, :pos => v.first[:data]['position']}
    end

    puts weighted_usages.sort_by{|h| h[:weighted_sum]}
  end

  private

  def options
    {
      :team => team,
      :exclude_garbage_time => exclude_garbage_time
    }
  end
end

WrUsage.new.perform