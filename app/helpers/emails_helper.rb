module EmailsHelper
  def email_hint(body, field, value)
    link_to(body, '#', onClick: "$('#email_#{field}').val($('#email_#{field}').val() + ($('#email_#{field}').val()?', ':'') + '#{value}'); return false")
  end
end