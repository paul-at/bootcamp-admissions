module DashboardHelper
  def statistic_group(items, klass)
    raw '<ul class="list-group">' +
      items.map { |i| statistic(i, klass, 'list-group-item list-group-item-action') }.join +
      '</ul>'
  end

  # Applications statistic with a link to search
  def statistic(item, klass, html_class='')
    raise "Undefined search #{item}" unless klass.searches.has_key?(item)

    count = klass.searches[item].count

    link_text = h(item.to_s.humanize)
    link_text = '<small>' + link_text + '</small>' if item.to_s[0] == '_'

    body = '<span class="tag tag-default tag-pill pull-xs-right">' +
      count.to_s +
      '</span>' +
      link_text

    options = {
      controller: 'app_forms',
      action: 'index',
      search: item.to_s,
      klass_id: klass.id,
    }

    html_class += ' disabled' if count == 0

    link_to body.html_safe, options, class: html_class
  end
end
