# == Schema Information
#
# Table name: conversations
#
#  id           :bigint           not null, primary key
#  current_step :integer
#  data         :jsonb
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_conversations_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Conversation < ApplicationRecord
  belongs_to :user

  enum current_step: %w[
    at_lobby
    pending_name
  ]
end
