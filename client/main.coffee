$ = require 'jquery'
markdown = require 'markdown'
url = require 'url' # why doesn't it copy built-in?

# the URL
$(document).on 'click', 'a', (evt) ->
  evt.preventDefault()
  helper = (data) ->
    $('#column-2').html markdown.toHTML(data)

  failHelper = (xhr, status, text) =>
    errorTxt = "<h3>#{status}</h3><p>Retrieving #{@pathname}: #{text}</p>"
    $('#column-2').html errorTxt

  console.log 'a', 'clicked', @pathname

  $.ajax
    url: @pathname
    type: 'GET'
    success: helper
    error: failHelper

  false





$ () ->
  $.get 'content/outline.md', (data) ->
    console.log 'contents'
    console.log data
    $('#toc').html markdown.toHTML(data)

  $.getJSON 'project', (data) ->
    $('#title').html data.title
    $('#description').html data.description

