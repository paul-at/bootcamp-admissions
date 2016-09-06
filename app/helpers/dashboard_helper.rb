module DashboardHelper
  def statistic_group(items, klass)
    raw '<ul class="list-group">' +
      items.map { |i| statistic(i, klass) }.join +
      '</ul>'
  end

  # Applications statistic with a link to search
  def statistic(item, klass)
    count = klass.searches[item].count

    body = '<span class="tag tag-default tag-pill pull-xs-right">' +
      count.to_s +
      '</span>' +
      h(item.to_s.humanize)

    options = {
      controller: 'app_forms',
      action: 'index',
      search: item.to_s,
      klass_id: klass.id,
    }

    html_class = 'list-group-item list-group-item-action'
    html_class += ' disabled' if count == 0

    link_to body.html_safe, options, class: html_class
  end
end
