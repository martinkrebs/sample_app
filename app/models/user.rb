# == Schema Information
# Schema version: 20101013112401
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'digest'

class User < ActiveRecord::Base
  # mk: we dont save password to the db, it is not part of the db so 
  # we Active record does not auto create the attribute accessors for us
  # so we do it manually next. we just work with the password attr here 
  # it is not saved in the db.
  attr_accessor :password
  attr_accessible :name, :email, :password, :password_confirmation
    
  before_save :encrypt_password 

  # Automatically create the virtual attribute 'password_confirmation'.
  validates :password, :presence     => true,
                       :confirmation => true,
                       :length       => { :within => 6..40 }
                        

  validates :name,  :presence => true,
                    :length => { :maximum => 50 }                 
   
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, :presence => true,
                    :format => { :with => email_regex },
                    :uniqueness => { :case_sensitive => false }

  
  # Return true if the user's password matches the submitted password.
  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end  
  
  def self.authenticate(email, submitted_password)
   user = find_by_email(email)
   return nil  if user.nil?
   return user if user.has_password?(submitted_password)
  end           

  private
  def encrypt_password
    self.salt = make_salt if new_record?
    self.encrypted_password = encrypt(password)
  end

  def encrypt(string)
    secure_hash("#{salt}--#{string}")
  end

  def make_salt
    secure_hash("#{Time.now.utc}--#{password}")
  end

  def secure_hash(string)
    Digest::SHA2.hexdigest(string)
  end
  
end
