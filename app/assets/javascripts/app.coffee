refreshVotes = () ->
  $.getJSON(url: document.location.href + '/votes').done (json) ->
    $("[id^=voter]").removeClass 'tag-success tag-danger'
    current_voter = $('.voter-current')
    if current_voter.length > 0
      current_voter = parseInt current_voter[0].id.substring(5)
    $('#screening-revoke').hide()
    $('#screening-vote').hide()
    for vote in json
      c = if vote.vote then 'tag-success' else 'tag-danger'
      $('#voter' + vote.user_id).addClass c
      if vote.user_id == current_voter
        $('#screening-revoke').show()
    if $('#screening-revoke').is(':hidden')
      $('#screening-vote').show()

$(document).on "turbolinks:load", ->
  if $('#screening-vote').length > 0
    refreshVotes()
    $("a[data-remote]").on "ajax:success", (e, data, status, xhr) ->
      refreshVotes()