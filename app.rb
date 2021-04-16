require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'byebug'


#TODO
#Gör inlogg och så att man äger sina reviews
#Kolla så sträng interpoleringen i SQL inte är olaglig


def gettitle(id)
    db = SQLite3::Database.new('db/reviews.db')
    db.results_as_hash = true
    title = db.execute("SELECT TITLE FROM MOVIES WHERE Movie_Id ='#{id}'")
    return title
end

#post('category') do
#   category = params[:genre_chosen]
#end

get ('/') do #TODO Fixa kategorier
    db = SQLite3::Database.new('db/reviews.db')
    db.results_as_hash = true
    entries = db.execute("SELECT * FROM REVIEWS")
    genre = db.execute("SELECT * FROM GENRE")
    slim(:index, locals:{entries:entries, genre:genre})
end

get ('/edit') do
    db = SQLite3::Database.new('db/reviews.db')
    db.results_as_hash = true
    genre = db.execute("SELECT * FROM GENRE")
    slim(:edit, locals:{genre:genre})
end

post("/genre") do
    db = SQLite3::Database.new('db/reviews.db')
    db.results_as_hash = true
    genre_name = db.execute("SELECT genre_name, genre_id FROM GENRE")
    slim(:edit, locals:{genre:genre_name})
end

post("/newreview") do
    #TODO
    #Se till att alla fält är ifyllda
    #Publicera inte en film om filmen redan finns
    i = 0
    title = params[:Title]
    genre_chosen = params[:genre_chosen]
    content = params[:CONTENT]
    rating = params[:rating]
    genre_id = genre_chosen.to_i
    db = SQLite3::Database.new("db/reviews.db")
    titles_existing = db.execute("SELECT Title FROM MOVIES")
    
    titlesbool = titles_existing[0].include? title

    if (titles_existing[0].include? title) == false
        db.execute("INSERT INTO MOVIES (Title, Genre_id) VALUES(?,?)", title, genre_id) 
    end

    movie_id = db.execute("SELECT Movie_id FROM MOVIES WHERE Title = '#{title}'") #Är detta felaktig interpolering?
    #
    db.execute("INSERT INTO REVIEWS (review_text, movie_id, rating, genre_id) VALUES(?,?,?,?)", content, movie_id[0], rating, genre_id)
    #Väljer index 0 för att movie_id blir en array pga att titlar inte blir unika
    
    redirect('/edit')
end

get("/category/?") do
    db = SQLite3::Database.new('db/reviews.db')
    db.results_as_hash = true   
    entries = db.execute("SELECT * FROM REVIEWS WHERE genre_id =#{params['genre_chosen']}")
    genre = db.execute("SELECT * FROM GENRE")
    slim(:index, locals:{entries:entries, genre:genre})
end