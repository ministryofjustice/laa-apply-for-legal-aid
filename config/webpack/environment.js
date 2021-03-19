const { environment } = require('@rails/webpacker')

const webpack = require('webpack')
environment.plugins.append('Provide', new webpack.ProvidePlugin({
  $: 'jquery'
}))

const config = environment.toWebpackConfig()

config.resolve.alias = {
  jquery: 'jquery/src/jquery'
}

module.exports = environment
