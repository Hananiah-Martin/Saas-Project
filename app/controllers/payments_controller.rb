# app/controllers/payments_controller.rb
class PaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:verify]

  def checkout
    # 1. Amount in paise (e.g., 500.00 INR = 50000 paise)
    amount = 50000 
    
    # 2. Create Razorpay Order
    @order = Razorpay::Order.create(
      amount: amount,
      currency: 'INR',
      receipt: "receipt_#{@current_tenant.id}_#{Time.now.to_i}"
    )
    
    # Store order ID in session or database if needed
    session[:razorpay_order_id] = @order.id
  end

  def verify
    # 3. Signature Verification
    payment_response = {
      razorpay_order_id: params[:razorpay_order_id],
      razorpay_payment_id: params[:razorpay_payment_id],
      razorpay_signature: params[:razorpay_signature]
    }

    begin
      Razorpay::Utility.verify_payment_signature(payment_response)
      
      # SUCCESS: Logic to enable premium features for your tenant
      @current_tenant.update(plan: 'premium')
      
      redirect_to root_path, notice: "Payment successful! You are now a Premium member."
    rescue SecurityError => e
      redirect_to root_path, alert: "Payment verification failed. Please try again."
    end
  end
end