class Team < ActiveRecord::Base
  has_many :schedules, dependent: :destroy
  has_many :games, through: :schedules
  
  def get_schedule
    Time.zone = "Eastern Time (US & Canada)"
    agent = Mechanize.new
    sport = self.sport
    team = self.espn_abbv
    
    if self.sport == "nfl"
      season = Date.today.year
      sched = Schedule.where(team_id: self.id, season: season.to_s).first_or_create
      agent.get("http://espn.go.com/nfl/team/schedule/_/name/#{team}/")
      content = Nokogiri::HTML(agent.page.content)
      games = content.css('tr')
      games_array = games.map{ |g| g.text }
      games_array.delete_if{ |g| g[0..4] == " Date" }
      games_array.each do |g| 
        date = g.match(/\d{1,2}[A-Z][a-z]{2}\,\s([A-Z][a-z]{2}\s\d{1,2})[@?|v]/)
        date = date[1] unless date.nil?
        time = g.match(/\S(\d{1,2}:\d{2}\s\S{2})\s/)
        time = time[1] unless time.nil?
        unless date.nil?
          if date[0..2].match(/Jun|Jul|Aug|Sep|Oct|Nov|Dec/)
            year = season
          elsif date[0..2].match(/Jan|Feb|Mar|Apr|May/)
            year = season + 1
          else
            puts "Error parsing year in #{g}"
            return false
          end
          game_date = Time.zone.parse("#{date} #{year} #{time}").to_datetime
          opp_check = g.match(/(@|vs)([A-Z]+\.?\s?[A-Z]+)\d/i)
          opp = opp_check[2] unless opp_check.nil?
          if g.match(/\@/).nil?
            home = true
          else
            home = false
          end 
          Game.where(date: game_date, schedule_id: sched.id, home: home, opponent: opp).first_or_create
        end
      end      
    else
      season = Date.today.year + 1
      match = 0
      while match == 0 do
        agent.get("http://espn.go.com/#{sport}/teams/printSchedule/_/team/#{team}/season/#{season}")
        content = Nokogiri::HTML(agent.page.content)
        games = content.css('tr td tr')
        if games.count > 5
          match = 1
          sched = Schedule.where(team_id: self.id, season: season.to_s).first_or_create
        else
          season = season - 1
        end
      end
      games_array = games.map{ |g| g.text }
      games_array.delete_if{ |g| g[0..4] == " Date" }
      games_array.each do |g|
        puts g
        if (sport == "nhl") || (sport == "nba")
          if g[0..2].match(/Sep|Oct|Nov|Dec/)
            year = season
          elsif g[0..2].match(/Jan|Feb|Mar|Apr|May|Jun|Jul|Aug/)
            year = season
          else
            puts "Error parsing year in #{g}"
            return false
          end
        else
          year = season
        end
        date = Time.zone.parse((g.match(/([a-z]{3,4}\.?\s\d{1,2})/i)[1] + " #{year} " + g.match(/(\d{1,2}:\d{2}\z)/)[1] + " pm").gsub(".", "")).to_datetime
        opp = g.match(/[\dat\s]?([a-z]+\.?\s?[a-z]*)\n/i)[1]
        if g.match(/\dat\s/).nil?
          home = true
        else
          home = false
        end
        Game.where(date: date, schedule_id: sched.id, home: home, opponent: opp).first_or_create
      end
    end
  end
end
