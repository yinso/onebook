fs = require 'fs'
path = require 'path'

module.exports =
  init: (app, root) ->
    app.get root, (req, res) ->
      # the idea is simple - just serve the index.html.
      fs.readFile path.join(__dirname, '../public/index.html'), 'utf8', (err, data) ->
        if err
          res.json 500, err
        else
          res.send data