<template>
  <div>
    <h2>{{ counter.count }}</h2>
    <button @click="counter.increment">+</button>
    <button @click="counter.decrement">-</button>
  </div>
</template>

<script setup>
import { useCounterStore } from '../stores/counter.js'

const counter = useCounterStore()
</script>
