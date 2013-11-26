module SessionsHelper
	def sign_in(user)
		remember_token = User.new_remember_token
		# Permanent je ve skutecnosti 20 let, v podstate se provadi nasledujici kod:
		# cookies[:remember_token] = { value:   remember_token,
        #                              expires: 20.years.from_now.utc }
		cookies.permanent[:remember_token] = remember_token
		# Tento update nevyvolava zadnou validaci user modelu, coz chceme, protoze nemame heslo atp.
		user.update_attribute(:remember_token, User.encrypt(remember_token))
		self.current_user = user
	end

	def signed_in?
    	!current_user.nil?
  	end

	def current_user=(user)
	    @current_user = user
	end

	# Nelze jen jednoduse vratit @current_user, vse je tu stateless, takze po kazdem requestu je @current_user nil
	# a my si ho musime zase najit
	def current_user
	    remember_token = User.encrypt(cookies[:remember_token])
	    # Pokud bychom ke current_user pristpovali vicekrat v ramci jednoho requestu, tak se nacte jen poprve, pak
	    # uz si ho pamatujeme
	    @current_user ||= User.find_by(remember_token: remember_token)
	end

	def current_user?(user)
    	user == current_user
  	end

	def destroy
	    sign_out
	    redirect_to root_url
	end

	def sign_out
    	self.current_user = nil
    	cookies.delete(:remember_token)
    end

    def redirect_back_or(default)
	    redirect_to(session[:return_to] || default)
	    session.delete(:return_to)
	end

	def store_location
	    session[:return_to] = request.url if request.get?
	end
end
