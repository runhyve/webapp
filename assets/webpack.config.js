const path = require('path');
const glob = require('glob');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const TerserPlugin = require('terser-webpack-plugin')

module.exports = (env, options) => ({
  optimization: {
    minimizer: [
      new OptimizeCSSAssetsPlugin({})
    ]
  },
  entry: {
      './app.js': ['./js/app.js'].concat(glob.sync('./vendor/**/*.js')),
      './hypervisor.js': ['./js/hypervisor.js'].concat(glob.sync('./vendor/**/*.js')),
      './machine.js': ['./js/machine.js'].concat(glob.sync('./vendor/**/*.js')),
      './team.js': ['./js/team.js'].concat(glob.sync('./vendor/**/*.js')),
      './admin.js': ['./js/admin.js'].concat(glob.sync('./vendor/**/*.js')),
      './ip_pool.js': ['./js/ip_pool.js'].concat(glob.sync('./vendor/**/*.js')),
  },
  output: {
    filename: '[name]',
    path: path.resolve(__dirname, '../priv/static/js')
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader'
        }
      },
      {
        test: /\.scss$/,
        use: [MiniCssExtractPlugin.loader, 'css-loader', 'sass-loader']
      },
      {
        test: /.(ttf|otf|eot|svg|woff(2)?)(\?[a-z0-9]+)?$/,
        use: [{
          loader: 'file-loader',
          options: {
            name: '[name].[ext]',
            outputPath: '../fonts/',
          }
        }]
      },
      {
        test: /\.(jpg|png|gif)$/,
        loader: "file-loader",
        options: {
          name: "[name].[ext]",
          outputPath: "../static/images/",
          publicPath: "../images/"
        }
      }
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({ filename: '../css/app.css' }),
    new CopyWebpackPlugin([{ from: 'static/', to: '../' }]),
    new TerserPlugin({parallel: true, terserOptions: { ecma: 6} })
  ]
});
