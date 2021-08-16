'use strict'

const webpack = require('webpack')
const path = require('path')
const { merge } = require('webpack-merge')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const CopyWebpackPlugin = require('copy-webpack-plugin')


const port = 8080
const host = 'localhost'
const title = 'ELM autocomplete component example'
const author = 'Gribouille'
const target = process.env.npm_lifecycle_event
const entryPath = path.join(__dirname, 'index.js')
const outputPath = path.join(__dirname, 'dist')


// Common configuration
const commonConfig = {
    mode: target === 'build' ? 'production' : 'development',
    output: {
        path: outputPath,
        filename: target === 'build' ? '[name]-[fullhash].js' : '[name].js',
    },
    resolve: {
        extensions: ['.js', '.elm'],
        modules: [path.resolve(__dirname, './src'), 'node_modules']
    },
    module: {
        noParse: /\.elm$/,
        rules: [
            {
                test: /\.(ts|js)x?$/,
                loader: 'babel-loader',
                exclude: /node_modules/
            },
            {
                test: /\.s[ac]ss$/i,
                use: ['style-loader', 'css-loader', 'resolve-url-loader', 'sass-loader']
            }
        ]
    },
    plugins: [
        new CopyWebpackPlugin({
            patterns: [
                {
                    from: 'favicon.ico',
                    to: outputPath
                }
            ]
        }),
        new HtmlWebpackPlugin({
            template: 'index.html',
            inject: 'body',
            filename: 'index.html',
            title: title,
            author: author
        })
    ]
}

// Development mode
const developmentConfig = {
    entry: entryPath,
    devServer: {
        disableHostCheck: true,
        historyApiFallback: true,
        host: host,
        port: port,
        hot: true,
        contentBase: ['node_modules', '.'].map(x => path.resolve(__dirname, x)),
        publicPath: '/',
        watchOptions: {
            ignored: path.resolve(__dirname, 'node_modules')
        },
    },
    module: {
        rules: [
            {
                test: /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                use: {
                    loader: 'elm-webpack-loader',
                    options: {
                        debug: true
                    }
                }
            }
        ]
    },

}


// Production mode
const productionConfig = {
    entry: entryPath,
    module: {
        rules: [
            {
                test: /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                use: {
                    loader: 'elm-webpack-loader',
                    options: {
                        optimize: true,
                        runtimeOptions: ['-A128M', '-H128M', '-n8m']
                    }
                }
            }
        ]
    },
    optimization: {
        minimize: true,
        nodeEnv: 'production',
        splitChunks: {
            chunks: 'all'
        }
    }
}

if (target === 'dev') {
    module.exports = merge(commonConfig, developmentConfig)
} else {
    module.exports = merge(commonConfig, productionConfig)
}
