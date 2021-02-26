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