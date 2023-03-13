class ApplicationController < ActionController::Base
    before_action :set_locale
    before_action :logged_in_user, only: [:edit, :update]
    before_action :correct_user, only: [:edit, :update]

    def set_locale
        I18n.locale = params[:locale] || I18n.default_locale
    end

    def default_url_options
        {locale: I18n.locale}
    end

    def logged_in_user
        unless logged_in?
            store_location
            flash[:danger] = "Please log in."
            redirect_to login_url
        end
    end

    def correct_user
        @user = User.find(params[:id])
        redirect_to(root_url) unless current_user?(@user)
    end

    include SessionsHelper
end
