<template>
  <div class="widget">
    <h1>Failed Jobs</h1>
    <p>Showing {{firstItem}}-{{lastItem}} of {{ total }} jobs.</p>
    <ul>
      <li v-for="job in failed" :key="job.id" class="hover">
        <dl>
          <dt>Worker</dt>
          <dd>
            <router-link :to="`/workers/${ job.worker }`">{{ clearId(job.worker) }}</router-link>
            on <strong>{{ job.queue }}</strong>
            at <strong><time-ago :date="job.failed_at" /></strong>
          </dd>
          <dt>Class</dt>
          <dd>
            <router-link :to="`/failed?class=${ job.payload.class }`">
              <code>{{ job.payload.class }}</code>
            </router-link>
          </dd>
          <dt>Arguments</dt>
          <dd>
            <pre v-highlightjs>
              <code class="json">{{ job.payload.args }}</code>
            </pre>
          </dd>
          <dt>Error</dt>
          <dd class="error">
            <p>{{ job.error }}</p>
          </dd>
        </dl>
      </li>
    </ul>
    <pagination
      :page="page"
      :total="total"
      size="20"
      :onChange="setPage"
    />
  </div>
</template>

<script>
import TimeAgo from '@/components/TimeAgo.vue'
import Pagination from '@/components/Pagination.vue'
export default {
  components: { 'time-ago': TimeAgo, Pagination },
  data () {
    return {
      loading: false,
      failed: [],
      total: 0,
      page: parseInt(this.$route.query.page || 1),
      error: null,
      nextFetch: null
    }
  },
  mounted () { this.fetchData() },
  beforeRouteUpdate(to, from, next) {
    this.page = parseInt( to.query.page || 1 );
    this.fetchData();
    next();
  },
  methods: {
    async fetchData () {
      this.loading = true;
      try {
        console.log(this.page);
        const res = (await this.$http.get(`/failed?page=${this.page}`)).data;
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
    },
    setPage(page) {
      this.$router.push({ query: { page } })
    }
  },
  computed: {
    firstItem(){
      return 0;
    },
    lastItem(){
      return 19;
    }
  }
}
</script>

<style scoped lang="scss">
  ul {
    list-style: none;
    margin:0;
    padding:0;

    li {
      background: -webkit-gradient(linear, left top, left bottom, from(#efefef), to(#fff)) #efefef;
      margin-top: 10px;
      padding: 10px;
      overflow: hidden;
      -webkit-border-radius: 5px;
      border: 1px solid #ccc;
      dt {
        font-size: 80%;
        color: #999;
        width: 60px;
        float: left;
        padding-top: 1px;
        text-align: right;
      }
      dd {
        margin-bottom: 10px;
        margin-left: 70px;
      }
    }
  }
</style>
