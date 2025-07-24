<template>
  <div class="course-grid">
    <div class="grid-container">
      <div
        v-for="course in courses"
        :key="course.id"
        class="course-card"
        @click="goToCourse(course.id)"
      >
        <div class="course-image">
          <img :src="course.cover" :alt="course.title" />
          <div class="course-badge" v-if="course.isHot">
            <span>热门</span>
          </div>
          <div class="course-level" :class="course.level">
            {{ getLevelText(course.level) }}
          </div>
        </div>
        
        <div class="course-content">
          <h3 class="course-title">{{ course.title }}</h3>
          <p class="course-desc">{{ course.description }}</p>
          
          <div class="course-meta">
            <div class="teacher">
              <img :src="course.teacher.avatar" :alt="course.teacher.name" />
              <span>{{ course.teacher.name }}</span>
            </div>
            <div class="stats">
              <span class="students">{{ formatNumber(course.studentCount) }}人学习</span>
            </div>
          </div>
          
          <div class="course-footer">
            <div class="price">
              <span v-if="course.originalPrice" class="original-price">
                ¥{{ course.originalPrice }}
              </span>
              <span class="current-price">
                {{ course.price === 0 ? '免费' : `¥${course.price}` }}
              </span>
            </div>
            <div class="rating">
              <el-rate
                v-model="course.rating"
                disabled
                show-score
                text-color="#ff9900"
                score-template="{value}"
              />
            </div>
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
  courses: {
    type: Array,
    default: () => []
  }
})

const goToCourse = (courseId) => {
  router.push(`/course/${courseId}`)
}

const getLevelText = (level) => {
  const levelMap = {
    beginner: '入门',
    intermediate: '进阶',
    advanced: '高级'
  }
  return levelMap[level] || '入门'
}

const formatNumber = (num) => {
  if (num >= 10000) {
    return (num / 10000).toFixed(1) + '万'
  }
  return num
}
</script>

<style lang="scss" scoped>
.course-grid {
  .grid-container {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 24px;
    
    @media (max-width: 768px) {
      grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
      gap: 16px;
    }
  }
  
  .course-card {
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
    
    .course-image {
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
      
      .course-badge {
        position: absolute;
        top: 12px;
        left: 12px;
        background: linear-gradient(45deg, #ff6b6b, #ee5a24);
        color: white;
        padding: 4px 8px;
        border-radius: 12px;
        font-size: 12px;
        font-weight: 500;
      }
      
      .course-level {
        position: absolute;
        top: 12px;
        right: 12px;
        padding: 4px 8px;
        border-radius: 12px;
        font-size: 12px;
        font-weight: 500;
        color: white;
        
        &.beginner {
          background: #52c41a;
        }
        
        &.intermediate {
          background: #faad14;
        }
        
        &.advanced {
          background: #f5222d;
        }
      }
    }
    
    .course-content {
      padding: 20px;
      
      .course-title {
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
      
      .course-desc {
        font-size: 14px;
        color: #666;
        line-height: 1.5;
        margin-bottom: 16px;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
      }
      
      .course-meta {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 16px;
        
        .teacher {
          display: flex;
          align-items: center;
          
          img {
            width: 24px;
            height: 24px;
            border-radius: 50%;
            margin-right: 6px;
          }
          
          span {
            font-size: 13px;
            color: #666;
          }
        }
        
        .stats {
          .students {
            font-size: 13px;
            color: #999;
          }
        }
      }
      
      .course-footer {
        display: flex;
        justify-content: space-between;
        align-items: center;
        
        .price {
          .original-price {
            font-size: 12px;
            color: #999;
            text-decoration: line-through;
            margin-right: 6px;
          }
          
          .current-price {
            font-size: 18px;
            font-weight: 600;
            color: #f5222d;
          }
        }
        
        .rating {
          :deep(.el-rate) {
            .el-rate__text {
              font-size: 12px;
              color: #666;
            }
          }
        }
      }
    }
  }
}
</style>