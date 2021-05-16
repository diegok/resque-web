<template>
  <div class="widget">
    <h1>Stats</h1>
    <p>System status.</p>
    <table>
      <tr>
        <th>Metric</th>
        <th>Value</th>
      </tr>
      <tbody>
        <tr v-for="(value, name) in stats" :key="name">
          <td>{{ name }}</td>
          <td v-if="name === 'redis'">
            <pre v-highlightjs>
              <code class="json">{{ value }}</code>
            </pre>
          </td>
          <td v-else>
            {{ value }}
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
export default {
  data () {
    return {
      loading: false,
      stats: {},
      error: null,
      nextFetch: null
    }
  },
  mounted () { this.fetchData() },
  methods: {
    async fetchData () {
      this.loading = true;
      try {
        this.stats = (await this.$http.get('/stats/resque')).data;
      }
      catch(err) {
        this.error = err;
      }
      this.loading = false;
    }
  }
}
</script>
