class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
  has_one :member, dependent: :destroy
  belongs_to :tenant, optional: true
  has_many :tenants, through: :members
  # 2. Tell Rails to accept tenant data during User creation
  accepts_nested_attributes_for :tenant
end
