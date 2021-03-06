class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    #@movies = Movie.all
    @all_ratings = Movie.all_ratings
    @ratings_to_show = Movie.all_ratings

    if params[:sort] == 'release_date'
      @release_dateCSS = 'hilite'
      @titleCSS = ''
    elsif params[:sort] == 'title'
      @titleCSS = 'hilite'
      @release_dateCSS = ''
    end
    
    if !params[:ratings].nil?
      session[:ratings] = params[:ratings]
    end
    
    if !params[:sort].nil?
      session[:sort] = params[:sort]
    end
    
    if params[:ratings].nil? && !session[:ratings].nil?
      redirect_to(movies_path(:ratings=>session[:ratings], :sort=>session[:sort]))
    elsif params[:sort].nil? && !session[:sort].nil?
      redirect_to(movies_path(:ratings=>session[:ratings], :sort=>session[:sort]))
    end
    
    if params[:ratings].nil? && !params[:sort].nil?
      session[:sort] = params[:sort]
      @movies = Movie.all.order(session[:sort])
      
    elsif params[:ratings].nil? && params[:sort].nil? 
      @movies = Movie.all

    else
      session[:sort] = params[:sort]
      session[:ratings] = params[:ratings]
      @movies = Movie.with_ratings(session[:ratings].keys).order(session[:sort])
      @ratings_to_show = params[:ratings].keys
    end
    

    
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
