class Chat < ApplicationRecord
  belongs_to :group, optional: true
end
