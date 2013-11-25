bean = require 'coffee-bean'
path = require 'path'

module.exports =
  init: (app, root) ->
    app.get root, (req, res) ->
      bean.readFile path.join(__dirname, '../public/project.bean'), (err, data) ->
        if err
          res.json 500, err
        else
          res.json data
