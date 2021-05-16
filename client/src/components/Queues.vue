<template>
  <div class="widget">
    <h1>Queues</h1>
    <p>The list below contains all the registered queues with the number of jobs currently in the queue. Select a queue from above to view all jobs currently pending on the queue.</p>
    <table>
      <tr>
        <th>Name</th>
        <th>Jobs</th>
      </tr>
      <tbody>
        <tr v-for="queue in activeQueues" :key="queue.name">
          <td class="queue">{{ queue.name }}</td>
          <td>{{ queue.jobs }}</td>
        </tr>
        <tr class="failed">
          <td>Failed</td>
          <td>{{ failed }}</td>
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
      queues: [],
      failed: 0,
      error: null
    }
  },
  mounted () { this.fetchData() },
  methods: {
    async fetchData () {
      this.loading = true;
      try {
        const res = (await this.$http.get('/queues')).data
        this.queues = res.items;
        this.failed = res.failed;
      }
      catch(err) {
        this.error = err;
      }
      this.loading = false;
    }
  },
  computed: {
    activeQueues() {
      return this.queues.filter( queue => queue.jobs > 0 )
    }
  }

}
</script>

<style lang="scss">
  table {
    td.queue {
      font-weight: bold;
    }

    tr.failed {
      background-color: #ffecec;
      color: #d37474;
    }
  }
</style>
