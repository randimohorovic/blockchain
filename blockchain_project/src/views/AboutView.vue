<template>
  <div class="about">
    <h1>Povecaj vrijednost ili smanji</h1>
    <Counter />
  </div>
</template>

<style>
@media (min-width: 1024px) {
  .about {
    min-height: 100vh;
    display: flex;
    align-items: center;
  }
}

</style>

<script setup>
import Counter from '../components/Counter.vue'
</script>