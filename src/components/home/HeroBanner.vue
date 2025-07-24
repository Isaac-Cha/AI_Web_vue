<template>
  <div class="hero-banner">
    <el-carousel
      :height="bannerHeight"
      :autoplay="true"
      :interval="5000"
      indicator-position="outside"
    >
      <el-carousel-item v-for="banner in props.banners" :key="banner.id">
        <div class="banner-item" :style="{ backgroundImage: `url(${banner.image})` }">
          <div class="banner-content">
            <div class="container">
              <div class="content-wrapper">
                <h1 class="banner-title">{{ banner.title }}</h1>
                <p class="banner-subtitle">{{ banner.subtitle }}</p>
                <div class="banner-actions">
                  <el-button
                    type="primary"
                    size="large"
                    @click="handleAction(banner.action)"
                  >
                    {{ banner.actionText }}
                  </el-button>
                  <el-button
                    v-if="banner.secondaryAction"
                    size="large"
                    @click="handleAction(banner.secondaryAction)"
                  >
                    {{ banner.secondaryActionText }}
                  </el-button>
                </div>
              </div>
            </div>
          </div>
          <div class="banner-overlay"></div>
        </div>
      </el-carousel-item>
    </el-carousel>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

// 接收从父组件传递的banners数据
const props = defineProps({
  banners: {
    type: Array,
    default: () => [
      {
        id: 1,
        title: '解构建筑设计，开启创意之门',
        subtitle: '专业建筑设计课程，从基础到进阶，助你成为设计大师',
        image: 'https://picsum.photos/1200/500?random=1',
        action: '/courses',
        actionText: '立即学习',
        secondaryAction: '/free',
        secondaryActionText: '免费试听'
      },
      {
        id: 2,
        title: 'CAD制图精品课程',
        subtitle: '零基础学CAD，快速掌握建筑制图技能',
        image: 'https://picsum.photos/1200/500?random=2',
        action: '/course/2',
        actionText: '查看课程',
        secondaryAction: '/live',
        secondaryActionText: '观看直播'
      },
      {
        id: 3,
        title: '建筑可视化表现',
        subtitle: '3D建模+渲染技术，打造震撼视觉效果',
        image: 'https://picsum.photos/1200/500?random=3',
        action: '/course/3',
        actionText: '开始学习',
        secondaryAction: '/community',
        secondaryActionText: '加入社区'
      }
    ]
  }
})

const bannerHeight = ref('500px')

// 响应式高度设置
const updateBannerHeight = () => {
  if (window.innerWidth <= 768) {
    bannerHeight.value = '300px'
  } else if (window.innerWidth <= 1024) {
    bannerHeight.value = '400px'
  } else {
    bannerHeight.value = '500px'
  }
}

onMounted(() => {
  updateBannerHeight()
  window.addEventListener('resize', updateBannerHeight)
})

onUnmounted(() => {
  window.removeEventListener('resize', updateBannerHeight)
})

const handleAction = (action) => {
  router.push(action)
}

onMounted(() => {
  // 可以在这里加载轮播图数据
})
</script>

<style lang="scss" scoped>
.hero-banner {
  width: 100%;
  min-height: 500px;
  
  @media (max-width: 1024px) {
    min-height: 400px;
  }
  
  @media (max-width: 768px) {
    min-height: 300px;
  }
  
  :deep(.el-carousel) {
    height: 100% !important;
    min-height: inherit;
  }
  
  :deep(.el-carousel__container) {
    height: 100% !important;
    min-height: inherit;
  }
  
  :deep(.el-carousel__item) {
    height: 100% !important;
    min-height: inherit;
  }
  
  .banner-item {
    position: relative;
    height: 100%;
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
    display: flex;
    align-items: center;
    
    .banner-overlay {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: rgba(0, 0, 0, 0.4);
      z-index: 1;
    }
    
    .banner-content {
      position: relative;
      z-index: 2;
      width: 100%;
      color: white;
      
      .container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 0 20px;
      }
      
      .content-wrapper {
        max-width: 600px;
        
        .banner-title {
          font-size: 48px;
          font-weight: bold;
          margin-bottom: 20px;
          line-height: 1.2;
          
          @media (max-width: 768px) {
            font-size: 28px;
            margin-bottom: 15px;
          }
        }
        
        .banner-subtitle {
          font-size: 18px;
          margin-bottom: 30px;
          line-height: 1.6;
          opacity: 0.9;
          
          @media (max-width: 768px) {
            font-size: 16px;
            margin-bottom: 25px;
          }
        }
        
        .banner-actions {
          display: flex;
          gap: 15px;
          
          @media (max-width: 768px) {
            flex-direction: column;
            gap: 10px;
            
            .el-button {
              width: 100%;
            }
          }
          
          .el-button {
            padding: 12px 30px;
            font-size: 16px;
            border-radius: 25px;
            
            @media (max-width: 768px) {
              padding: 10px 20px;
              font-size: 14px;
            }
          }
        }
      }
    }
  }
}

:deep(.el-carousel__indicator) {
  @media (max-width: 768px) {
    display: none;
  }
}

:deep(.el-carousel__arrow) {
  width: 50px !important;
  height: 50px !important;
  font-size: 20px !important;
  top: 50% !important;
  transform: translateY(-50%) !important;
  background-color: rgba(255, 255, 255, 0.8) !important;
  border-radius: 50% !important;
  
  &:hover {
    background-color: rgba(255, 255, 255, 0.9) !important;
  }
  
  @media (max-width: 768px) {
    display: none;
  }
}
</style>