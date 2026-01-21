class Project < ApplicationRecord
  acts_as_tenant(:tenant)
  validates :title, presence: true, length: { minimum: 3 }
  validates :title, uniqueness: { scope: :tenant_id, message: "already exists in this organization" }
  validate :free_plan_can_only_have_one_project, on: :create
  has_many :artifacts, dependent: :destroy
  scope :visible_by_plan, -> {
    if ActsAsTenant.current_tenant&.plan == 'free'
      order(created_at: :asc).limit(1)
    else
      all
    end
  }
  private
  def free_plan_can_only_have_one_project
    if tenant&.plan == 'free' && tenant.projects.count >= 1
      errors.add(:base, "Free plan is limited to 1 project. Please upgrade to create more.")
    end
  end
end