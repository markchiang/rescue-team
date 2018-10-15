class Uploader < ApplicationRecord
  def id
    created_at.to_i
  end

  def to_json
    {
      created_at: created_at.iso8601,
      meta: { id: id, timestamp: created_at.to_i }
    }
  end

  def to_limited_json
    { id: id }
  end
end
