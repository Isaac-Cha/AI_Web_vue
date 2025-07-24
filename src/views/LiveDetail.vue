<template>
  <div class="live-detail-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="container">
        <el-breadcrumb separator="/">
          <el-breadcrumb-item :to="{ path: '/' }">首页</el-breadcrumb-item>
          <el-breadcrumb-item :to="{ path: '/live' }">直播课程</el-breadcrumb-item>
          <el-breadcrumb-item>{{ liveDetail.title }}</el-breadcrumb-item>
        </el-breadcrumb>
        
        <div class="live-header-content">
          <div class="live-info">
            <h1 class="live-title">{{ liveDetail.title }}</h1>
            <p class="live-subtitle">{{ liveDetail.description }}</p>
            
            <div class="live-meta">
              <div class="meta-item">
                <el-icon><User /></el-icon>
                <span>{{ liveDetail.instructor }}</span>
              </div>
              <div class="meta-item">
                <el-icon><Calendar /></el-icon>
                <span>{{ formatDateTime(liveDetail.startTime) }}</span>
              </div>
              <div class="meta-item">
                <el-icon><Clock /></el-icon>
                <span>{{ liveDetail.duration }}</span>
              </div>
              <div class="meta-item" v-if="liveDetail.isLive">
                <el-icon><View /></el-icon>
                <span>{{ liveDetail.viewers }}人观看</span>
              </div>
            </div>
            
            <div class="live-status">
              <el-tag v-if="liveDetail.isLive" type="danger" size="large">
                <el-icon><VideoCamera /></el-icon>
                直播中
              </el-tag>
              <el-tag v-else-if="liveDetail.isUpcoming" type="warning" size="large">
                <el-icon><Bell /></el-icon>
                即将开始
              </el-tag>
              <el-tag v-else type="info" size="large">
                <el-icon><VideoPlay /></el-icon>
                回放
              </el-tag>
            </div>
          </div>
          
          <div class="live-video">
            <div class="video-container">
              <img :src="liveDetail.image" :alt="liveDetail.title" v-if="!liveDetail.isLive" />
              <video v-else controls>
                <source :src="liveDetail.videoUrl" type="video/mp4">
                您的浏览器不支持视频播放
              </video>
              
              <div v-if="!liveDetail.isLive" class="video-overlay">
                <el-button 
                  type="primary" 
                  size="large" 
                  @click="handleAction"
                  :loading="actionLoading"
                >
                  <el-icon><VideoPlay v-if="!liveDetail.isUpcoming" /><Bell v-else /></el-icon>
                  {{ liveDetail.isUpcoming ? '预约直播' : '观看回放' }}
                </el-button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 直播内容 -->
    <div class="live-content">
      <div class="container">
        <div class="content-layout">
          <div class="main-content">
            <!-- 课程介绍 -->
            <div class="section-card">
              <h3>课程介绍</h3>
              <div class="course-description">
                <p>{{ liveDetail.fullDescription }}</p>
                
                <h4>课程亮点</h4>
                <ul>
                  <li v-for="highlight in liveDetail.highlights" :key="highlight">
                    {{ highlight }}
                  </li>
                </ul>
                
                <h4>适合人群</h4>
                <ul>
                  <li v-for="audience in liveDetail.targetAudience" :key="audience">
                    {{ audience }}
                  </li>
                </ul>
              </div>
            </div>

            <!-- 课程大纲 -->
            <div class="section-card">
              <h3>课程大纲</h3>
              <div class="course-outline">
                <div 
                  v-for="(chapter, index) in liveDetail.outline" 
                  :key="index"
                  class="outline-item"
                >
                  <div class="chapter-header">
                    <span class="chapter-number">{{ index + 1 }}</span>
                    <span class="chapter-title">{{ chapter.title }}</span>
                    <span class="chapter-duration">{{ chapter.duration }}</span>
                  </div>
                  <p class="chapter-description">{{ chapter.description }}</p>
                </div>
              </div>
            </div>

            <!-- 互动区域 -->
            <div class="section-card" v-if="liveDetail.isLive">
              <h3>实时互动</h3>
              <div class="chat-area">
                <div class="chat-messages">
                  <div 
                    v-for="message in chatMessages" 
                    :key="message.id"
                    class="chat-message"
                  >
                    <img :src="message.avatar" :alt="message.username" class="user-avatar" />
                    <div class="message-content">
                      <div class="message-header">
                        <span class="username">{{ message.username }}</span>
                        <span class="timestamp">{{ formatTime(message.timestamp) }}</span>
                      </div>
                      <p class="message-text">{{ message.content }}</p>
                    </div>
                  </div>
                </div>
                
                <div class="chat-input">
                  <el-input
                    v-model="newMessage"
                    placeholder="输入消息参与互动..."
                    @keyup.enter="sendMessage"
                  >
                    <template #append>
                      <el-button @click="sendMessage" :disabled="!newMessage.trim()">
                        发送
                      </el-button>
                    </template>
                  </el-input>
                </div>
              </div>
            </div>
          </div>

          <div class="sidebar">
            <!-- 讲师信息 -->
            <div class="instructor-card">
              <div class="instructor-header">
                <img :src="liveDetail.instructorAvatar" :alt="liveDetail.instructor" class="instructor-avatar" />
                <div class="instructor-info">
                  <h4>{{ liveDetail.instructor }}</h4>
                  <p>{{ liveDetail.instructorTitle }}</p>
                </div>
              </div>
              <p class="instructor-bio">{{ liveDetail.instructorBio }}</p>
              <div class="instructor-stats">
                <div class="stat-item">
                  <span class="stat-number">{{ liveDetail.instructorStats.courses }}</span>
                  <span class="stat-label">课程</span>
                </div>
                <div class="stat-item">
                  <span class="stat-number">{{ liveDetail.instructorStats.students }}</span>
                  <span class="stat-label">学员</span>
                </div>
                <div class="stat-item">
                  <span class="stat-number">{{ liveDetail.instructorStats.rating }}</span>
                  <span class="stat-label">评分</span>
                </div>
              </div>
            </div>

            <!-- 相关课程 -->
            <div class="related-courses">
              <h4>相关课程</h4>
              <div class="course-list">
                <div 
                  v-for="course in relatedCourses" 
                  :key="course.id"
                  class="course-item"
                  @click="goToCourse(course.id)"
                >
                  <img :src="course.image" :alt="course.title" />
                  <div class="course-info">
                    <h5>{{ course.title }}</h5>
                    <p class="course-price">{{ course.price === 0 ? '免费' : `¥${course.price}` }}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import {
  User, Calendar, Clock, View, VideoCamera, Bell, VideoPlay
} from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()

// 响应式数据
const actionLoading = ref(false)
const newMessage = ref('')

// 直播详情数据
const liveDetail = ref({
  id: 1,
  title: 'AutoCAD高级建模技巧实战',
  description: '深入学习AutoCAD高级建模技巧，提升设计效率',
  fullDescription: '本次直播将深入讲解AutoCAD的高级建模技巧，包括复杂几何体的创建、参数化设计、动态块的应用等内容。通过实际案例演示，帮助学员掌握高效的设计方法。',
  image: 'https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=400&h=300&fit=crop&crop=center',
  instructor: '张工程师',
  instructorTitle: '高级建筑师',
  instructorAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
  instructorBio: '拥有15年建筑设计经验，精通各类设计软件，曾参与多个大型项目设计。',
  instructorStats: {
    courses: 25,
    students: 5420,
    rating: 4.9
  },
  startTime: new Date(),
  duration: '2小时30分',
  viewers: 1234,
  isLive: true,
  isUpcoming: false,
  highlights: [
    '实战案例教学，即学即用',
    '高级建模技巧全面解析',
    '参数化设计方法详解',
    '动态块应用技巧分享'
  ],
  targetAudience: [
    '有AutoCAD基础的设计师',
    '希望提升建模效率的工程师',
    '建筑、机械相关专业学生'
  ],
  outline: [
    {
      title: '复杂几何体建模',
      duration: '30分钟',
      description: '学习创建复杂的三维几何体，掌握高级建模命令'
    },
    {
      title: '参数化设计应用',
      duration: '45分钟',
      description: '了解参数化设计理念，学会创建智能化的设计模型'
    },
    {
      title: '动态块制作技巧',
      duration: '40分钟',
      description: '掌握动态块的创建方法，提升设计效率'
    },
    {
      title: '实战案例演练',
      duration: '35分钟',
      description: '通过实际项目案例，综合运用所学技巧'
    }
  ]
})

// 聊天消息
const chatMessages = ref([
  {
    id: 1,
    username: '学员小王',
    avatar: '/avatars/user-1.jpg',
    content: '老师讲得很清楚，受益匪浅！',
    timestamp: new Date(Date.now() - 5 * 60 * 1000)
  },
  {
    id: 2,
    username: '设计师李',
    avatar: '/avatars/user-2.jpg',
    content: '这个参数化设计方法太实用了',
    timestamp: new Date(Date.now() - 3 * 60 * 1000)
  }
])

// 相关课程
const relatedCourses = ref([
  {
    id: 2,
    title: 'AutoCAD基础入门',
    image: 'https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=400&h=300&fit=crop&crop=center',
    price: 199
  },
  {
    id: 3,
    title: 'SketchUp建模技巧',
    image: 'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=400&h=300&fit=crop&crop=center',
    price: 299
  }
])

// 方法
const formatDateTime = (date) => {
  return date.toLocaleString('zh-CN')
}

const formatTime = (date) => {
  return date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
}

const handleAction = async () => {
  const isLoggedIn = localStorage.getItem('isLoggedIn')
  if (!isLoggedIn) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return
  }

  actionLoading.value = true
  
  try {
    await new Promise(resolve => setTimeout(resolve, 1000))
    
    if (liveDetail.value.isUpcoming) {
      ElMessage.success('预约成功！我们会在开播前提醒您')
    } else {
      ElMessage.success('正在加载回放视频...')
      // 跳转到视频播放页面
      router.push({
        path: '/video-player',
        query: {
          title: liveDetail.value.title,
          type: liveDetail.value.isLive ? 'live' : 'live-replay',
          from: 'live-detail'
        }
      })
    }
  } catch (error) {
    ElMessage.error('操作失败，请重试')
  } finally {
    actionLoading.value = false
  }
}

const sendMessage = () => {
  if (!newMessage.value.trim()) return
  
  const isLoggedIn = localStorage.getItem('isLoggedIn')
  if (!isLoggedIn) {
    ElMessage.warning('请先登录后再发送消息')
    return
  }

  chatMessages.value.push({
    id: Date.now(),
    username: '我',
    avatar: '/avatars/current-user.jpg',
    content: newMessage.value,
    timestamp: new Date()
  })
  
  newMessage.value = ''
}

const goToCourse = (courseId) => {
  router.push(`/course/${courseId}`)
}

onMounted(() => {
  // 根据路由参数加载直播详情
  const liveId = route.params.id
  // 这里可以根据liveId加载对应的直播数据
})
</script>

<style lang="scss" scoped>
.live-detail-page {
  min-height: 100vh;
  background: #f8f9fa;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

.page-header {
  background: linear-gradient(135deg, #ff4d4f 0%, #ff7875 100%);
  color: white;
  padding: 30px 0 50px;
  
  .live-header-content {
    display: grid;
    grid-template-columns: 1fr 400px;
    gap: 40px;
    align-items: start;
    margin-top: 20px;
  }
  
  .breadcrumb {
    margin-bottom: 20px;
    
    :deep(.el-breadcrumb__inner) {
      color: rgba(255, 255, 255, 0.8);
      
      &.is-link {
        color: white;
        
        &:hover {
          color: #ffd700;
        }
      }
    }
  }
  
  .live-title {
    font-size: 2.5rem;
    font-weight: 600;
    margin-bottom: 10px;
    line-height: 1.2;
  }
  
  .live-subtitle {
    font-size: 1.2rem;
    opacity: 0.9;
    margin-bottom: 25px;
    line-height: 1.5;
  }
  
  .live-meta {
    display: flex;
    flex-wrap: wrap;
    gap: 20px;
    margin-bottom: 20px;
    
    .meta-item {
      display: flex;
      align-items: center;
      gap: 6px;
      font-size: 14px;
      opacity: 0.9;
    }
  }
  
  .live-status {
    .el-tag {
      padding: 8px 16px;
      font-size: 14px;
      
      .el-icon {
        margin-right: 4px;
      }
    }
  }
  
  .live-video {
    .video-container {
      position: relative;
      border-radius: 12px;
      overflow: hidden;
      box-shadow: 0 8px 25px rgba(0, 0, 0, 0.3);
      
      video, img {
        width: 100%;
        height: 225px;
        object-fit: cover;
      }
      
      .video-overlay {
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(0, 0, 0, 0.5);
        display: flex;
        align-items: center;
        justify-content: center;
        
        .el-button {
          padding: 12px 24px;
          font-size: 16px;
        }
      }
    }
  }
}

.live-content {
  padding: 30px 0;
  
  .content-layout {
    display: grid;
    grid-template-columns: 1fr 300px;
    gap: 30px;
  }
}

.section-card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  margin-bottom: 24px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  
  h3 {
    font-size: 20px;
    font-weight: 600;
    color: #333;
    margin-bottom: 20px;
    padding-bottom: 10px;
    border-bottom: 2px solid #f0f0f0;
  }
  
  h4 {
    font-size: 16px;
    font-weight: 600;
    color: #333;
    margin: 20px 0 10px;
  }
  
  ul {
    padding-left: 20px;
    
    li {
      margin-bottom: 8px;
      line-height: 1.6;
    }
  }
}

.course-outline {
  .outline-item {
    border: 1px solid #e9ecef;
    border-radius: 8px;
    padding: 16px;
    margin-bottom: 12px;
    
    .chapter-header {
      display: flex;
      align-items: center;
      gap: 12px;
      margin-bottom: 8px;
      
      .chapter-number {
        background: #ff4d4f;
        color: white;
        width: 24px;
        height: 24px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 12px;
        font-weight: 600;
      }
      
      .chapter-title {
        font-weight: 600;
        flex: 1;
      }
      
      .chapter-duration {
        color: #666;
        font-size: 14px;
      }
    }
    
    .chapter-description {
      color: #666;
      line-height: 1.6;
      margin-left: 36px;
    }
  }
}

.chat-area {
  .chat-messages {
    max-height: 300px;
    overflow-y: auto;
    margin-bottom: 16px;
    
    .chat-message {
      display: flex;
      gap: 12px;
      margin-bottom: 16px;
      
      .user-avatar {
        width: 32px;
        height: 32px;
        border-radius: 50%;
        object-fit: cover;
      }
      
      .message-content {
        flex: 1;
        
        .message-header {
          display: flex;
          align-items: center;
          gap: 8px;
          margin-bottom: 4px;
          
          .username {
            font-weight: 600;
            font-size: 14px;
          }
          
          .timestamp {
            color: #999;
            font-size: 12px;
          }
        }
        
        .message-text {
          line-height: 1.5;
        }
      }
    }
  }
}

.instructor-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 20px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  
  .instructor-header {
    display: flex;
    gap: 12px;
    margin-bottom: 16px;
    
    .instructor-avatar {
      width: 60px;
      height: 60px;
      border-radius: 50%;
      object-fit: cover;
    }
    
    .instructor-info {
      h4 {
        font-size: 18px;
        font-weight: 600;
        margin-bottom: 4px;
      }
      
      p {
        color: #666;
        font-size: 14px;
      }
    }
  }
  
  .instructor-bio {
    color: #666;
    line-height: 1.6;
    margin-bottom: 16px;
  }
  
  .instructor-stats {
    display: flex;
    justify-content: space-around;
    padding-top: 16px;
    border-top: 1px solid #f0f0f0;
    
    .stat-item {
      text-align: center;
      
      .stat-number {
        display: block;
        font-size: 20px;
        font-weight: 600;
        color: #ff4d4f;
      }
      
      .stat-label {
        font-size: 12px;
        color: #666;
      }
    }
  }
}

.related-courses {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  
  h4 {
    font-size: 16px;
    font-weight: 600;
    margin-bottom: 16px;
  }
  
  .course-item {
    display: flex;
    gap: 12px;
    padding: 12px;
    border-radius: 8px;
    cursor: pointer;
    transition: background 0.3s ease;
    
    &:hover {
      background: #f8f9fa;
    }
    
    img {
      width: 60px;
      height: 45px;
      border-radius: 6px;
      object-fit: cover;
    }
    
    .course-info {
      flex: 1;
      
      h5 {
        font-size: 14px;
        font-weight: 600;
        margin-bottom: 4px;
        line-height: 1.3;
      }
      
      .course-price {
        color: #ff4d4f;
        font-weight: 600;
        font-size: 14px;
      }
    }
  }
}
</style>