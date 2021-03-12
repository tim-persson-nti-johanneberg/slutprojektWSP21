require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'byebug'

get ('/') do
    slim(:index)
end

get ('/edit') do
    db = SQLite3::Database.new('db/reviews.db')
    db.results_as_hash = true
    genre = db.execute("SELECT * FROM GENRE")
    slim(:edit, locals:{genre:genre})
end

post("/genre") do
    db = SQLite3::Database.new('db/databas.db')
    db.results_as_hash = true
    genre_name = db.execute("SELECT genre_name, genre_id FROM GENRE")
    slim(:edit, locals:{genre:genre_name})
end

post("/newreview") do
    title = params[:Title]
    genre_chosen = params[:genre_chosen]
    genre_id = genre_chosen.to_i
    db = SQLite3::Database.new("db/reviews.db")
    db.execute("INSERT INTO MOVIES (Title, Genre_id) VALUES(?,?)", title, genre_id)
    redirect('/edit')
end