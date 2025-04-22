module RenderMethods
  extend ActiveSupport::Concern

  RESPONSE_STRUCTURE = {
    status: :code,
    message: :optional,
    data: :optional,
    meta: :optional,
    errors: :optional
  }.freeze

  STATUS_CODES = {
    '100': :continue,
    '102': :processing,
    '200': :ok,
    '201': :created,
    '202': :accepted,
    '203': :non_authoritative_info,
    '204': :no_content,
    '400': :bad_request,
    '401': :unauthorized,
    '403': :forbidden,
    '404': :not_found,
    '405': :method_not_allowed,
    '408': :request_timeout,
    '413': :request_entity_too_large,
    '422': :unprocessable_entity,
    '423': :locked,
    '429': :too_many_requests,
    '500': :interal_server_error,
    '501': :not_implemented,
    '502': :bad_geteway,
    '507': :insufficient_storage,
    '520': :uncnown_error
  }

  STATUS_CODES.each do |code, status|
    define_method "render#{code}" do |**options|
      response = build_response(code.to_s, status, options)
      render json: Oj.dump(response, mode: :compat), status: status
    end
  end
  
  private

  def build_response(code, status, options)
    {
      status: code,
      message: options[:message] || default_message_for(status),
      data: options[:data],
      meta: options[:meta],
      errors: options[:errors]
    }.compact
  end

  def default_message_for(status)
    {
      ok: 'Request successful',
      created: 'Resource created',
      no_content: 'No content',
      bad_request: 'Invalid request',
      unauthorized: 'Authentication required',
      not_found: 'Resource not found',
      unprocessable_entity: 'Validation failed',
      internal_server_error: 'Server error occurred'
    }[status]
  end
end