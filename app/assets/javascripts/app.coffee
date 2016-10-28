refreshVotes = () ->
  $.getJSON(url: document.location.origin + document.location.pathname + '/votes').done (json) ->
    $("[id^=voter]").removeClass 'tag-success tag-danger'
    current_voter = $('.voter-current')
    if current_voter.length > 0
      current_voter = parseInt current_voter[0].id.substring(5)
    $('#screening-revoke').hide()
    $('#screening-vote').hide()

    positive_votes = 0
    negative_votes = 0

    for vote in json
      if vote.vote
        positive_votes++
      else
        negative_votes++
      c = if vote.vote then 'tag-success' else 'tag-danger'
      $('#voter' + vote.user_id).addClass c
      if vote.user_id == current_voter
        $('#screening-revoke').show()
    if $('#screening-revoke').is(':hidden')
      $('#screening-vote').show()

    if $('#application_state').text() == 'Applied'
      invite_disabled = false
      reject_disabled = false
      if positive_votes / $('.voter').length <= 0.5
        invite_disabled = true
      if negative_votes / $('.voter').length <= 0.5
        reject_disabled = true
      $('#event_invite').prop('disabled', invite_disabled)
      $('#event_reject').prop('disabled', reject_disabled)

$(document).on "turbolinks:load", ->
  if $('#screening-vote').length > 0
    refreshVotes()
    $("a[data-remote]").on "ajax:success", (e, data, status, xhr) ->
      refreshVotes()