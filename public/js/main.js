require.config({
  "shim": {
    "jquery": {
      "deps": [],
      "exports": "jQuery"
    },
    "markdown": {
      "deps": [],
      "exports": "markdown"
    }
  }
});
define(['require','jquery','markdown','builtin'], function(require) {

// client/main
var ___CLIENT_MAIN___ = (function(module) {
  (function() {
  var $, markdown, url;

  $ = require('jquery');

  markdown = require('markdown');

  url = require('builtin').url;

  $(document).on('click', 'a', function(evt) {
    var failHelper, helper,
      _this = this;
    evt.preventDefault();
    helper = function(data) {
      return $('#column-2').html(markdown.toHTML(data));
    };
    failHelper = function(xhr, status, text) {
      var errorTxt;
      errorTxt = "<h3>" + status + "</h3><p>Retrieving " + _this.pathname + ": " + text + "</p>";
      return $('#column-2').html(errorTxt);
    };
    console.log('a', 'clicked', this.pathname);
    $.ajax({
      url: this.pathname,
      type: 'GET',
      success: helper,
      error: failHelper
    });
    return false;
  });

  $(function() {
    $.get('content/outline.md', function(data) {
      console.log('contents');
      console.log(data);
      return $('#toc').html(markdown.toHTML(data));
    });
    return $.getJSON('project', function(data) {
      $('#title').html(data.title);
      return $('#description').html(data.description);
    });
  });

}).call(this);

  return module.exports;
})({exports: {}});


  return ___CLIENT_MAIN___;
});
