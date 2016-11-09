module QuillToEmail
  def quill_to_email(html)
    html.gsub(/<p class="ql-align-center">(.*?)<\/p>/, '<table width="100%"><tr><td align="center">\1</td></tr></table>')
  end
end