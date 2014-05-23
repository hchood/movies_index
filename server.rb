require 'sinatra'
require 'csv'
require 'pry'

def read_movies_from(csv)
  movies = []

  CSV.foreach(csv, headers: true, header_converters: :symbol) do |row|
    movies << row.to_hash
  end

  movies.sort_by! { |movie| movie[:title] }
end

def find_movie(movie_id)
  movies = read_movies_from('movies.csv')
  movie = nil

  i = 0
  while movie.nil?
    movie = movies[i] if movies[i][:id] == movie_id
    i += 1
  end

  movie
end

get '/movies' do
  @movies = read_movies_from('movies.csv')
  erb :index
end

get '/movies/:movie_id' do
  @movie = find_movie(params[:movie_id])
  erb :show
end
