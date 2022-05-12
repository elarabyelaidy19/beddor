class Tweet < ApplicationRecord
  belongs_to :twitter_account 
  belongs_to :user 

  validates :body, length: {minimum: 1, maximum: 280 } 
  validates :publish_at, presence: true 

  after_initialize do 
    self.publish_at ||= 24.hour.from_now
  end   

  # callback if commit changed after commit to database   
  after_save_commit do 
    if publish_at_previously_changed? 
      # queue tweet until publish time
      TweetJob.set(wait_until: publish_at).perform_later(self) 
    end 
  end 

  def published? 
    tweet_id? 
  end 

  
  def publish_to_twitter! 
    tweet = twitter_account.client.update(body) 
    update(tweet_id: tweet.id)
  end
  
end
