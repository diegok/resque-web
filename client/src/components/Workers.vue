<template>
  <div class="widget">
    <h1>{{ workingCount }} of {{ workersCount }} Workers Working</h1>
    <p>The list below contains all workers which are currently running a job.</p>
    <table>
      <tr>
        <th>Host</th>
        <th>PID</th>
        <th>Queue</th>
        <th>Since</th>
        <th>Processing</th>
      </tr>
      <tbody>
        <tr v-for="worker in working" :key="worker.id">
          <td>
            <router-link :to="`/hosts/${ host(worker.id) }`">
              {{ host(worker.id) }}
            </router-link>
          </td>
          <td>
            <router-link :to="`/workers/${ worker.id }`">
              {{ pid(worker.id) }}
            </router-link>
          </td>
          <td>{{ worker.working.queue }}</td>
          <td>
            <time-ago :date="worker.working.run_at" />
          </td>
          <td>
            {{ worker.working.payload.class }}
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import { mapState, mapGetters } from 'vuex';
import TimeAgo from './TimeAgo';

export default {
  data() { return {} },
  components: { 'time-ago': TimeAgo },
  mounted() { this.$store.dispatch('startPeriodic', 'fetchWorkers') },
  unmounted() { this.$store.dispatch('stopPeriodic', 'fetchWorkers') },
  methods: {
    host(id) {
      return id.replace(/:.*$/, '')
    },
    pid(id) {
      return id.replace(/:[^:]*$/, '').replace(/^.*?:/,'')
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
