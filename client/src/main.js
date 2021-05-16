import { createApp } from 'vue'
import axios from 'axios'
import VueAxios from 'vue-axios'
import VueHighlightJS from 'vue3-highlightjs'
import 'highlight.js/styles/github-gist.css'

import App from './App.vue'
import router from './router'
import store from './store'

createApp(App)
  .use(VueAxios, axios)
  .use(store)
  .use(router)
  .use(VueHighlightJS)
  .mount('#app')
