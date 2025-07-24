<template>
  <div class="section-title">
    <h2 class="title">{{ title }}</h2>
    <p v-if="subtitle" class="subtitle">{{ subtitle }}</p>
  </div>
</template>

<script setup>
defineProps({
  title: {
    type: String,
    required: true
  },
  subtitle: {
    type: String,
    default: ''
  }
})
</script>

<style lang="scss" scoped>
.section-title {
  text-align: center;
  margin-bottom: 40px;
  
  .title {
    font-size: 32px;
    font-weight: bold;
    color: #333;
    margin-bottom: 10px;
    
    @media (max-width: 768px) {
      font-size: 24px;
    }
  }
  
  .subtitle {
    font-size: 16px;
    color: #666;
    margin: 0;
    
    @media (max-width: 768px) {
      font-size: 14px;
    }
  }
}
</style>