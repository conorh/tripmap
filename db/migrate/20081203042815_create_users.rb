class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string    :login,                 :null => false
      t.string    :email
      t.string    :crypted_password,      :null => false
      t.string    :password_salt,         :null => false
      t.string    :persistence_token
      t.string    :single_access_token
      t.string    :perishable_token
      t.integer   :login_count,           :null => false, :default => 0
      t.datetime  :last_request_at
      t.datetime  :last_login_at
      t.string    :last_login_ip
      t.string    :current_login_ip
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
