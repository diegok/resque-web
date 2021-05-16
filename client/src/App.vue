<template>
  <div id="nav">
    <router-link to="/">Overview</router-link>
    <router-link to="/working">Working</router-link>
    <router-link to="/failed">Failed</router-link>
    <router-link to="/queues">Queues</router-link>
    <router-link to="/workers">Workers</router-link>
    <router-link to="/stats">Stats</router-link>
  </div>
  <router-view/>
</template>

<style lang="scss">
body {
  margin:0;
  padding:0;
  background-color:#fafafa;
}

#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
  padding: 0 0 30px 0;
}

#nav {
  text-align: center;
  padding: 30px 0;
  background-color:#fff;
  border-bottom: 1px solid #efefef;

  a {
    padding: 20px;
    font-weight: bold;
    color: #2c3e50;

    &.router-link-exact-active {
      color: #42b983;
    }
  }
}

div.widget {
  width:80%;
  margin: 30px auto 0 auto;
  padding: 15px 30px;
  background-color: #fefefe;
  border-radius: 2px;

  h1 {
    margin:0;
  }

  p {
    font-size: 12px;
    color: #bababa;
  }

  a {
    color: #42b983;
  }

  table {
    border-collapse: collapse;
    border-spacing: 0;
    width:100%;

    td, th {
      border: 1px solid #ccc;
      padding: 6px;
    }

    th {
      background: #efefef;
      color: #888;
      font-size: 15px;
      font-weight: bold;
      text-align: left;
    }
  }
}
</style>
