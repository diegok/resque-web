<template>
  <span>{{ timeAgo }}</span>
</template>

<script>
import TimeAgo from 'javascript-time-ago';
import en      from 'javascript-time-ago/locale/en';

TimeAgo.addDefaultLocale(en);
const timeAgo = new TimeAgo('en-US');

export default {
  props: ['date'],

  data() {
    return {
      now:     Date.now(),
      updater: null
    }
  },

  mounted()       { this.startUpdater() },
  beforeUnmount() { this.stopUpdater() },

  computed: {
    dateObj(){
      return typeof(this.date) === 'string' ? new Date(this.date) : this.date;
    },
    timeAgo(){
      const date = this.dateObj;

      try { return this.now && this.now < date
        ? 'just now' // ... in the future :-/
        : timeAgo.format(date)
      }
      catch(err){ return '' }
    }
  },

  methods: {
    startUpdater() {
      this.updater = setInterval( () => { this.now = Date.now() }, 60000 );
    },

    stopUpdater() {
      if ( this.updater ) {
        clearInterval(this.updater);
        this.updater = null;
      }
    }
  }
}
</script>

<style scoped lang="scss">
  span {
    color: #adadad;
  }
</style>
