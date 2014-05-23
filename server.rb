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

def search(movies, query)
  results = []

  movies.each do |movie|
    if includes_query?(movie, query)
      results << movie
    end
  end

  results
end

def includes_query?(movie, query)
  in_title = !movie[:title].nil? && movie[:title].downcase.include?(query.downcase)
  in_synopsis = !movie[:synopsis].nil? && movie[:synopsis].downcase.include?(query.downcase)

  in_title || in_synopsis
end

get '/movies' do
  movies = read_movies_from('movies.csv')

  if !params[:query].nil?
    movies = search(movies, params[:query])
  end

  if params[:page].nil? || params[:page] == "1"
    @movies = movies[0..19]
  else
    @page_no = params[:page]
    starting_index = (@page_no.to_i - 1) * 20
    range = starting_index..starting_index + 19
    @movies = movies[range] || []
  end

  erb :index
end

get '/movies/:movie_id' do
  @movie = find_movie(params[:movie_id])
  erb :show
end
