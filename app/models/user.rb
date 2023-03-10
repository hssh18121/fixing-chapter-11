class User < ApplicationRecord
    before_save { self.email = email.downcase }
    validates :name, presence: true, length: { maximum: Settings.max_user_name_length }                
    validates :email, presence: true, length: { maximum: Settings.max_user_email_length }, format: { with: Settings.valid_email_regex }, uniqueness: { case_sensitive: false }
    
    has_secure_password
    validates :password, presence: true, length: { minimum: Settings.min_user_password_length}
end
