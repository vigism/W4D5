require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req = req
    @res = res
    @already_built_response = false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    if !already_built_response?
      @res.location = url
      @res.status = 302
      @already_built_response = true
    else
      raise 'DoubleRedirect'
    end
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type = "text/html")
    if !already_built_response?
      @res["Content-Type"] = content_type
      # @res["body"] = [content]
      @res.write(content)
      @already_built_response = true
    else
      raise 'Double render!!!'
    end
  end

  
  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    dir_path = File.dirname(__FILE__) #directory 
    dir_path = dir_path[0...-4]
    template_path = File.join(dir_path,"views/#{self.class.to_s.underscore}","#{template_name}.html.erb")
    returned_code = File.read(template_path)
    render_content((ERB.new(returned_code)).result(binding))
  end

  # method exposing a `Session` object
  def session
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end

