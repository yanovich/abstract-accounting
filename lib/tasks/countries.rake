require "sqlite3"

namespace :countries do
  task fill: :environment do
    db = SQLite3::Database.new "#{Rails.root}/db/predefined/countries.sqlite"
    Country.delete_all
    db.execute("select rus_title, rus_fulltitle from iso_countries") do |country|
      Country.create!(:tag => (country[1].empty? ? country[0] : country[1]))
      puts "Added #{Country.count}" if Country.count % 50 == 0
    end
  end
end