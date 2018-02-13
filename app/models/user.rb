# frozen_string_literal: true

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

class User < ApplicationRecord
  has_secure_password

  def clear_auth_token!
    self.auth_token = nil
    save!
  end

  def set_auth_token!
    self.auth_token = generate_auth_token
    save!
  end

  private

  def generate_auth_token
    SecureRandom.uuid.delete('-')
  end
end
