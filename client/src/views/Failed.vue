<template>
  <div class="widget">
    <h1>Failed Jobs</h1>
    <p>Showing 0-19 of {{ total }} jobs.</p>
    <table>
      <tr>
        <th>Where</th>
        <th>Queue</th>
        <th>Class</th>
        <th>Arguments</th>
        <th>Error</th>
      </tr>
      <tbody>
        <tr v-for="job in failed" :key="job.id">
          <td>{{ clearId(job.worker) }}</td>
          <td>{{ job.queue }}</td>
          <td>{{ job.payload.class }}</td>
          <td>
            <pre v-highlightjs="sourcecode">
              <code class="json">{{ job.payload.args }}</code>
            </pre>
          </td>
          <td>{{ job.error }}</td>
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
      failed: [],
      total: 0,
      error: null,
      nextFetch: null
    }
  },
  mounted () { this.fetchData() },
  methods: {
    async fetchData () {
      this.loading = true;
      try {
        const res = (await this.$http.get('/failed')).data;
        this.failed = res.items;
        this.total = res.total;
      }
      catch(err) {
        this.error = err;
      }
      this.loading = false;
    },
    clearId(id) {
      return id.replace(/:.*$/, '')
    }
  }
}
</script>
