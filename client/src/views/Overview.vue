<template>
  <div class="Overview">
    <Queues/>
    <Workers/>
  </div>
</template>

<script>
import Queues from '@/components/Queues.vue'
import Workers from '@/components/Workers.vue'

export default {
  name: 'Home',
  components: { Queues, Workers }
}
</script>
