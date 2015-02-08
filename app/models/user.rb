# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email           :string
#  password_digest :string
#  auth_token      :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'securerandom'

class User < ActiveRecord::Base
  has_secure_password

  def clear_auth_token!
    self.auth_token = nil
    self.save!
  end

  def set_auth_token!
    self.auth_token = generate_auth_token
    self.save!
  end

  private

  def generate_auth_token
    SecureRandom.uuid.gsub(/\-/,'')
  end
end
