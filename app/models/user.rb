class User < ActiveRecord::Base
	# Nektere DB adaptery maji indexy case insensitive, coz by vadilo pri validoani unikatnosti
	before_save { email.downcase! }

  	validates :name,  presence: true, length: { maximum: 50 }
  	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  	validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

    # Magie - vytvari virtualni sloupce password a password_confirmation - ty jsou
    # jen v pameti a do DB se neukladaji, pridava take validace na presence a dalsi veci
    has_secure_password

    validates :password, length: { minimum: 6 }
end
