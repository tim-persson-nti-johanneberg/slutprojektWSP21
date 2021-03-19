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
    i = 0
    title = params[:Title]
    genre_chosen = params[:genre_chosen]
    content = params[:CONTENT]
    genre_id = genre_chosen.to_i
    db = SQLite3::Database.new("db/reviews.db")
    titles_existing = db.execute("SELECT Title FROM MOVIES")
    
    titlesbool = titles_existing[0].include? title
    byebug
    if (titles_existing[0].include? title) == false
        titdb.execute("INSERT INTO MOVIES (Title, Genre_id) VALUES(?,?)", title, genre_id) 
    end

    movie_id = db.execute("SELECT Movie_id FROM MOVIES WHERE Title = '#{title}'")
    #
    db.execute("INSERT INTO REVIEWS (review_text, movie_id) VALUES(?,?)", content, movie_id[0])
    #Väljer index 0 för att movie_id blir en array pga att titlar inte blir unika
    
    redirect('/edit')
end