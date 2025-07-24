<template>
  <div class="course-detail-page">
    <div v-loading="loading" class="course-detail">
      <!-- 课程头部信息 -->
      <div class="course-header">
        <div class="container">
          <div class="course-header-content">
            <div class="course-info">
              <div class="breadcrumb">
                <el-breadcrumb separator="/">
                  <el-breadcrumb-item :to="{ path: '/' }">首页</el-breadcrumb-item>
                  <el-breadcrumb-item :to="{ path: '/courses' }">课程中心</el-breadcrumb-item>
                  <el-breadcrumb-item>{{ course.title }}</el-breadcrumb-item>
                </el-breadcrumb>
              </div>
              
              <h1 class="course-title">{{ course.title }}</h1>
              <p class="course-subtitle">{{ course.subtitle }}</p>
              
              <div class="course-meta">
                <div class="meta-item">
                  <el-icon><User /></el-icon>
                  <span>讲师：{{ course.instructor }}</span>
                </div>
                <div class="meta-item">
                  <el-icon><Clock /></el-icon>
                  <span>时长：{{ course.duration }}</span>
                </div>
                <div class="meta-item">
                  <el-icon><Document /></el-icon>
                  <span>{{ course.lessons }}节课</span>
                </div>
                <div class="meta-item">
                  <el-icon><Star /></el-icon>
                  <span>{{ course.rating }}分 ({{ course.reviews }}人评价)</span>
                </div>
                <div class="meta-item">
                  <el-icon><View /></el-icon>
                  <span>{{ course.students }}人学习</span>
                </div>
              </div>
              
              <div class="course-tags">
                <el-tag
                  v-for="tag in course.tags"
                  :key="tag"
                  type="info"
                  effect="plain"
                >
                  {{ tag }}
                </el-tag>
              </div>
            </div>
            
            <div class="course-video">
              <div class="video-container">
                <video
                  v-if="course.previewVideo"
                  :src="course.previewVideo"
                  :poster="course.image"
                  controls
                  preload="metadata"
                >
                  您的浏览器不支持视频播放
                </video>
                <img v-else :src="course.image" :alt="course.title" />
                <div class="video-overlay" v-if="!course.previewVideo">
                  <el-icon class="play-icon"><VideoPlay /></el-icon>
                  <span>课程预览</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 课程购买区域 -->
      <div class="course-purchase">
        <div class="container">
          <div class="purchase-card">
            <div class="price-section">
              <div v-if="course.isFree" class="free-price">
                <span class="price-label">免费课程</span>
              </div>
              <div v-else class="paid-price">
                <span class="current-price">¥{{ course.price }}</span>
                <span v-if="course.originalPrice" class="original-price">¥{{ course.originalPrice }}</span>
                <span v-if="course.discount" class="discount">{{ course.discount }}折</span>
              </div>
            </div>
            
            <div class="action-buttons">
              <el-button
                v-if="course.isFree"
                type="primary"
                size="large"
                @click="startLearning"
                :loading="actionLoading"
              >
                <el-icon><VideoPlay /></el-icon>
                开始学习
              </el-button>
              <template v-else>
                <el-button
                  type="primary"
                  size="large"
                  @click="buyNow"
                  :loading="actionLoading"
                >
                  立即购买
                </el-button>
                <el-button
                  size="large"
                  @click="addToCart"
                  :loading="cartLoading"
                >
                  <el-icon><ShoppingCart /></el-icon>
                  加入购物车
                </el-button>
              </template>
            </div>
            
            <div class="course-features">
              <div class="feature-item">
                <el-icon><Clock /></el-icon>
                <span>永久观看</span>
              </div>
              <div class="feature-item">
                <el-icon><Download /></el-icon>
                <span>课件下载</span>
              </div>
              <div class="feature-item">
                <el-icon><ChatDotRound /></el-icon>
                <span>答疑服务</span>
              </div>
              <div class="feature-item">
                <el-icon><Trophy /></el-icon>
                <span>结业证书</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 课程内容 -->
      <div class="course-content">
        <div class="container">
          <div class="content-layout">
            <div class="main-content">
              <!-- 课程介绍 -->
              <div class="content-section">
                <h2>课程介绍</h2>
                <div class="course-description" v-html="course.description"></div>
              </div>

              <!-- 学习目标 -->
              <div class="content-section">
                <h2>学习目标</h2>
                <ul class="learning-objectives">
                  <li v-for="objective in course.objectives" :key="objective">
                    <el-icon><Check /></el-icon>
                    {{ objective }}
                  </li>
                </ul>
              </div>

              <!-- 课程大纲 -->
              <div class="content-section">
                <h2>课程大纲</h2>
                <div class="course-outline">
                  <el-collapse v-model="activeChapters">
                    <el-collapse-item
                      v-for="(chapter, index) in course.chapters"
                      :key="chapter.id"
                      :title="`第${index + 1}章 ${chapter.title}`"
                      :name="chapter.id"
                    >
                      <template #title>
                        <div class="chapter-title">
                          <span>第{{ index + 1 }}章 {{ chapter.title }}</span>
                          <span class="chapter-info">{{ chapter.lessons.length }}节课 · {{ chapter.duration }}</span>
                        </div>
                      </template>
                      
                      <div class="chapter-content">
                        <div
                          v-for="(lesson, lessonIndex) in chapter.lessons"
                          :key="lesson.id"
                          class="lesson-item"
                          @click="playLesson(lesson)"
                        >
                          <div class="lesson-info">
                            <el-icon class="lesson-icon">
                              <VideoPlay v-if="lesson.type === 'video'" />
                              <Document v-else-if="lesson.type === 'document'" />
                              <EditPen v-else />
                            </el-icon>
                            <span class="lesson-title">{{ lessonIndex + 1 }}. {{ lesson.title }}</span>
                          </div>
                          <div class="lesson-meta">
                            <span class="lesson-duration">{{ lesson.duration }}</span>
                            <el-icon v-if="lesson.isFree" class="free-icon"><Unlock /></el-icon>
                            <el-icon v-else class="lock-icon"><Lock /></el-icon>
                          </div>
                        </div>
                      </div>
                    </el-collapse-item>
                  </el-collapse>
                </div>
              </div>

              <!-- 学员评价 -->
              <div class="content-section">
                <h2>学员评价</h2>
                <div class="reviews-section">
                  <div class="reviews-summary">
                    <div class="rating-overview">
                      <div class="rating-score">{{ course.rating }}</div>
                      <div class="rating-stars">
                        <el-rate
                          v-model="course.rating"
                          disabled
                          show-score
                          text-color="#ff9900"
                        />
                        <span class="rating-count">{{ course.reviews }}人评价</span>
                      </div>
                    </div>
                    
                    <div class="rating-distribution">
                      <div
                        v-for="(count, star) in course.ratingDistribution"
                        :key="star"
                        class="rating-bar"
                      >
                        <span class="star-label">{{ star }}星</span>
                        <div class="progress-bar">
                          <div
                            class="progress-fill"
                            :style="{ width: `${(count / course.reviews) * 100}%` }"
                          ></div>
                        </div>
                        <span class="count">{{ count }}</span>
                      </div>
                    </div>
                  </div>
                  
                  <div class="reviews-list">
                    <div
                      v-for="review in course.reviewsList"
                      :key="review.id"
                      class="review-item"
                    >
                      <div class="review-header">
                        <div class="user-info">
                          <img :src="review.avatar" :alt="review.username" class="user-avatar" />
                          <div class="user-details">
                            <span class="username">{{ review.username }}</span>
                            <span class="review-date">{{ formatDate(review.date) }}</span>
                          </div>
                        </div>
                        <el-rate v-model="review.rating" disabled size="small" />
                      </div>
                      <div class="review-content">{{ review.content }}</div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- 侧边栏 -->
            <div class="sidebar">
              <!-- 讲师信息 -->
              <div class="instructor-card">
                <h3>讲师介绍</h3>
                <div class="instructor-info">
                  <img :src="course.instructorAvatar" :alt="course.instructor" class="instructor-avatar" />
                  <div class="instructor-details">
                    <h4>{{ course.instructor }}</h4>
                    <p class="instructor-title">{{ course.instructorTitle }}</p>
                    <p class="instructor-bio">{{ course.instructorBio }}</p>
                  </div>
                </div>
              </div>

              <!-- 相关课程 -->
              <div class="related-courses">
                <h3>相关课程</h3>
                <div class="related-course-list">
                  <div
                    v-for="relatedCourse in relatedCourses"
                    :key="relatedCourse.id"
                    class="related-course-item"
                    @click="goToCourse(relatedCourse.id)"
                  >
                    <img :src="relatedCourse.image" :alt="relatedCourse.title" />
                    <div class="related-course-info">
                      <h4>{{ relatedCourse.title }}</h4>
                      <div class="related-course-price">
                        <span v-if="relatedCourse.isFree" class="free">免费</span>
                        <span v-else class="price">¥{{ relatedCourse.price }}</span>
                      </div>
                    </div>
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
import { ref, reactive, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  User, Clock, Document, Star, View, VideoPlay, ShoppingCart,
  Download, ChatDotRound, Trophy, Check, EditPen, Unlock, Lock
} from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()

// 响应式数据
const loading = ref(true)
const actionLoading = ref(false)
const cartLoading = ref(false)
const activeChapters = ref(['1'])

const course = ref({})
const relatedCourses = ref([])

// 模拟课程数据
const mockCourse = {
  id: 1,
  title: 'AutoCAD建筑制图基础',
  subtitle: '从零开始学习AutoCAD，掌握建筑制图的基本技能和规范',
  image: 'https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=400&h=300&fit=crop&crop=center',
  previewVideo: null,
  instructor: '张建筑',
  instructorTitle: '高级建筑师',
  instructorAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
  instructorBio: '拥有15年建筑设计经验，参与过多个大型建筑项目的设计工作，精通AutoCAD、Revit等专业软件。',
  duration: '20小时',
  lessons: 45,
  students: 1234,
  rating: 4.8,
  reviews: 156,
  price: 299,
  originalPrice: 399,
  discount: 7.5,
  isFree: false,
  tags: ['AutoCAD', '建筑制图', '基础入门', '软件技能'],
  description: `
    <p>本课程是专为建筑设计初学者打造的AutoCAD基础教程。通过系统的学习，您将掌握AutoCAD的基本操作、建筑制图规范以及实际项目应用技巧。</p>
    <p>课程采用理论与实践相结合的方式，通过大量的案例练习，让您快速上手AutoCAD软件，为后续的建筑设计学习打下坚实基础。</p>
    <h3>适合人群：</h3>
    <ul>
      <li>建筑设计专业学生</li>
      <li>想要转行建筑设计的人员</li>
      <li>需要提升CAD技能的从业者</li>
      <li>对建筑制图感兴趣的爱好者</li>
    </ul>
  `,
  objectives: [
    '掌握AutoCAD软件的基本操作和界面布局',
    '学会使用各种绘图工具和修改命令',
    '了解建筑制图的基本规范和标准',
    '能够独立完成简单的建筑平面图绘制',
    '掌握图层管理和标注技巧',
    '学会打印输出和文件管理'
  ],
  chapters: [
    {
      id: '1',
      title: 'AutoCAD基础入门',
      duration: '3小时',
      lessons: [
        { id: '1-1', title: 'AutoCAD界面介绍', type: 'video', duration: '15分钟', isFree: true },
        { id: '1-2', title: '基本操作和设置', type: 'video', duration: '20分钟', isFree: true },
        { id: '1-3', title: '坐标系统详解', type: 'video', duration: '25分钟', isFree: false },
        { id: '1-4', title: '练习：界面熟悉', type: 'document', duration: '30分钟', isFree: false }
      ]
    },
    {
      id: '2',
      title: '绘图工具详解',
      duration: '5小时',
      lessons: [
        { id: '2-1', title: '直线和多段线', type: 'video', duration: '30分钟', isFree: false },
        { id: '2-2', title: '圆和弧的绘制', type: 'video', duration: '25分钟', isFree: false },
        { id: '2-3', title: '矩形和多边形', type: 'video', duration: '20分钟', isFree: false },
        { id: '2-4', title: '样条曲线和椭圆', type: 'video', duration: '25分钟', isFree: false },
        { id: '2-5', title: '综合练习', type: 'document', duration: '45分钟', isFree: false }
      ]
    }
  ],
  ratingDistribution: {
    5: 98,
    4: 42,
    3: 12,
    2: 3,
    1: 1
  },
  reviewsList: [
    {
      id: 1,
      username: '学员***123',
      avatar: '/avatars/user-1.jpg',
      rating: 5,
      date: '2024-01-15',
      content: '课程内容很详细，老师讲解清晰，对于初学者来说非常友好。通过学习已经能够独立完成简单的建筑图纸绘制了。'
    },
    {
      id: 2,
      username: '建筑***456',
      avatar: '/avatars/user-2.jpg',
      rating: 4,
      date: '2024-01-10',
      content: '整体不错，但是希望能增加更多实际项目案例。老师的专业水平很高，答疑也很及时。'
    }
  ]
}

const mockRelatedCourses = [
  {
    id: 2,
    title: 'SketchUp建筑建模入门',
    image: 'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=400&h=300&fit=crop&crop=center',
    price: 199,
    isFree: false
  },
  {
    id: 3,
    title: '建筑设计原理与方法',
    image: 'https://images.unsplash.com/photo-1448630360428-65456885c650?w=400&h=300&fit=crop&crop=center',
    price: 0,
    isFree: true
  }
]

// 方法
const loadCourseData = async () => {
  try {
    loading.value = true
    // 模拟API调用
    await new Promise(resolve => setTimeout(resolve, 500))
    
    const courseId = route.params.id
    // 这里应该根据courseId从API获取数据
    course.value = { ...mockCourse, id: parseInt(courseId) }
    relatedCourses.value = mockRelatedCourses
  } catch (error) {
    ElMessage.error('加载课程信息失败')
  } finally {
    loading.value = false
  }
}

const startLearning = async () => {
  const isLoggedIn = localStorage.getItem('isLoggedIn')
  if (!isLoggedIn) {
    ElMessage.warning('请先登录后再开始学习')
    router.push('/login')
    return
  }
  
  actionLoading.value = true
  try {
    // 模拟开始学习
    await new Promise(resolve => setTimeout(resolve, 1000))
    ElMessage.success('开始学习课程')
    // 跳转到视频播放页面
    router.push({
      path: '/video-player',
      query: {
        title: course.value.title,
        type: 'course',
        from: 'courses'
      }
    })
  } catch (error) {
    ElMessage.error('操作失败，请重试')
  } finally {
    actionLoading.value = false
  }
}

const buyNow = async () => {
  const isLoggedIn = localStorage.getItem('isLoggedIn')
  if (!isLoggedIn) {
    ElMessage.warning('请先登录后再购买')
    router.push('/login')
    return
  }
  
  try {
    await ElMessageBox.confirm(
      `确认购买课程《${course.value.title}》？`,
      '确认购买',
      {
        confirmButtonText: '确认',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    actionLoading.value = true
    // 模拟购买
    await new Promise(resolve => setTimeout(resolve, 1500))
    ElMessage.success('购买成功！')
    // 这里可以跳转到支付页面或学习页面
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('购买失败，请重试')
    }
  } finally {
    actionLoading.value = false
  }
}

const addToCart = async () => {
  const isLoggedIn = localStorage.getItem('isLoggedIn')
  if (!isLoggedIn) {
    ElMessage.warning('请先登录后再添加到购物车')
    router.push('/login')
    return
  }
  
  cartLoading.value = true
  try {
    // 模拟添加到购物车
    await new Promise(resolve => setTimeout(resolve, 800))
    ElMessage.success('已添加到购物车')
  } catch (error) {
    ElMessage.error('添加失败，请重试')
  } finally {
    cartLoading.value = false
  }
}

const playLesson = (lesson) => {
  if (!lesson.isFree) {
    const isLoggedIn = localStorage.getItem('isLoggedIn')
    if (!isLoggedIn) {
      ElMessage.warning('请先登录后观看')
      router.push('/login')
      return
    }
    
    // 检查是否已购买课程
    ElMessage.warning('请先购买课程后观看')
    return
  }
  
  ElMessage.success(`开始播放：${lesson.title}`)
  // 跳转到视频播放页面
  router.push({
    path: '/video-player',
    query: {
      title: lesson.title,
      type: 'lesson',
      from: 'courses'
    }
  })
}

const goToCourse = (courseId) => {
  router.push(`/course/${courseId}`)
}

const formatDate = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN')
}

onMounted(() => {
  loadCourseData()
})
</script>

<style lang="scss" scoped>
.course-detail-page {
  min-height: 100vh;
  background: #f8f9fa;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

.course-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 30px 0 50px;
  
  .course-header-content {
    display: grid;
    grid-template-columns: 1fr 400px;
    gap: 40px;
    align-items: start;
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
  
  .course-title {
    font-size: 2.5rem;
    font-weight: 600;
    margin-bottom: 10px;
    line-height: 1.2;
  }
  
  .course-subtitle {
    font-size: 1.2rem;
    opacity: 0.9;
    margin-bottom: 25px;
    line-height: 1.5;
  }
  
  .course-meta {
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
  
  .course-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    
    .el-tag {
      background: rgba(255, 255, 255, 0.2);
      border: 1px solid rgba(255, 255, 255, 0.3);
      color: white;
    }
  }
  
  .course-video {
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
        flex-direction: column;
        align-items: center;
        justify-content: center;
        color: white;
        cursor: pointer;
        
        .play-icon {
          font-size: 48px;
          margin-bottom: 10px;
        }
      }
    }
  }
}

.course-purchase {
  background: white;
  padding: 30px 0;
  border-bottom: 1px solid #e9ecef;
  
  .purchase-card {
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 20px;
    
    .price-section {
      .free-price {
        .price-label {
          font-size: 24px;
          font-weight: 600;
          color: #52c41a;
        }
      }
      
      .paid-price {
        display: flex;
        align-items: baseline;
        gap: 10px;
        
        .current-price {
          font-size: 32px;
          font-weight: 600;
          color: #ff4d4f;
        }
        
        .original-price {
          font-size: 18px;
          color: #999;
          text-decoration: line-through;
        }
        
        .discount {
          background: #ff4d4f;
          color: white;
          padding: 2px 6px;
          border-radius: 4px;
          font-size: 12px;
        }
      }
    }
    
    .action-buttons {
      display: flex;
      gap: 15px;
      
      .el-button {
        padding: 12px 24px;
        font-size: 16px;
      }
    }
    
    .course-features {
      display: flex;
      gap: 20px;
      
      .feature-item {
        display: flex;
        align-items: center;
        gap: 6px;
        color: #666;
        font-size: 14px;
      }
    }
  }
}

.course-content {
  padding: 40px 0;
  
  .content-layout {
    display: grid;
    grid-template-columns: 1fr 300px;
    gap: 40px;
  }
  
  .main-content {
    .content-section {
      background: white;
      border-radius: 12px;
      padding: 30px;
      margin-bottom: 30px;
      box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
      
      h2 {
        font-size: 24px;
        font-weight: 600;
        margin-bottom: 20px;
        color: #333;
        border-bottom: 2px solid #667eea;
        padding-bottom: 10px;
      }
      
      .course-description {
        line-height: 1.8;
        color: #666;
        
        :deep(h3) {
          color: #333;
          margin: 20px 0 10px;
        }
        
        :deep(ul) {
          padding-left: 20px;
          
          li {
            margin-bottom: 8px;
          }
        }
      }
      
      .learning-objectives {
        list-style: none;
        padding: 0;
        
        li {
          display: flex;
          align-items: center;
          gap: 10px;
          margin-bottom: 12px;
          padding: 10px;
          background: #f8f9fa;
          border-radius: 6px;
          
          .el-icon {
            color: #52c41a;
            font-size: 16px;
          }
        }
      }
      
      .course-outline {
        .chapter-title {
          display: flex;
          justify-content: space-between;
          align-items: center;
          width: 100%;
          
          .chapter-info {
            color: #999;
            font-size: 14px;
            font-weight: normal;
          }
        }
        
        .chapter-content {
          .lesson-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid #f0f0f0;
            cursor: pointer;
            transition: background-color 0.2s;
            
            &:hover {
              background: #f8f9fa;
            }
            
            &:last-child {
              border-bottom: none;
            }
            
            .lesson-info {
              display: flex;
              align-items: center;
              gap: 10px;
              
              .lesson-icon {
                color: #667eea;
              }
              
              .lesson-title {
                color: #333;
              }
            }
            
            .lesson-meta {
              display: flex;
              align-items: center;
              gap: 10px;
              
              .lesson-duration {
                color: #999;
                font-size: 14px;
              }
              
              .free-icon {
                color: #52c41a;
              }
              
              .lock-icon {
                color: #999;
              }
            }
          }
        }
      }
      
      .reviews-section {
        .reviews-summary {
          display: grid;
          grid-template-columns: 200px 1fr;
          gap: 30px;
          margin-bottom: 30px;
          padding-bottom: 20px;
          border-bottom: 1px solid #f0f0f0;
          
          .rating-overview {
            text-align: center;
            
            .rating-score {
              font-size: 48px;
              font-weight: 600;
              color: #ff9900;
              margin-bottom: 10px;
            }
            
            .rating-stars {
              .rating-count {
                display: block;
                color: #999;
                font-size: 14px;
                margin-top: 5px;
              }
            }
          }
          
          .rating-distribution {
            .rating-bar {
              display: flex;
              align-items: center;
              gap: 10px;
              margin-bottom: 8px;
              
              .star-label {
                width: 40px;
                font-size: 14px;
                color: #666;
              }
              
              .progress-bar {
                flex: 1;
                height: 8px;
                background: #f0f0f0;
                border-radius: 4px;
                overflow: hidden;
                
                .progress-fill {
                  height: 100%;
                  background: #ff9900;
                  transition: width 0.3s ease;
                }
              }
              
              .count {
                width: 30px;
                text-align: right;
                font-size: 14px;
                color: #999;
              }
            }
          }
        }
        
        .reviews-list {
          .review-item {
            padding: 20px 0;
            border-bottom: 1px solid #f0f0f0;
            
            &:last-child {
              border-bottom: none;
            }
            
            .review-header {
              display: flex;
              justify-content: space-between;
              align-items: center;
              margin-bottom: 10px;
              
              .user-info {
                display: flex;
                align-items: center;
                gap: 12px;
                
                .user-avatar {
                  width: 40px;
                  height: 40px;
                  border-radius: 50%;
                  object-fit: cover;
                }
                
                .user-details {
                  .username {
                    display: block;
                    font-weight: 500;
                    color: #333;
                  }
                  
                  .review-date {
                    font-size: 12px;
                    color: #999;
                  }
                }
              }
            }
            
            .review-content {
              color: #666;
              line-height: 1.6;
            }
          }
        }
      }
    }
  }
  
  .sidebar {
    .instructor-card,
    .related-courses {
      background: white;
      border-radius: 12px;
      padding: 20px;
      margin-bottom: 20px;
      box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
      
      h3 {
        font-size: 18px;
        font-weight: 600;
        margin-bottom: 15px;
        color: #333;
      }
    }
    
    .instructor-info {
      .instructor-avatar {
        width: 60px;
        height: 60px;
        border-radius: 50%;
        object-fit: cover;
        margin-bottom: 15px;
      }
      
      .instructor-details {
        h4 {
          font-size: 16px;
          font-weight: 600;
          margin-bottom: 5px;
          color: #333;
        }
        
        .instructor-title {
          color: #667eea;
          font-size: 14px;
          margin-bottom: 10px;
        }
        
        .instructor-bio {
          color: #666;
          font-size: 14px;
          line-height: 1.5;
        }
      }
    }
    
    .related-course-list {
      .related-course-item {
        display: flex;
        gap: 12px;
        padding: 12px 0;
        border-bottom: 1px solid #f0f0f0;
        cursor: pointer;
        transition: background-color 0.2s;
        
        &:hover {
          background: #f8f9fa;
        }
        
        &:last-child {
          border-bottom: none;
        }
        
        img {
          width: 60px;
          height: 45px;
          border-radius: 6px;
          object-fit: cover;
        }
        
        .related-course-info {
          flex: 1;
          
          h4 {
            font-size: 14px;
            font-weight: 500;
            margin-bottom: 5px;
            color: #333;
            line-height: 1.3;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
          }
          
          .related-course-price {
            .free {
              color: #52c41a;
              font-weight: 500;
            }
            
            .price {
              color: #ff4d4f;
              font-weight: 500;
            }
          }
        }
      }
    }
  }
}

// 响应式设计
@media (max-width: 768px) {
  .course-header {
    .course-header-content {
      grid-template-columns: 1fr !important;
      gap: 20px !important;
    }
    
    .course-title {
      font-size: 2rem !important;
    }
    
    .course-meta {
      flex-direction: column !important;
      gap: 10px !important;
    }
  }
  
  .course-purchase {
    .purchase-card {
      flex-direction: column !important;
      align-items: stretch !important;
      
      .action-buttons {
        justify-content: center;
      }
      
      .course-features {
        justify-content: center;
        flex-wrap: wrap;
      }
    }
  }
  
  .course-content {
    .content-layout {
      grid-template-columns: 1fr !important;
      gap: 20px !important;
    }
    
    .content-section {
      padding: 20px !important;
    }
    
    .reviews-summary {
      grid-template-columns: 1fr !important;
      gap: 20px !important;
    }
  }
}
</style>