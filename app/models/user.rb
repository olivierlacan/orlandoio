class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  
  validates_uniqueness_of :email, :allow_blank => true

  has_many :authorizations

  extend FriendlyId
  friendly_id :full_name, use: [:slugged, :history, :finders]

  def self.from_omniauth(auth)
    #cases:
    # user already has email and twitter uid in database
    # user already has email in database
    # user has neither email nor witter uid in database


    #auth hash contains email:
    
    #auth hash contains twitter uid:


    # start with find logic

    # if nothing is found:

    #create logic

  # where(auth.slice("provider", "uid")).first || create_from_omniauth(auth)
    binding.pry
    if auth["info"]["provider"] == "twitter" 
      User.authorization.find_by_uid(auth["uid"])
    elsif User.find_by_email(auth["info"]["email"])
    else  #looks like we're going to have to create a user
      user = create_from_omniauth(auth)
      Authorization.new(provider: auth["provider"], uid: auth["uid"], user_id: user.id)
    end
  end

  def self.create_from_omniauth(auth)
    create! do |user|
      # user.provider = auth["provider"]
      # user.uid = auth["uid"]
      user.full_name = auth["info"]["name"]
    end
  end

  def self.new_with_session(params, session)
    if session["devise.user_attributes"]
      new(sessions["devise.user_attributes"], without_protection: true) do |use|
        user.attibutes = params
        user.valid?
      end
    else
      super
    end
  end

  def password_required?
    super && provider.blank?
  end

  def email_required?
    super && provider.blank?
  end

  has_attached_file :avatar, styles: { 
    large: "450x450#",
    medium: "300x300#", 
    thumb: "100x100#",
    mini: "32x32#" 
  }, 
    default_url:"/images/:style/missing.png"
end
