<template>
  <div class="teacher-card-grid">
    <div class="grid-container">
      <div
        v-for="teacher in teachers"
        :key="teacher.id"
        class="teacher-card"
        @click="goToTeacher(teacher.id)"
      >
        <div class="teacher-avatar">
          <img :src="teacher.avatar" :alt="teacher.name" />
          <div class="online-status" v-if="teacher.isOnline"></div>
        </div>
        
        <div class="teacher-info">
          <h3 class="teacher-name">{{ teacher.name }}</h3>
          <p class="teacher-title">{{ teacher.title }}</p>
          <p class="teacher-intro">{{ teacher.introduction }}</p>
          
          <div class="teacher-stats">
            <div class="stat-item">
              <span class="stat-label">学生</span>
              <span class="stat-value">{{ formatNumber(teacher.studentCount) }}</span>
            </div>
            <div class="stat-item">
              <span class="stat-label">课程</span>
              <span class="stat-value">{{ teacher.courseCount }}</span>
            </div>
            <div class="stat-item">
              <span class="stat-label">评分</span>
              <span class="stat-value">{{ teacher.rating.toFixed(1) }}</span>
            </div>
          </div>
          
          <div class="teacher-tags">
            <el-tag
              v-for="tag in teacher.specialties"
              :key="tag"
              size="small"
              type="primary"
            >
              {{ tag }}
            </el-tag>
          </div>
          
          <div class="teacher-actions">
            <el-button
              type="primary"
              size="small"
              @click.stop="followTeacher(teacher.id)"
            >
              {{ teacher.isFollowed ? '已关注' : '关注' }}
            </el-button>
            <el-button
              type="default"
              size="small"
              @click.stop="viewCourses(teacher.id)"
            >
              查看课程
            </el-button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'

const router = useRouter()

defineProps({
  teachers: {
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

const goToTeacher = (teacherId) => {
  router.push(`/teacher/${teacherId}`)
}

const followTeacher = (teacherId) => {
  // 关注老师逻辑
  console.log('关注老师:', teacherId)
}

const viewCourses = (teacherId) => {
  router.push(`/courses?teacher=${teacherId}`)
}
</script>

<style lang="scss" scoped>
.teacher-card-grid {
  .grid-container {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 24px;
    
    @media (max-width: 768px) {
      grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
      gap: 16px;
    }
  }
  
  .teacher-card {
    background: white;
    border-radius: 16px;
    padding: 24px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
    transition: all 0.3s ease;
    cursor: pointer;
    text-align: center;
    
    &:hover {
      transform: translateY(-4px);
      box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
    }
    
    .teacher-avatar {
      position: relative;
      display: inline-block;
      margin-bottom: 16px;
      
      img {
        width: 80px;
        height: 80px;
        border-radius: 50%;
        object-fit: cover;
        border: 3px solid #f0f0f0;
        transition: transform 0.3s ease;
      }
      
      &:hover img {
        transform: scale(1.05);
      }
      
      .online-status {
        position: absolute;
        bottom: 5px;
        right: 5px;
        width: 16px;
        height: 16px;
        background: #52c41a;
        border: 2px solid white;
        border-radius: 50%;
      }
    }
    
    .teacher-info {
      .teacher-name {
        font-size: 18px;
        font-weight: 600;
        color: #333;
        margin-bottom: 4px;
      }
      
      .teacher-title {
        font-size: 14px;
        color: #409eff;
        margin-bottom: 8px;
        font-weight: 500;
      }
      
      .teacher-intro {
        font-size: 13px;
        color: #666;
        line-height: 1.5;
        margin-bottom: 16px;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
      }
      
      .teacher-stats {
        display: flex;
        justify-content: space-around;
        margin-bottom: 16px;
        padding: 12px 0;
        background: #f8f9fa;
        border-radius: 8px;
        
        .stat-item {
          display: flex;
          flex-direction: column;
          align-items: center;
          
          .stat-label {
            font-size: 12px;
            color: #999;
            margin-bottom: 4px;
          }
          
          .stat-value {
            font-size: 16px;
            font-weight: 600;
            color: #333;
          }
        }
      }
      
      .teacher-tags {
        display: flex;
        flex-wrap: wrap;
        justify-content: center;
        gap: 6px;
        margin-bottom: 20px;
        
        .el-tag {
          font-size: 11px;
        }
      }
      
      .teacher-actions {
        display: flex;
        gap: 8px;
        
        .el-button {
          flex: 1;
        }
      }
    }
  }
}
</style>