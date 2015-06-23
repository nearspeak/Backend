##
# The DeviseHelper module.
module DeviseHelper
  
  ##
  # Handle device error messages with the bootstrap theme.
  def devise_error_messages!
    return '' if resource.errors.empty?

    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    sentence = I18n.t('errors.messages.not_saved',
                      count: resource.errors.count,
                      resource: resource.class.model_name.human.downcase)

    html = <<-HTML

    <div class="alert alert-info alert-dismissable">

      <a class="close" data-dismiss="alert" href="#">×</a>
      <i class="icon-info-sign"></i>
      #{sentence}
      #{messages}
    </div>

    HTML

    html.html_safe
  end
end