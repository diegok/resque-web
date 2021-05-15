module.exports = {
  outputDir: '../lib/Resque/Web/public',
  devServer: {
    proxy: {
      "/": {
        target: "http://localhost:3000",
        logLevel: "debug"
      }
    }
  }
};

