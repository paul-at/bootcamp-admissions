module DashboardHelper
  def statistic_group(items, klass)
    raw '<ul class="list-group">' +
      items.map { |i| statistic(i, klass, 'list-group-item list-group-item-action') }.join +
      '</ul>'
  end

  # Applications statistic with a link to search
  def statistic(item, klass, html_class='')
    count = statistic_count(klass, item)

    link_text = h(item.to_s.humanize)
    link_text = '<small>' + link_text + '</small>' if item.to_s[0] == '_'

    body = '<span class="tag tag-default tag-pill pull-xs-right">' +
      count.to_s +
      '</span>' +
      link_text

    html_class += ' disabled' if count == 0

    link_to body.html_safe, options_hash(klass.id, item), class: html_class
  end

  def statistic_count(klass, item)
    @statistic_groups[klass.id][item] || (klass.searches[item] ? klass.searches[item].count : 0)
  end

  def todo_link(klass_id, search, count, title)
    content_tag :li, link_to("<big>#{count}</big>".html_safe, options_hash(klass_id, search)) + ' ' +
      title.gsub(/_(\w+)_/) {|s| link_to($1, options_hash(klass_id, search)) }.html_safe
  end

  private
  def options_hash(klass_id, search)
    {
      controller: 'app_forms',
      action: 'index',
      search: search.to_s,
      klass_id: klass_id,
    }
  end
end
