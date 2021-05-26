import { createRouter, createWebHistory } from 'vue-router'
import Overview from '../views/Overview.vue'
import Working  from '../views/Working.vue'
import Queues   from '../views/Queues.vue'
import Failed   from '../views/Failed.vue'
import Stats    from '../views/Stats.vue'
import Hosts    from '../views/Hosts.vue'

const routes = [
  { path: '/', component: Overview },
  { path: '/working', component: Working },
  { path: '/failed', component: Failed },
  { path: '/queues', component: Queues },
  { path: '/workers', component: Hosts },
  { path: '/stats', component: Stats },
  { path: '/hosts/:hostname', component: Working },
  { path: '/workers/:id', component: Working },
  { path: '/queues/:name', component: Working },
]

const router = createRouter({
  scrollBehavior(to, from, savedPosition) {
    return savedPosition || { top: 0 };
  },
  history: createWebHistory(process.env.BASE_URL),
  routes
})

export default router
