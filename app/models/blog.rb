class Blog < ActiveRecord::Base
  
  acts_as_taggable_on :categories, :tags, :authors
  
  has_many :comments

  named_scope :published, lambda {{:conditions => ["publishing_date < '#{Time.now.to_formatted_s(:db)}' and draft != ?", true],
                                  :order => "publishing_date DESC"}}


  acts_as_indexed :fields => [:title, :permalink, :excerpt, :body],
                  :index_file => [Rails.root.to_s, "tmp", "index"]

  validates_presence_of :excerpt, :body
  validates_uniqueness_of :title, :permalink, :case_sensitive => true

  validates_format_of :permalink, :with => /^(([-_]|[a-z]|\d){1,100})$/, :message => " is invalid, only lowercase alphanumeric character and _-"
  validates_length_of :permalink, :within => 4..99
  validates_length_of :title, :within => 2..95
  
  def before_validation
    self.permalink = title.parameterize if permalink.blank?
  end

  def published?
    # A blog post should be published? if:
    # the publishing date is before now and it is not a draft blog post.
    publishing_date <= Time.now && !draft
  end
  
  def num_comments
    comments.size
  end
  
  def self.grouped_by_date
    all.group_by { |blog| blog.publishing_date.to_date }.sort {|a,b| b[0] <=> a[0]}
  end
  
end
