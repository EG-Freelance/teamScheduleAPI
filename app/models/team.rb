class Team < ActiveRecord::Base
  has_many :games
  
  def get_schedule
    Time.zone = "Eastern Time (US & Canada)"
    agent = Mechanize.new
    sport = self.sport
    team = self.espn_abbv
    
    if self.sport == "nfl"
      season = Date.today.year
      agent.get("http://www.espn.com/nfl/team/schedule/_/name/#{team.downcase}/")
      content = Nokogiri::HTML(agent.page.content)
      games = content.css('tr')
      games_array = games.map{ |g| [g.text, g.css('a').first.nil? ? nil : g.css('a').first.attributes['href'].value] }
      games_array.delete_if{ |g| g[0][0..4] == " Date" }
      while games_array[0][0].match(/Regular/).nil? do
        games_array.delete_at(0)
      end
      games_array.each do |g| 
        next if g[0].match(/\A(\d{1,2})/).nil?
        # un-0-padded week number
        week_u = g[0].match(/\A(\d{1,2})/)[1]
        # add 0-padding
        week_u.length == 1 ? week = "0" + week_u : week = week_u
        date_reg = g[0].match(/\d{1,2}[A-Z][a-z]{2}\,\s([A-Z][a-z]{2}\s\d{1,2})[@?|v]|(BYE WEEK)\z/)
        unless date_reg.nil?
          date = date_reg[1] unless date_reg[1].nil?
          date = date_reg[2] unless date_reg[2].nil?
        end
        time = g[0].match(/\S(\d{1,2}:\d{2}\s\S{2})\s/)
        time = time[1] unless time.nil?
        unless date.nil?
          if date[0..2].match(/Jun|Jul|Aug|Sep|Oct|Nov|Dec/)
            year = season
          elsif date[0..2].match(/Jan|Feb|Mar|Apr|May/)
            year = season + 1
          else
            year = "N/A"
          end
          if year == "N/A"
            game_date = nil
            opp = "BYE WEEK"
            home = nil
          else
            game_date = Time.zone.parse("#{date} #{year} #{time}").to_datetime
            opp_check = g[0].match(/(@|vs)([A-Z]+\.?\s?[A-Z]+)\d/i)
            opp = g[1].match(/name\/([A-Za-z]{1,3})\//)[1] unless opp_check.nil?
            if g[0].match(/\@/).nil?
              home = true
            else
              home = false
            end 
          end
          Game.where(week: week, date: game_date, season: season, home: home, opponent: ( home == false ? "at " : "" ) + opp, team_id: self.id).first_or_create
        end
        # FIX DUPLICATE WEEK GAMES CAUSED BY PRESEASON
        games = Game.where(team_id: self.id, week: week, season: season)
        games.order('date asc').first.update(week: "P" + week_u) if games.count > 1
      end      
    else
      season = Date.today.year
      match = 0
      while match == 0 do
        agent.get("http://espn.go.com/#{sport}/teams/printSchedule/_/team/#{team}/season/#{season}")
        content = Nokogiri::HTML(agent.page.content)
        games = content.css('tr td tr')
        if games.count > 5
          match = 1
        else
          season = season - 1
        end
      end
       (sport == 'nba' || sport == 'nhl') ? team_season = "#{season-1}-#{season.to_s[2..3]}" : team_season = season.to_s
      games_array = games.map{ |g| g.text }
      games_array.delete_if{ |g| g[0..4] == " Date" }
      games_array.each do |g|
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
        Game.where(week: "N/A", date: date, season: team_season, home: home, opponent: opp, team_id: self.id).first_or_create
      end
    end
  end
end
