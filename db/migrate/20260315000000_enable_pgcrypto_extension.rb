# This migration enables the pgcrypto extension for PostgreSQL, which provides functions for generating UUIDs and other cryptographic functions.
# This is necessary for using UUIDs as primary keys in the users table.
class EnablePgcryptoExtension < ActiveRecord::Migration[7.0]
  def change
    enable_extension "pgcrypto"
  end
end
