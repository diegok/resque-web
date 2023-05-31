<template>
  <ul class="pager" v-if="totalPages > 1">
    <li v-if="previousPage">
      <a @click.prevent="onChange(previousPage)">
        Previous
      </a>
    </li>
    <li v-for="pg in pages" :key="pg">
      <a v-if="pg !== page" @click.prevent="onChange(pg)">
        {{ pg }}
      </a>
      <span v-else>
        {{ pg }}
      </span>
    </li>
    <li v-if="nextPage">
      <a @click.prevent="onChange(nextPage)">
        Next
      </a>
    </li>
  </ul>
</template>

<script>

export default {
  props: ['total', 'size', 'page', 'onChange'],

  computed: {
    totalPages() {
      if ( !this.total || !this.size ) return 0;
      return parseInt(this.total / this.size) + (this.total % this.size ? 1 : 0)
    },
    previousPage() {
      return this.page > 1 ? this.page - 1 : 0;
    },
    nextPage() {
      return this.page < this.totalPages ? this.page + 1 : 0;
    },
    pages() {
      let from = this.page - 5 > 0 ? this.page - 5 : 1;
      let to   = from + 10 > this.totalPages ? this.totalPages : from + 10;
      var list = [];
      for (var i = from; i <= to; i++) { list.push(i) }
      return list;
    },
  }
}
</script>

<style scoped lang="scss">
  ul.pager {
    list-style: none;
    padding: 20px;
    margin: 0 auto;
    display:table;
    li {
      display: inline;
      margin: 5px;
      a {
        cursor: pointer;
        text-decoration:none;
        padding: 6px;
        &:hover {
          background-color: #eee;
          border-radius: 3px;
        }
        &:active {
          background-color: #e1e1e1;
        }
      }
      span {
        padding: 6px;
        background-color: #eee;
        border-radius: 3px;
      }
    }
  }
</style>
