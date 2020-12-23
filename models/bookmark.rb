ActiveRecord::Base.establish_connection(ENV['DATABASE_URL']||"sqlite3:db/development.db")
class Bookmark < ActiveRecord::Base
  belongs_to :user
end

class User < ActiveRecord::Base
  has_many :bookmarks
  has_many :favorites
  has_secure_password

end

class Favorite < ActiveRecord::Base
  belongs_to :user
end

class Tag < ActiveRecord::Base
  
end