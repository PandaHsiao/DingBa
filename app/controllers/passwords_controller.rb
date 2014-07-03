
class PasswordsController < Devise::PasswordsController
  #layout 'home_index'

  def set_new_password
    self.resource = resource_class.new
    render :layout => false
  end

  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      flash.now[:alert] = '重新設定密碼 E-Mail 已經寄出，麻煩前往收信'
      render 'devise/sessions/booker_new'
      return
    else
      user = self.resource
      if user.id.blank?
        flash.now[:alert] = '沒有此 E-Mail'
        render 'devise/sessions/booker_new'
        return
      else
        redirect_to booker_manage_index_path
      end
    end
  end

  def update
    reset_password = resource_params[:password]
    reset_confirm_password = resource_params[:password_confirmation]

    if reset_password != reset_confirm_password
      flash.now[:alert] = '新密碼與確認新密碼不符'

      self.resource = resource_class.new
      resource.reset_password_token = params[:reset_password_token]
      render 'devise/passwords/edit'
      return
    end

    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:notice, flash_message) if is_flashing_format?
      sign_in(resource_name, resource)
      respond_with resource, :location => after_resetting_password_path_for(resource)
    else
      #respond_with resource
      flash.now[:alert] = '您的重新設定密碼連結已經過期，請至登入頁面，點選忘記密碼，方可取得新密碼設定連結'
      #render '/home/index', layout: 'home_index'
      render 'sessions/booker_new', layout: 'registration'
      return
    end
  end
end


