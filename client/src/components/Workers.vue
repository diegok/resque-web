<template>
  <div class="workers">
    <h1>50 of 462 Workers Working</h1>
    <p>The list below contains all workers which are currently running a job.</p>
  </div>
</template>

<script>
export default {
  data () {
    return {
      loading: false,
      workers: [],
      error: null
    }
  },
  created () { this.fetchData() },
  methods: {
    fetchData () {
      this.loading = true;
    }
  }
}
</script>

<style scoped lang="scss">
div.workers {
  width:75%;
  margin: auto;

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
}
</style>
