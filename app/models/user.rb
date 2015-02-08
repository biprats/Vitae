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
    if self.image
      LivePaper.auth({id: ENV["LINK_PUBLIC"], secret: ENV["LINK_SECRET"]})
      i = LivePaper::Image.upload(self.image)
      if self.watermark
        t = LivePaper::WmTrigger.get(watermark.trigger_id)
        t.watermark[:imageURL] = i
        t.update
      else
        t = LivePaper::WmTrigger.create(name: name, watermark: {strength: 10, imageURL: i})
        p = LivePaper::Payoff.create(name: name, type: LivePaper::Payoff::TYPE[:WEB], url: "http://vitae.tomprats.com/users/#{id}")
        l = LivePaper::Link.create(name: name, payoff_id: p.id, trigger_id: t.id)
        Watermark.create(
          user_id: self.id,
          trigger_id: t.id,
          payoff_id: p.id,
          link_id: l.id
        )
      end

      watermark = t.download_watermark
      AWS.config(
        access_key_id: ENV["AWS_PUBLIC"],
        secret_access_key: ENV["AWS_SECRET"],
        region: "us-east-1"
      )
      s3 = AWS::S3.new
      s3.buckets["vitae"].objects["users/#{id}/watermark.jpg"].write(file: watermark)

      current_user.update(image: "https://s3.amazonaws.com/vitae/users/#{id}/watermark.jpg")
    end
  rescue
    true
  end
end
