import { createRouter, createWebHistory } from 'vue-router'
import Overview from '../views/Overview.vue'
import Working  from '../views/Working.vue'
import Queues   from '../views/Queues.vue'
import Failed   from '../views/Failed.vue'
import Stats    from '../views/Stats.vue'

const routes = [
  {
    path: '/',
    name: 'Overview',
    component: Overview
  },
  {
    path: '/overview',
    name: 'xxx',
    component: Overview
    // route level code-splitting
    // this generates a separate chunk (about.[hash].js) for this route
    // which is lazy-loaded when the route is visited.
    // component: () => import(/* webpackChunkName: "about" */ '../views/About.vue')
  },
  {
    path: '/working',
    name: 'Working',
    component: Working
  },
  {
    path: '/failed',
    name: 'Failed',
    component: Failed
  },
  {
    path: '/queues',
    name: 'Queues',
    component: Queues
  },
  {
    path: '/workers',
    name: 'Workers',
    component: Overview
  },
  {
    path: '/stats',
    name: 'Stats',
    component: Stats
  },
]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
})

export default router
