module ErrorHandlers
  extend ActiveSupport::Concern

  class Forbidden < ActionController::ActionControllerError; end
  class IpAddressRejected < ActionController::ActionControllerError; end

  included do
    rescue_from Exception, with: :rescue500
    rescue_from IpAddressRejected, with: :rescue403
    rescue_from Forbidden, with: :rescue_403
    rescue_from ActionController::RoutingError, with: :rescue404
    rescue_from ActiveRecord::RecordNotFound, with: :rescue404

    def routing_error
      raise ActionController::RoutingError, params[:path]
    end
  end

  private

  def rescue403(err = nil)
    logging(err)
    render 'errors/forbidden', status: :forbidden
  end

  def rescue404(err = nil)
    logging(err)
    render 'errors/not_found', status: :not_found
  end

  def rescue500(err = nil)
    logging(err)
    render 'errors/internal_server_error', status: :internal_server_error
  end

  def logging(err = nil)
    if err
      logger.error err
      logger.error err.backtrace.join("\n")
    end

    @exception = err
  end
end
