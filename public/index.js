'use strict';

console.log('started script');
window.onload = () => {
  // DOM loaded
};

const getdata1 = function () {
  return ['hello', 'bye'];
};

const getdata2 = function () {
  const arr = [];
  for (let i = 0; i < 10; i += 1) {
    arr.push(i);
  }
  return arr;
};

// vue.js
window.app = new Vue({
  el: '#app',
  data: {
    collection: getdata1(),
    otherstuff: getdata2(),
  },
  filter: {

  },
  computed: {

  },
  watch: {

  },
  methods: {

  },
});
