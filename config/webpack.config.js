const webpack = require("webpack");
const path = require("path");
const glob = require("glob");

module.exports = {
  entry: glob.sync('./app/javascript/packs/*.js').reduce((result, file, index) => {
    result[path.basename(file, '.js')] = file
    return result;
  }, {}),

  output: {
    path: path.resolve(__dirname, "../app/assets"),
    filename: "javascripts/docin/[name].js"
  },

  resolve: {
    modules: [
      path.resolve(__dirname, "../app/javascript"),
      "node_modules"
    ]
  },

  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: [
          { loader: "babel-loader" },
          { loader: "import-glob-loader" }
        ]
      }, {
        test: /\.(css|sass|scss)$/,
        use: [
          { loader: "style-loader" },
          { loader: "css-loader" },
          { loader: "postcss-loader" },
          { loader: "sass-loader" },
          { loader: "import-glob-loader" }
        ]
      }, {
        test: /\.(gif|png)$/,
        type: "asset/inline"
      }
    ]
  },

  watchOptions: {
    poll: 1000,
    ignored: /node_modules/
  }
};
