# app/controllers/payments_controller.rb
class PaymentsController < ApplicationController
  # Security: Only skip CSRF for the verify POST request from Razorpay
  skip_before_action :verify_authenticity_token, only: [:verify]
  
  # Ensure a tenant is present before allowing checkout
  before_action :authenticate_tenant!

  def checkout
    # 1. Define amount (₹500.00 = 50000 paise)
    amount = 50000 

    begin
      # 2. Create Razorpay Order
      # Note: receipt helps you track the transaction in Razorpay Dashboard
      @order = Razorpay::Order.create(
        amount: amount,
        currency: 'INR',
        receipt: "tenant_#{current_tenant.id}_#{Time.now.to_i}"
      )
      
      # Store the order ID in the session for verification later
      session[:razorpay_order_id] = @order.id
    rescue StandardError => e
      Rails.logger.error "Razorpay Order Creation Failed: #{e.message}"
      redirect_to root_path, alert: "Payment system is temporarily unavailable. Please try again later."
    end
  end

  def verify
    # 3. Prepare response data for signature verification
    payment_response = {
      razorpay_order_id: params[:razorpay_order_id],
      razorpay_payment_id: params[:razorpay_payment_id],
      razorpay_signature: params[:razorpay_signature]
    }

    begin
      # 4. Critical: Verify that the payment actually came from Razorpay
      Razorpay::Utility.verify_payment_signature(payment_response)
      
      # 5. Success Logic: Update the tenant's plan
      # We use update! to raise an error if the database save fails
      if current_tenant.update(plan: 'premium')
        # Clear the session order id
        session.delete(:razorpay_order_id)
        
        redirect_to root_path, notice: "Congratulations! Your account has been upgraded to Premium."
      else
        redirect_to root_path, alert: "Payment verified, but we couldn't update your plan. Please contact support."
      end

    rescue SecurityError => e
      Rails.logger.error "Razorpay Signature Verification Failed: #{e.message}"
      redirect_to checkout_path, alert: "Payment verification failed. Your card was not charged."
    rescue StandardError => e
      Rails.logger.error "Unexpected Payment Error: #{e.message}"
      redirect_to root_path, alert: "An unexpected error occurred during payment."
    end
  end

  private

  # Helper to ensure current_tenant exists (adjust based on your auth gem like Devise)
  def authenticate_tenant!
    unless current_tenant
      redirect_to new_user_session_path, alert: "Please sign in to upgrade."
    end
  end
end