<template>
  <div class="live-preview-card">
    <div class="live-list">
      <div
        v-for="live in lives"
        :key="live.id"
        class="live-item"
        @click="goToLive(live.id)"
      >
        <div class="live-cover">
          <img :src="live.cover" :alt="live.title" />
          <div class="live-status" :class="{ 'live': live.isLive }">
            {{ live.isLive ? '直播中' : '预告' }}
          </div>
          <div class="viewer-count" v-if="live.isLive">
            <el-icon><View /></el-icon>
            <span>{{ formatNumber(live.viewers) }}</span>
          </div>
        </div>
        
        <div class="live-info">
          <h3 class="live-title">{{ live.title }}</h3>
          <div class="teacher-info">
            <img :src="live.teacher.avatar" :alt="live.teacher.name" />
            <span>{{ live.teacher.name }}</span>
          </div>
          <div class="live-time">
            <el-icon><Clock /></el-icon>
            <span>{{ formatTime(live.time) }}</span>
          </div>
          <div class="live-actions">
            <el-button
              v-if="live.isLive"
              type="primary"
              size="small"
              @click.stop="joinLive(live.id)"
            >
              立即观看
            </el-button>
            <el-button
              v-else
              type="default"
              size="small"
              @click.stop="reserveLive(live.id)"
            >
              预约提醒
            </el-button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { View, Clock } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'

const router = useRouter()

defineProps({
  lives: {
    type: Array,
    default: () => []
  }
})

const formatNumber = (num) => {
  if (num >= 10000) {
    return (num / 10000).toFixed(1) + '万'
  }
  return num
}

const formatTime = (time) => {
  const date = new Date(time)
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  return `${month}月${day}日 ${hours}:${minutes}`
}

const goToLive = (liveId) => {
  router.push(`/live/${liveId}`)
}

const joinLive = (liveId) => {
  router.push(`/live/${liveId}`)
}

const reserveLive = (liveId) => {
  // 预约直播逻辑
  console.log('预约直播:', liveId)
  ElMessage.success('预约成功，开播前会提醒您')
}
</script>

<style lang="scss" scoped>
.live-preview-card {
  .live-list {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 24px;
    
    @media (max-width: 768px) {
      grid-template-columns: 1fr;
      gap: 16px;
    }
  }
  
  .live-item {
    background: white;
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
    transition: all 0.3s ease;
    cursor: pointer;
    
    &:hover {
      transform: translateY(-4px);
      box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
    }
    
    .live-cover {
      position: relative;
      height: 180px;
      overflow: hidden;
      
      img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        transition: transform 0.3s ease;
      }
      
      &:hover img {
        transform: scale(1.05);
      }
      
      .live-status {
        position: absolute;
        top: 12px;
        left: 12px;
        padding: 4px 8px;
        border-radius: 12px;
        font-size: 12px;
        font-weight: 500;
        color: white;
        background: #909399;
        
        &.live {
          background: #f56c6c;
          animation: pulse 2s infinite;
        }
      }
      
      .viewer-count {
        position: absolute;
        top: 12px;
        right: 12px;
        display: flex;
        align-items: center;
        gap: 4px;
        padding: 4px 8px;
        background: rgba(0, 0, 0, 0.6);
        color: white;
        border-radius: 12px;
        font-size: 12px;
        
        .el-icon {
          font-size: 14px;
        }
      }
    }
    
    .live-info {
      padding: 20px;
      
      .live-title {
        font-size: 16px;
        font-weight: 600;
        color: #333;
        margin-bottom: 12px;
        line-height: 1.4;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
      }
      
      .teacher-info {
        display: flex;
        align-items: center;
        margin-bottom: 10px;
        
        img {
          width: 24px;
          height: 24px;
          border-radius: 50%;
          margin-right: 8px;
        }
        
        span {
          font-size: 14px;
          color: #666;
        }
      }
      
      .live-time {
        display: flex;
        align-items: center;
        gap: 6px;
        margin-bottom: 16px;
        font-size: 14px;
        color: #666;
        
        .el-icon {
          font-size: 16px;
          color: #409eff;
        }
      }
      
      .live-actions {
        .el-button {
          width: 100%;
        }
      }
    }
  }
}

@keyframes pulse {
  0% {
    box-shadow: 0 0 0 0 rgba(245, 108, 108, 0.7);
  }
  70% {
    box-shadow: 0 0 0 10px rgba(245, 108, 108, 0);
  }
  100% {
    box-shadow: 0 0 0 0 rgba(245, 108, 108, 0);
  }
}
</style>