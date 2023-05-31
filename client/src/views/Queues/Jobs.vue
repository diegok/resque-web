<template>
  <div class="widget">
    <a class="btn" @click.prevent="remove()">Remove queue</a>
    <h1>Pending jobs on {{ name }}</h1>
    <p>Showing {{ total }} jobs</p>
    <table>
      <tr>
        <th>Class</th>
        <th>Args</th>
      </tr>
      <tbody>
        <tr v-for="job in jobs" :key="job.name">
          <td>{{ job.class }}</td>
          <td>
            <pre v-highlightjs>
              <code class="json">{{ job.args }}</code>
            </pre>
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
      jobs: [],
      total: 0,
      error: null,
      name: this.$route.params.name
    }
  },
  mounted () { this.fetchData() },
  methods: {
    async fetchData () {
      this.loading = true;
      try {
        const res = (await this.$http.get(`/queues/${this.name}`)).data;
        this.jobs = res.jobs;
        this.total = res.total;
      }
      catch(err) {
        this.error = err;
      }
      this.loading = false;
    },
    async remove() {
      try {
        this.loading = true;
        await this.$http.delete(`/queues/${this.name}`);
        this.loading = false;
        this.$router.push('/');
      }
      catch(err) {
        this.error = err;
      }
    }
  }
}
</script>

<style scoped lang="scss">
  a.btn {
    cursor: pointer;
    float: right;
    margin-top:10px;
    padding: 10px 8px 8px;
    color: #111;
    border-radius: 5px;
    text-decoration: none;
    background-color: #eee;
    border: 1px solid #e1e1e1;
    &:hover {
      background-color: red;
      border: 1px solid red;
      color: #fff;
    }
    &:active {
      background-color: #c7332c;
      border: 1px solid #c7332c;
    }
  }
</style>
