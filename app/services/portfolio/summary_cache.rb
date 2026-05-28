module Portfolio
  class SummaryCache
    PREFIX = "portfolio/summary_query"

    def self.invalidate_for(user)
      invalidate_for_user_id(user.id)
    end

    def self.invalidate_for_user_id(user_id)
      Rails.cache.delete_matched(%r{\A#{Regexp.escape(PREFIX)}/users/#{user_id}/})
    end

    def self.invalidate_all
      Rails.cache.delete_matched(%r{\A#{Regexp.escape(PREFIX)}/})
    end
  end
end
