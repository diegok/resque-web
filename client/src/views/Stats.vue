<template>
  <div class="widget">
    <h1>Resque Stats</h1>
    <p>Statistics overview of this resque system.</p>
    <table>
      <tr>
        <th>Metric</th>
        <th>Value</th>
      </tr>
      <tbody>
        <tr><td>Processed</td><td>{{ stats.processed }}</td></tr>
        <tr><td>Queues</td><td>{{ activeQueuesCount }} / {{ queuesCount }}</td></tr>
        <tr><td>Workers</td><td>{{ workingCount }} / {{ workersCount }}</td></tr>
        <tr><td>Pending</td><td>{{ pendingTasksCount }}</td></tr>
        <tr class="failed"><td>Failed</td><td>{{ failedTotal }}</td></tr>
      </tbody>
    </table>
  </div>
  <div class="widget">
    <h1>Redis Stats</h1>
    <p>Statistics overview from the redis backend system used by resque.</p>
    <table>
      <tr>
        <th>Metric</th>
        <th>Value</th>
      </tr>
      <tbody>
        <tr v-for="(value, name) in redisStats" :key="name">
          <td>{{ name }}</td>
          <td>{{ value }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import { mapState, mapGetters } from 'vuex';
export default {
  data() { return {} },
  mounted() {
    this.$store.dispatch('startPeriodic', 'fetchStats');
    this.$store.dispatch('startPeriodic', 'fetchQueues');
    this.$store.dispatch('startPeriodic', 'fetchWorkers');
  },
  unmounted() {
    this.$store.dispatch('stopPeriodic', 'fetchStats');
    this.$store.dispatch('stopPeriodic', 'fetchQueues');
    this.$store.dispatch('stopPeriodic', 'fetchWorkers');
  },
  methods: {
    clearId(id) {
      return id.replace(/:[^:]*$/, '')
    }
  },
  computed: {
    ...mapGetters(['working', 'activeQueues']),
    ...mapState(['workers', 'queues', 'failedTotal', 'redisStats', 'resqueStats' ]),
    workersCount(){ return this.workers.length },
    workingCount(){ return this.working.length },
    queuesCount(){ return this.queues.length },
    activeQueuesCount(){ return this.activeQueues.length },
    stats(){ return this.resqueStats },
    pendingTasksCount(){ return this.queues.map( q => q.jobs ).reduce((total, value) => total + value ) }
  }
}
</script>
