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
          <td class="queue">
            <router-link :to="`/queues/${ queue.name }`">
              {{ queue.name }}
            </router-link>
          </td>
          <td>{{ queue.jobs }}</td>
        </tr>
        <tr class="failed">
          <td>
            <router-link to="/failed">
              Failed
            </router-link>
          </td>
          <td>{{ failed }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import { mapState, mapGetters } from 'vuex';
export default {
  data(){ return {} },
  mounted() { this.$store.dispatch('startPeriodic', 'fetchQueues') },
  unmounted() { this.$store.dispatch('stopPeriodic', 'fetchQueues') },
  computed: {
    ...mapGetters(['activeQueues']),
    ...mapState({ failed: 'failedTotal' })
  }
}
</script>

<style scoped lang="scss">
  table {
    td.queue {
      font-weight: bold;
    }

    tr.failed {
      background-color: #ffecec;
      color: #d37474;
      &:hover { background-color: #ffecec; }
      a { color: #d37474; }
    }
  }
</style>
