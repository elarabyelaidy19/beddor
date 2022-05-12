class PasswordResetsController < ApplicationController 

    def new 
        
    end 

    def create 
        @user = User.find_by(email: params[:email]) 

        if @user.present?
            PasswordMailer.with(user: @user).reset.deliver_now
        end 
        redirect_to root_path, notice: "password has been reset"
    end 

    def edit 
        @user = User.find_signed!(params[:token], purpose: "reset password" ) 
    rescue ActiveSupport::MessageVerifier::InvalidSignature 
        redirect_to root_path, alert: "token has expired"
    end 


    def update
        @user = User.find_signed!(params[:token], purpose: "reset password" ) 
        if @user.update(password_params) 
            redirect_to sign_in_path, notice: "password has been updated"
        else 
            render :edit
        end
    end 


    private  

    def password_params
        params.require(:user).permit(:password, :password_confirmation)
    end 
end 