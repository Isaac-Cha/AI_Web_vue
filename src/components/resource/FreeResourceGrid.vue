<template>
  <div class="free-resource-grid">
    <div class="grid-container">
      <div
        v-for="resource in resources"
        :key="resource.id"
        class="resource-card"
        @click="handleDownload(resource)"
      >
        <div class="resource-image">
          <img :src="resource.thumbnail" :alt="resource.title" />
          <div class="resource-type" :class="resource.type">
            {{ getTypeText(resource.type) }}
          </div>
          <div class="download-overlay">
            <el-icon class="download-icon"><Download /></el-icon>
            <span>点击下载</span>
          </div>
        </div>
        
        <div class="resource-content">
          <h3 class="resource-title">{{ resource.title }}</h3>
          <p class="resource-desc">{{ resource.description }}</p>
          
          <div class="resource-meta">
            <div class="file-info">
              <span class="file-size">{{ formatFileSize(resource.size) }}</span>
              <span class="file-format">{{ resource.format.toUpperCase() }}</span>
            </div>
            <div class="download-count">
              <el-icon><Download /></el-icon>
              <span>{{ formatNumber(resource.downloadCount) }}</span>
            </div>
          </div>
          
          <div class="resource-tags">
            <el-tag
              v-for="tag in resource.tags"
              :key="tag"
              size="small"
              type="info"
            >
              {{ tag }}
            </el-tag>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { Download } from '@element-plus/icons-vue'

defineProps({
  resources: {
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

const formatFileSize = (bytes) => {
  if (bytes === 0) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

const getTypeText = (type) => {
  const typeMap = {
    template: '模板',
    material: '素材',
    tool: '工具',
    tutorial: '教程',
    plugin: '插件'
  }
  return typeMap[type] || '资源'
}

const handleDownload = (resource) => {
  // 这里可以添加下载逻辑
  console.log('下载资源:', resource)
  // 实际项目中可能需要调用API记录下载次数
}
</script>

<style lang="scss" scoped>
.free-resource-grid {
  .grid-container {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 24px;
    
    @media (max-width: 768px) {
      grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
      gap: 16px;
    }
  }
  
  .resource-card {
    background: white;
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
    transition: all 0.3s ease;
    cursor: pointer;
    
    &:hover {
      transform: translateY(-4px);
      box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
      
      .download-overlay {
        opacity: 1;
      }
    }
    
    .resource-image {
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
      
      .resource-type {
        position: absolute;
        top: 12px;
        left: 12px;
        padding: 4px 8px;
        border-radius: 12px;
        font-size: 12px;
        font-weight: 500;
        color: white;
        
        &.template {
          background: #722ed1;
        }
        
        &.material {
          background: #13c2c2;
        }
        
        &.tool {
          background: #fa8c16;
        }
        
        &.tutorial {
          background: #52c41a;
        }
        
        &.plugin {
          background: #eb2f96;
        }
      }
      
      .download-overlay {
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(0, 0, 0, 0.7);
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        color: white;
        opacity: 0;
        transition: opacity 0.3s ease;
        
        .download-icon {
          font-size: 32px;
          margin-bottom: 8px;
        }
        
        span {
          font-size: 14px;
        }
      }
    }
    
    .resource-content {
      padding: 20px;
      
      .resource-title {
        font-size: 16px;
        font-weight: 600;
        color: #333;
        margin-bottom: 8px;
        line-height: 1.4;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
      }
      
      .resource-desc {
        font-size: 14px;
        color: #666;
        line-height: 1.5;
        margin-bottom: 16px;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
      }
      
      .resource-meta {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 16px;
        
        .file-info {
          display: flex;
          gap: 8px;
          
          .file-size {
            font-size: 12px;
            color: #999;
          }
          
          .file-format {
            font-size: 12px;
            color: #666;
            background: #f5f5f5;
            padding: 2px 6px;
            border-radius: 4px;
          }
        }
        
        .download-count {
          display: flex;
          align-items: center;
          gap: 4px;
          font-size: 12px;
          color: #999;
          
          .el-icon {
            font-size: 14px;
          }
        }
      }
      
      .resource-tags {
        display: flex;
        flex-wrap: wrap;
        gap: 6px;
        
        .el-tag {
          font-size: 11px;
        }
      }
    }
  }
}
</style>