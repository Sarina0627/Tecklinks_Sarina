require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'open-uri'
require 'sinatra/json'
require './models/bookmark.rb'
require 'sinatra/activerecord'

enable :sessions
helpers do

  def current_user
    User.find_by(id:session[:user])
  end

  def get_favorite_bookmark_list
    bookmarks = []
    if Favorite.where(user_id: session[:user]).present?
      user_favorites = Favorite.where(user_id: session[:user])
      user_favorites.each do |f|
        if Bookmark.where(id: f.bookmark_id).present?
          bookmarks.push(Bookmark.find_by(id: f.bookmark_id))
        else
          bookmarks = Bookmark.none
        end
      end
      bookmarks = Bookmark.where(id: bookmarks.map{|bookmark| bookmark.id})
      bookmarks = bookmarks.distinct
    else
      bookmarks = Bookmark.none
    end
    return bookmarks.all
  end

  def get_all_bookmark_list
    bookmarks = Bookmark.all.order(id: "DESC")
    return bookmarks
  end

  def get_all_user_published_bookmark_list
    bookmarks = Bookmark.where(user_id:session[:user]).all.order(id: "DESC")
    return bookmarks
  end

end
#before '/'do
#if current_user.nil?
#redirect '/signin'
#end

get '/timeline' do
  @bookmarks = Bookmark.all.order(id: "DESC")
  if session[:user]
    @user_id = session[:user]
  end
  logger.info session[:user]
  erb :index
end

post '/publish' do
  Bookmark.create({
    url: params[:url],
    title: params[:title],
    tag: params[:tag],
    user_id: session[:user]
  })

  bookmark_last = Bookmark.last
  bookmark_last_body = bookmark_last.tag
  hashtags = bookmark_last_body.scan(/[#＃][\w\p{Han}ぁ-ヶｦ-ﾟー]+/)

  hashtags.uniq.map do |hashtag|
    Tag.find_or_create_by({tag_body: hashtag.delete('#')})
  end

  redirect '/timeline'
end

post '/delete/:id' do
  Bookmark.find(params[:id]).destroy
  redirect '/user'
end

get '/signup'do
  erb :sign_up
end

post '/signup'do
  user=User.create(
    username: params[:username],
    password: params[:password],
    password_confirmation: params[:password_confirmation]
  )
  if user.persisted?
    session[:user]=user.id
  end
  redirect '/'
end

get '/' do
  erb :sign_in
end

post '/signin'do
  user=User.find_by(username:params[:username])
  if user&&user.authenticate(params[:password])
    session[:user]=user.id
  end
  redirect '/timeline'
end

get '/signout'do
  session[:user]=nil
  redirect '/'
end

post '/favorite/:id' do
  if session[:user]
    if Favorite.find_by(bookmark_id: params[:id], user_id: session[:user]).present?
      Favorite.find_by(bookmark_id: params[:id], user_id: session[:user]).destroy
    else
      favorite = Favorite.create(
        bookmark_id: params[:id],
        user_id: session[:user]
      )
    end
  end
  redirect '/'
end

get '/user' do
  @bookmarks = Bookmark.where(user_id:session[:user]).all.order(id: "DESC")
  erb :user
end

get '/bookmark/:id' do
  bookmark_tag = Tag.find(params[:id])
  @bookmarks=Bookmark.where("tag LIKE ?", "%#{bookmark_tag.tag_body}%").all
  erb :index
end

get '/search/:path' do

  path = params[:path]
  case path
  when "timeline"
    @bookmarks = get_all_bookmark_list()
    @placeholder = "何でも検索"
  when "favorites"
    @bookmarks = get_favorite_bookmark_list()
    @placeholder = "お気に入りを検索"
  when "user"
    @bookmarks = get_all_user_published_bookmark_list()
    @placeholder = "投稿一覧を検索"
  else
    @bookmarks = get_all_bookmark_list()
  end

  @bookmarks = @bookmarks.all

  search_texts = params[:search_text].split(/[[:blank:]]+/)
  search_texts.each do |s|
    @bookmarks = @bookmarks.where("tag LIKE :args1 OR title LIKE :args2", args1: "%#{s}%", args2: "%#{s}%").all
  end
  @bookmarks = @bookmarks.all.order(id: "DESC")
  if session[:user]
    @user_id = session[:user]
  end

  erb :index
end

get '/favorites' do
  if session[:user]
    @bookmarks = get_favorite_bookmark_list()
    @user_id = session[:user]
  else
    redirect '/'
  end
  erb :favorites
end