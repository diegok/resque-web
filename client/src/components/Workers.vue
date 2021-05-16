<template>
  <div class="widget">
    <h1>{{ working.length }} of {{ workers.length }} Workers Working</h1>
    <p>The list below contains all workers which are currently running a job.</p>
    <table>
      <tr>
        <th>Where</th>
        <th>Queue</th>
        <th>Processing</th>
      </tr>
      <tbody>
        <tr v-for="worker in working" :key="worker.id">
          <td>{{ clearId(worker.id) }}</td>
          <td>{{ worker.working.queue }}</td>
          <td>{{ worker.working.payload.class }}</td>
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
      workers: [],
      error: null,
      nextFetch: null
    }
  },
  mounted () { this.fetchData() },
  methods: {
    async fetchData () {
      this.loading = true;
      try {
        this.workers = (await this.$http.get('/workers')).data;
      }
      catch(err) {
        this.error = err;
      }
      this.loading = false;
    },
    clearId(id) {
      return id.replace(/:[^:]*$/, '')
    }
  },
  computed: {
    working() {
      return this.workers.filter( worker => worker.working.state !== 'idle' )
    }
  }
}
</script>
