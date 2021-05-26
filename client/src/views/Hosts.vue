<template>
  <div class="widget">
    <h1>{{ busyCount }} of {{ hostsCount }} hosts are working</h1>
    <p>The list below contains all hosts running workers.</p>
    <table>
      <tr>
        <th>Host</th>
        <th>Workers</th>
      </tr>
      <tbody>
        <tr v-for="host in hosts" :key="host.name">
          <td>
            <router-link :to="`/hosts/${ host.name }`">
              {{ host.name }}
            </router-link>
          </td>
          <td>{{ host.working }} / {{ host.workers }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';

export default {
  data() { return {} },
  mounted() { this.$store.dispatch('startPeriodic', 'fetchWorkers') },
  beforUnmounted() { this.$store.dispatch('stopPeriodic', 'fetchWorkers') },
  methods: {
  },
  computed: {
    ...mapGetters(['hosts']),
    hostsCount(){ return this.hosts.length },
    busyCount(){ return this.hosts.filter( host => host.working ).length },
  }
}
</script>
