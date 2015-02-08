class User < ActiveRecord::Base
  has_one :watermark
  has_secure_password
  validates_uniqueness_of :email

  after_update :update_watermark

  def name
    "#{first_name} #{last_name}"
  end

  private
  def update_watermark
    if self.image && self.image_changed?
      binding.pry
      lp = LivePaper.auth({id: ENV["LINK_PUBLIC"], secret: ENV["LINK_SECRET"]})
      i = LivePaper::Image.upload(self.image.url)
      if self.watermark
        t = LivePaper::WmTrigger.get(watermark.trigger_id)
        t.watermark[:imageURL] = i
        t.update
      else
        t = LivePaper::WmTrigger.create(name: name, watermark: {strength: 10, imageURL: i})
        p = LivePaper::Payoff.create(name: name, type: LivePaper::Payoff::TYPE[:WEB], url: "http://tomprats.com/users/#{id}")
        l = LivePaper::Link.create(name: name, payoff_id: p.id, trigger_id: t.id)
        Watermark.create(
          user_id: self.id,
          trigger_id: t.id,
          payoff_id: p.id,
          link_id: l.id
        )
      end
    end
  end
end
