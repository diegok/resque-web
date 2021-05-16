<template>
  <div class="widget">
    <h1>{{ workingCount }} of {{ workersCount }} Workers Working</h1>
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
import { mapState, mapGetters } from 'vuex';
export default {
  data() { return {} },
  mounted() { this.$store.dispatch('startPeriodic', 'fetchWorkers') },
  unmounted() { this.$store.dispatch('stopPeriodic', 'fetchWorkers') },
  methods: {
    clearId(id) {
      return id.replace(/:[^:]*$/, '')
    }
  },
  computed: {
    ...mapGetters(['working']),
    ...mapState(['workers']),
    workersCount(){ return this.workers.length },
    workingCount(){ return this.working.length }
  }
}
</script>
