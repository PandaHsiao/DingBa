class ConfirmationsController < Devise::ConfirmationsController

  def resend_confirm_email
    self.resource = resource_class.new
    render :layout => false
  end

  def create
    self.resource = resource_class.send_confirmation_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      #respond_with({}, :location => after_resending_confirmation_instructions_path_for(resource_name))

      @user_email = resource.email
      flash.now[:alert] = '已成功發出註冊驗證信'
      render 'home/wait_confirm_email', layout: 'home_index'
      return
    else
      user = self.resource
      if user.id.blank?
        flash.now[:alert] = '沒有此 E-Mail'
        render 'devise/sessions/booker_new'
        return
      else
        if user.confirmation_token.length == 20
          flash.now[:alert] = '您的帳戶已經可以使用，請直接登入'
          render 'devise/sessions/booker_new'
          return
        end
        redirect_to booker_manage_index_path
      end
    end
  end

  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      set_flash_message(:notice, :confirmed) if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with_navigational(resource){
        if resource.role == '0'
          redirect_to confirmation_getting_started_path      # TODO user and restaurant
        else
          redirect_to booker_manage_index_path
        end
      }
    else
      # sessions destroy
      # comfirm again error

      if !resource.confirmation_token.blank?
        x = User.where(:confirmation_token => resource.confirmation_token).first
        set_flash_message(:notice, :confirmed) if is_navigational_format?
        sign_in(resource_name, x)
        respond_with_navigational(x){
          if x.role == '0'
            redirect_to confirmation_getting_started_path      # TODO user and restaurant
          else
            redirect_to booker_manage_index_path
          end
        }

      else
        redirect_path = after_sign_out_path_for(resource_name)
        signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
        set_flash_message :notice, :signed_out if signed_out && is_flashing_format?
        yield resource if block_given?

        respond_to do |format|
          format.all { head :no_content }
          format.any(*navigational_formats) { redirect_to redirect_path }
        end
      end


      #respond_with_navigational(resource.errors, :status => :unprocessable_entity){ render_with_scope :new } # TODO render_with_scope ,error handle
    end
  end

end