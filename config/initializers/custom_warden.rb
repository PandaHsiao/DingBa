Warden::Strategies.add(:custom_strategy_name) do
  def valid?
    # code here to check whether to try and authenticate using this strategy; 
    return true/false
  end

  def authenticate!(*args)
    # code here for doing authentication; 
    # if successful, call
    user, opts = _perform_authentication(*args)
    success!(resource) # where resource is the whatever you've authenticated, e.g. user;
                       # if fail, call
    fail!(message) # where message is the failure message 
  end
end 