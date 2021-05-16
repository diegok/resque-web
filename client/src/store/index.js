import { createStore } from 'vuex';
import axios from 'axios';

const state = {
  queues: [],
  workers: [],
  failed: [],
  failedTotal: 0,
  resqueStats: {},
  redisStats: {},
  lastError: null,
  periodic: {},
};

const mutations = {
  setQueues(state, items) { state.queues = items },
  setWorkers(state, items) { state.workers = items },
  setFailed(state, items) { state.workers = items },
  setFailedTotal(state, count) { state.failedTotal = count },
  setStats(state, stats) {
    state.redisStats = stats.redis;
    state.resqueStats = delete(stats.redis) && stats;
  },
  setLastError(state, err) { state.lastError = err },
  incPeriodic(state, key) {
    if ( state.periodic[key] ) { state.periodic[key]++   }
    else                       { state.periodic[key] = 1 }
  },
  decPeriodic(state, key) {
    if ( state.periodic[key] ) { state.periodic[key]--   }
    else                       { state.periodic[key] = 0 }
  },
};

const tasks = { waiting: {} };

const actions = {
  startPeriodic({ state, commit, dispatch }, action){
    commit('incPeriodic', action);
    if ( state.periodic[action] === 1 ) {
      dispatch(action);
      const taskId = setInterval( async () => {
        if ( tasks.waiting[action] ) return;
        tasks.waiting[action] = true;
        await dispatch(action);
        tasks.waiting[action] = false;
      }, 1500 );
      tasks[action] = taskId;
    }
  },
  stopPeriodic({ state, commit }, action){
    commit('decPeriodic', action);
    if ( state.periodic[action] === 0 && tasks[action] ) {
      clearInterval(tasks[action]);
      delete tasks[action];
    }
  },
  async fetchQueues({ commit }){
    try {
      const res = (await axios.get('/queues')).data;
      commit('setQueues', res.items);
      commit('setFailedTotal', res.failed);
    }
    catch(error) {
      console.log(error);
      commit('setLastError', { action: 'fetchQueues', error });
    }
  },
  async fetchWorkers({ commit }){
    try {
      const items = (await axios.get('/workers')).data;
      commit('setWorkers', items);
    }
    catch(error) {
      console.log(error);
      commit('setLastError', { action: 'fetchWorkers', error });
    }
  },
  async fetchFailed({ commit }){
    try {
      const res = (await axios.get('/failed')).data;
      commit('setFailed', res.items);
      commit('setFailedTotal', res.total);
    }
    catch(error) {
      console.log(error);
      commit('setLastError', { action: 'fetchFailed', error });
    }
  },
  async fetchStats({ commit }){
    try {
      const stats = (await axios.get('/stats')).data;
      commit('setStats', stats);
    }
    catch(error) {
      console.log(error);
      commit('setLastError', { action: 'fetchStats', error });
    }
  }
};

const getters = {
  activeQueues(state) {
    return state.queues.filter( queue => queue.jobs > 0 )
  },
  working(state) {
    return state.workers.filter( worker => worker.working.state !== 'idle' )
  }
};

export default createStore({ state, mutations, actions, getters });
