'use strict';

const webpack               = require('webpack');
const path                  = require('path');
const merge                 = require('webpack-merge');
const ExtractTextPlugin     = require("extract-text-webpack-plugin");
const HtmlWebpackPlugin     = require('html-webpack-plugin');
const CopyWebpackPlugin     = require('copy-webpack-plugin');
const CleanWebpackPlugin    = require('clean-webpack-plugin');


const port              = 8080;
const host              = 'localhost';
const title             = 'ELM autocomplete component example';
const author            = 'Gribouille';
const target            = process.env.npm_lifecycle_event;
const entryPath         = path.join(__dirname, 'index.js');
const outputPath        = path.join(__dirname, 'dist');
const outputFilename    = target === 'dist' ? '[name]-[hash].js' : '[name].js'


const htmlPlugin = new HtmlWebpackPlugin({
    template: 'index.html',
    inject: 'body',
    filename: 'index.html',
    title: title,
    author: 'Gribs'
});


// Common configuration
const commonConfig = {
    output: {
        path: outputPath,
        filename: `static/js/${outputFilename}`,

    },
    resolve: {
        extensions: ['.js', '.elm'],
        modules: ['node_modules']
    },
    module: {
        noParse: /\.elm$/,
        rules: [{
            test: /\.(eot|ttf|woff|woff2|svg)$/,
            use: 'file-loader?publicPath=../../&name=static/css/[hash].[ext]'
        }]
    }
}

// Development mode
const developmentConfig = {
    entry: [
        `webpack-dev-server/client?http://${host}:${port}`,
        entryPath
    ],
    devServer: {
        // serve index.html in place of 404 responses
        historyApiFallback: true,
        contentBase: [
            '../src', 
            '../node_modules', 
            './src', 
            './'
        ],
        hot: true
    },
    module: {
        rules: [
            {
                test: /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                use: [
                    {
                        loader: 'elm-webpack-loader',
                        options: {
                            verbose: true,
                            debug: true
                        }
                    }
                ]
            }, 
            {
                test: /\.sc?ss$/,
                use: [
                    {loader: 'style-loader'}, 
                    {loader: 'css-loader'}, 
                    {
                        loader: 'sass-loader',
                        options: {
                            sassOptions: {
                                includePaths: [
                                    path.resolve(__dirname, 'node_modules'),
                                ]
                            }
                        }
                    }
                ]
            }
        ]
    },
    plugins: [htmlPlugin]
};


// Production mode
const productionConfig = {
    entry: entryPath,
    module: {
        rules: [{
            test: /\.elm$/,
            exclude: [/elm-stuff/, /node_modules/],
            use: [
                    { loader: 'elm-hot-webpack-loader' },
                    {
                        loader: 'elm-webpack-loader',
                        options: {
                            optimize: true,
                            verbose: true
                        }
                    }
                ]
        }, {
            test: /\.sc?ss$/,
            use: ExtractTextPlugin.extract({
                fallback: 'style-loader',
                use: [
                    'css-loader', 
                    'sass-loader'
                ]
            })
        }]
    },
    plugins: [
        new ExtractTextPlugin({
            filename: 'static/css/[name]-[hash].css',
            allChunks: true,
        }),
        new CopyWebpackPlugin([
            // {
            //     from: 'assets/images/',
            //     to: 'static/images/'
            // }, 
            {
                from: 'favicon.ico'
            }
        ]),
        htmlPlugin
    ]
};

if (target === 'dev') {
    module.exports = merge(commonConfig, developmentConfig);
} else {
    module.exports = merge(commonConfig, productionConfig);
}
