require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'byebug'


#TODO
#Gör inlogg och så att man äger sina reviews
#Kolla så sträng interpoleringen i SQL inte är olaglig

enable :sessions

get ('/showlogin') do
    slim(:login)
end

post('/login') do
    username = params[:username]
    password = params[:password]
    db = SQLite3::Database.new("db/reviews.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM USER WHERE username = ?", username).first
    pwdigest = result["password"]
    id = result["id"]
  
      if BCrypt::Password.new(pwdigest) == password
        session[:id] = id
        redirect('/')
      else
        "FEL LÖSEN"
      end
  
end

get("/register") do
    slim(:register)
end

post("/users/new") do
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]

  if password == password_confirm
    #lägg användare
    password_digest = BCrypt::Password.create(password)
    db = SQLite3::Database.new("db/reviews.db")
    db.execute("INSERT INTO USER (username,password) VALUES (?,?)",username,password_digest)
    redirect("/")

  else
    #fixa
    "Fungerade inte"
  end
end


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
    id = session[:id].to_i
    entries = db.execute("SELECT * FROM REVIEWS")
    genre = db.execute("SELECT * FROM GENRE")
    username = db.execute("SELECT USERNAME FROM USER WHERE id ='#{id}'")
    slim(:index, locals:{entries:entries, genre:genre, username:username})
end

get('/edit') do
    db = SQLite3::Database.new('db/reviews.db')
    db.results_as_hash = true
    id = session[:id]
    entries = db.execute("SELECT * FROM REVIEWS WHERE owner_id ='#{id}'")
    slim(:edit, locals:{entries:entries})
end

post('/editreview') do
    db = SQLite3::Database.new('db/reviews.db')
    id = params[:number]
    text = params[:text]
    rating = params[:rating]
    if text != ""
        db.execute("UPDATE REVIEWS SET review_text = ? WHERE review_id = ?",text,id)
    end
    db.execute("UPDATE REVIEWS SET rating = ? WHERE review_id = ?",rating,id)
    redirect('/edit')
end

post('/deletereview') do
    id = params[:number]
    db = SQLite3::Database.new('db/reviews.db')
    db.execute("DELETE FROM REVIEWS WHERE review_id = ?", id)
    redirect('/edit')
end

get ('/writereview') do
    db = SQLite3::Database.new('db/reviews.db')
    db.results_as_hash = true
    genre = db.execute("SELECT * FROM GENRE")
    slim(:review, locals:{genre:genre})
end

post("/genre") do
    db = SQLite3::Database.new('db/reviews.db')
    db.results_as_hash = true
    genre_name = db.execute("SELECT genre_name, genre_id FROM GENRE")
    slim(:review, locals:{genre:genre_name})
end

post("/newreview") do
    #TODO
    #Se till att alla fält är ifyllda
    #Publicera inte en film om filmen redan finns
    i = 0
    id = session[:id].to_i
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
    db.execute("INSERT INTO REVIEWS (review_text, movie_id, rating, genre_id, owner_id) VALUES(?,?,?,?,?)", content, movie_id[0], rating, genre_id, id)
    #Väljer index 0 för att movie_id blir en array pga att titlar inte blir unika
    
    redirect('/')
end

post("/kill")do
    session[:id] = nil
    redirect("/")
end

get("/category/?") do
    db = SQLite3::Database.new('db/reviews.db')
    db.results_as_hash = true   
    entries = db.execute("SELECT * FROM REVIEWS WHERE genre_id =#{params['genre_chosen']}")
    genre = db.execute("SELECT * FROM GENRE")
    slim(:index, locals:{entries:entries, genre:genre})
end