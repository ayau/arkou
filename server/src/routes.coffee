app_name = 'arkou'

# index page
exports.index = (req, res) ->
    res.render 'index', {title: app_name}