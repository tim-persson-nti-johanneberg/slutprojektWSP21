require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

get ('/') do
    slim(:index)
end
get ('/edit') do
    slim(:edit)
end

get ('/admin') do
    db = SQLite3::Database.new('db/reviews.db')
    db.results_as_hash = true
    genre = db.execute("SELECT * FROM GENRE")
    slim(:admin, locals:{genre:genre})
end

post("/genre") do
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true
    genre_name = db.execute("SELECT genre_name FROM GENRE")
    genre_id = db.execute("SELECT genre_id FROM GENRE")
    slim(:admin, locals:{genre:genre_name, genre_id:genre_id})
end