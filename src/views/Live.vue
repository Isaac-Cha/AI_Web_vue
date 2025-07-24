<template>
  <div class="live-courses-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="container">
        <h1>直播课程</h1>
        <p>实时互动教学，与名师面对面交流学习</p>
      </div>
    </div>

    <!-- 正在直播 -->
    <div v-if="liveCourses.length > 0" class="live-now-section">
      <div class="container">
        <h2 class="section-title">
          <el-icon class="live-icon"><VideoCamera /></el-icon>
          正在直播
        </h2>
        <div class="live-courses">
          <div
            v-for="course in liveCourses"
            :key="course.id"
            class="live-course-card"
            @click="joinLive(course.id)"
          >
            <div class="course-image">
              <img :src="course.image" :alt="course.title" />
              <div class="live-badge">
                <span class="live-dot"></span>
                直播中
              </div>
              <div class="viewer-count">
                <el-icon><View /></el-icon>
                {{ course.viewers }}人观看
              </div>
            </div>
            <div class="course-content">
              <h3 class="course-title">{{ course.title }}</h3>
              <div class="course-meta">
                <div class="instructor">
                  <img :src="course.instructorAvatar" :alt="course.instructor" class="instructor-avatar" />
                  <span>{{ course.instructor }}</span>
                </div>
                <div class="live-time">
                  <el-icon><Clock /></el-icon>
                  {{ formatLiveTime(course.startTime) }}
                </div>
              </div>
              <p class="course-description">{{ course.description }}</p>
              <el-button type="primary" size="large" @click.stop="joinLive(course.id)">
                <el-icon><VideoCamera /></el-icon>
                进入直播间
              </el-button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 即将开始 -->
    <div class="upcoming-section">
      <div class="container">
        <h2 class="section-title">
          <el-icon><AlarmClock /></el-icon>
          即将开始
        </h2>
        <div class="upcoming-courses">
          <div
            v-for="course in upcomingCourses"
            :key="course.id"
            class="upcoming-course-card"
          >
            <div class="course-image">
              <img :src="course.image" :alt="course.title" />
              <div class="countdown-badge">
                <countdown :target-time="course.startTime" @finished="handleCountdownFinish" />
              </div>
            </div>
            <div class="course-content">
              <h3 class="course-title">{{ course.title }}</h3>
              <div class="course-meta">
                <div class="instructor">
                  <img :src="course.instructorAvatar" :alt="course.instructor" class="instructor-avatar" />
                  <span>{{ course.instructor }}</span>
                </div>
                <div class="schedule-time">
                  <el-icon><Calendar /></el-icon>
                  {{ formatDateTime(course.startTime) }}
                </div>
              </div>
              <p class="course-description">{{ course.description }}</p>
              <div class="course-actions">
                <el-button
                  :type="course.isReserved ? 'success' : 'primary'"
                  @click="toggleReservation(course.id)"
                  :loading="course.reserving"
                >
                  <el-icon>
                    <Check v-if="course.isReserved" />
                    <Bell v-else />
                  </el-icon>
                  {{ course.isReserved ? '已预约' : '预约提醒' }}
                </el-button>
                <span class="reservation-count">{{ course.reservations }}人已预约</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 直播回放 -->
    <div class="replay-section">
      <div class="container">
        <div class="section-header">
          <h2 class="section-title">
            <el-icon><VideoPlay /></el-icon>
            直播回放
          </h2>
          <div class="filter-controls">
            <el-select v-model="replayFilter" placeholder="选择分类" clearable>
              <el-option label="全部分类" value="" />
              <el-option label="建筑设计基础" value="basic" />
              <el-option label="软件技能" value="software" />
              <el-option label="设计理论" value="theory" />
              <el-option label="实战项目" value="project" />
            </el-select>
            <el-input
              v-model="searchKeyword"
              placeholder="搜索直播回放"
              :prefix-icon="Search"
              style="width: 250px;"
            />
          </div>
        </div>

        <div v-loading="loading" class="replay-courses">
          <div
            v-for="course in filteredReplayCourses"
            :key="course.id"
            class="replay-course-card"
            @click="watchReplay(course.id)"
          >
            <div class="course-image">
              <img :src="course.image" :alt="course.title" />
              <div class="replay-badge">回放</div>
              <div class="duration-badge">{{ course.duration }}</div>
              <div class="play-overlay">
                <el-icon class="play-icon"><VideoPlay /></el-icon>
              </div>
            </div>
            <div class="course-content">
              <h3 class="course-title">{{ course.title }}</h3>
              <div class="course-meta">
                <div class="instructor">
                  <img :src="course.instructorAvatar" :alt="course.instructor" class="instructor-avatar" />
                  <span>{{ course.instructor }}</span>
                </div>
                <div class="live-date">
                  <el-icon><Calendar /></el-icon>
                  {{ formatDate(course.liveDate) }}
                </div>
              </div>
              <p class="course-description">{{ course.description }}</p>
              <div class="course-stats">
                <div class="stat-item">
                  <el-icon><View /></el-icon>
                  <span>{{ course.views }}次观看</span>
                </div>
                <div class="stat-item">
                  <el-icon><Star /></el-icon>
                  <span>{{ course.rating }}分</span>
                </div>
                <div class="stat-item">
                  <el-icon><ChatDotRound /></el-icon>
                  <span>{{ course.comments }}条评论</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 分页 -->
        <div class="pagination-wrapper">
          <el-pagination
            v-model:current-page="currentPage"
            v-model:page-size="pageSize"
            :page-sizes="[12, 24, 36]"
            :total="filteredReplayCourses.length"
            layout="total, sizes, prev, pager, next, jumper"
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
          />
        </div>
      </div>
    </div>

    <!-- 直播日程 -->
    <div class="schedule-section">
      <div class="container">
        <h2 class="section-title">
          <el-icon><Calendar /></el-icon>
          本周直播日程
        </h2>
        <div class="schedule-calendar">
          <div class="calendar-header">
            <div
              v-for="day in weekDays"
              :key="day.date"
              class="day-header"
              :class="{ today: day.isToday }"
            >
              <div class="day-name">{{ day.name }}</div>
              <div class="day-date">{{ day.date }}</div>
            </div>
          </div>
          <div class="calendar-content">
            <div
              v-for="day in weekDays"
              :key="day.date"
              class="day-column"
            >
              <div
                v-for="schedule in day.schedules"
                :key="schedule.id"
                class="schedule-item"
                @click="viewScheduleDetail(schedule.id)"
              >
                <div class="schedule-time">{{ schedule.time }}</div>
                <div class="schedule-title">{{ schedule.title }}</div>
                <div class="schedule-instructor">{{ schedule.instructor }}</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  VideoCamera, View, Clock, AlarmClock, Calendar, VideoPlay,
  Search, Bell, Check, Star, ChatDotRound
} from '@element-plus/icons-vue'

const router = useRouter()

// 响应式数据
const loading = ref(false)
const searchKeyword = ref('')
const replayFilter = ref('')
const currentPage = ref(1)
const pageSize = ref(12)

// 正在直播的课程
const liveCourses = ref([
  {
    id: 1,
    title: 'AutoCAD高级建模技巧实战',
    description: '深入讲解AutoCAD的高级建模功能，通过实际案例演示复杂建筑结构的绘制方法',
    image: 'https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=400&h=300&fit=crop&crop=center',
    instructor: '张建筑师',
    instructorAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
    startTime: new Date(Date.now() - 30 * 60 * 1000), // 30分钟前开始
    viewers: 1247
  }
])

// 即将开始的课程
const upcomingCourses = ref([
  {
    id: 2,
    title: 'Revit BIM协同设计工作流',
    description: '学习Revit在团队协作中的应用，掌握BIM协同设计的完整工作流程',
    image: 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=400&h=300&fit=crop&crop=center',
    instructor: '李工程师',
    instructorAvatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
    startTime: new Date(Date.now() + 2 * 60 * 60 * 1000), // 2小时后开始
    reservations: 856,
    isReserved: false,
    reserving: false
  },
  {
    id: 3,
    title: '建筑设计方案评析',
    description: '分析经典建筑设计案例，探讨设计理念和实现方法',
    image: 'https://images.unsplash.com/photo-1448630360428-65456885c650?w=400&h=300&fit=crop&crop=center',
    instructor: '王教授',
    instructorAvatar: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150&h=150&fit=crop&crop=face',
    startTime: new Date(Date.now() + 24 * 60 * 60 * 1000), // 明天同一时间
    reservations: 1234,
    isReserved: true,
    reserving: false
  }
])

// 直播回放课程
const replayCourses = ref([
  {
    id: 4,
    title: 'SketchUp快速建模技巧',
    description: '掌握SketchUp的高效建模方法，提升建筑设计效率',
    image: 'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=400&h=300&fit=crop&crop=center',
    instructor: '陈设计师',
    instructorAvatar: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150&h=150&fit=crop&crop=face',
    liveDate: '2024-01-15',
    duration: '2小时15分',
    views: 3456,
    rating: 4.8,
    comments: 89,
    category: 'software'
  },
  {
    id: 5,
    title: '现代建筑设计趋势解析',
    description: '分析当前建筑设计的发展趋势和未来方向',
    image: 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=400&h=300&fit=crop&crop=center',
    instructor: '刘教授',
    instructorAvatar: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
    liveDate: '2024-01-12',
    duration: '1小时45分',
    views: 2789,
    rating: 4.6,
    comments: 67,
    category: 'theory'
  },
  {
    id: 6,
    title: '建筑结构设计基础',
    description: '讲解建筑结构设计的基本原理和计算方法',
    image: 'https://images.unsplash.com/photo-1487958449943-2429e8be8625?w=400&h=300&fit=crop&crop=center',
    instructor: '赵工程师',
    instructorAvatar: 'https://images.unsplash.com/photo-1507591064344-4c6ce005b128?w=150&h=150&fit=crop&crop=face',
    liveDate: '2024-01-10',
    duration: '3小时20分',
    views: 4123,
    rating: 4.9,
    comments: 156,
    category: 'theory'
  },
  {
    id: 7,
    title: '住宅项目设计实战',
    description: '通过真实住宅项目案例，学习完整的设计流程',
    image: 'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=400&h=300&fit=crop&crop=center',
    instructor: '孙建筑师',
    instructorAvatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
    liveDate: '2024-01-08',
    duration: '2小时50分',
    views: 1987,
    rating: 4.7,
    comments: 43,
    category: 'project'
  }
])

// 本周日程
const weekDays = ref([])

// 倒计时组件
const Countdown = {
  props: ['targetTime'],
  emits: ['finished'],
  setup(props, { emit }) {
    const timeLeft = ref('')
    
    const updateCountdown = () => {
      const now = new Date().getTime()
      const target = new Date(props.targetTime).getTime()
      const difference = target - now
      
      if (difference > 0) {
        const hours = Math.floor(difference / (1000 * 60 * 60))
        const minutes = Math.floor((difference % (1000 * 60 * 60)) / (1000 * 60))
        const seconds = Math.floor((difference % (1000 * 60)) / 1000)
        
        timeLeft.value = `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
      } else {
        timeLeft.value = '即将开始'
        emit('finished')
      }
    }
    
    onMounted(() => {
      updateCountdown()
      setInterval(updateCountdown, 1000)
    })
    
    return { timeLeft }
  },
  template: '<span>{{ timeLeft }}</span>'
}

// 计算属性
const filteredReplayCourses = computed(() => {
  let result = replayCourses.value
  
  if (searchKeyword.value) {
    result = result.filter(course =>
      course.title.toLowerCase().includes(searchKeyword.value.toLowerCase()) ||
      course.description.toLowerCase().includes(searchKeyword.value.toLowerCase())
    )
  }
  
  if (replayFilter.value) {
    result = result.filter(course => course.category === replayFilter.value)
  }
  
  return result.sort((a, b) => new Date(b.liveDate) - new Date(a.liveDate))
})

// 方法
const generateWeekSchedule = () => {
  const today = new Date()
  const startOfWeek = new Date(today)
  startOfWeek.setDate(today.getDate() - today.getDay())
  
  const days = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
  
  weekDays.value = Array.from({ length: 7 }, (_, i) => {
    const date = new Date(startOfWeek)
    date.setDate(startOfWeek.getDate() + i)
    
    const isToday = date.toDateString() === today.toDateString()
    
    // 模拟每天的直播安排
    const schedules = []
    if (i === 1) { // 周一
      schedules.push({
        id: 101,
        time: '14:00',
        title: 'AutoCAD基础教学',
        instructor: '张老师'
      })
      schedules.push({
        id: 102,
        time: '19:30',
        title: '建筑设计答疑',
        instructor: '李老师'
      })
    } else if (i === 3) { // 周三
      schedules.push({
        id: 103,
        time: '15:00',
        title: 'Revit建模实战',
        instructor: '王老师'
      })
    } else if (i === 5) { // 周五
      schedules.push({
        id: 104,
        time: '20:00',
        title: '设计案例分析',
        instructor: '赵老师'
      })
    }
    
    return {
      name: days[i],
      date: date.getDate(),
      isToday,
      schedules
    }
  })
}

const formatLiveTime = (startTime) => {
  const now = new Date()
  const start = new Date(startTime)
  const diff = Math.floor((now - start) / (1000 * 60))
  
  if (diff < 60) {
    return `直播中 ${diff}分钟`
  } else {
    const hours = Math.floor(diff / 60)
    const minutes = diff % 60
    return `直播中 ${hours}小时${minutes}分钟`
  }
}

const formatDateTime = (dateTime) => {
  const date = new Date(dateTime)
  return date.toLocaleString('zh-CN', {
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const formatDate = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN')
}

const joinLive = (courseId) => {
  const isLoggedIn = localStorage.getItem('isLoggedIn')
  if (!isLoggedIn) {
    ElMessage.warning('请先登录后再进入直播间')
    router.push('/login')
    return
  }
  
  // 获取课程信息
  const course = liveCourses.value.find(c => c.id === courseId)
  const courseTitle = course ? course.title : '直播课程'
  
  ElMessage.success('正在进入直播间...')
  // 跳转到视频播放页面
  router.push({
    path: '/video-player',
    query: {
      title: courseTitle,
      type: 'live',
      from: 'live'
    }
  })
}

const toggleReservation = async (courseId) => {
  const isLoggedIn = localStorage.getItem('isLoggedIn')
  if (!isLoggedIn) {
    ElMessage.warning('请先登录后再预约')
    router.push('/login')
    return
  }
  
  const course = upcomingCourses.value.find(c => c.id === courseId)
  if (!course) return
  
  course.reserving = true
  
  try {
    // 模拟API调用
    await new Promise(resolve => setTimeout(resolve, 1000))
    
    course.isReserved = !course.isReserved
    if (course.isReserved) {
      course.reservations++
      ElMessage.success('预约成功！我们会在开播前提醒您')
    } else {
      course.reservations--
      ElMessage.success('已取消预约')
    }
  } catch (error) {
    ElMessage.error('操作失败，请重试')
  } finally {
    course.reserving = false
  }
}

const watchReplay = (courseId) => {
  // 获取课程信息
  const course = [...liveCourses.value, ...upcomingCourses.value, ...replayCourses.value].find(c => c.id === courseId)
  const courseTitle = course ? course.title : '直播回放'
  
  ElMessage.success('正在加载回放视频...')
  // 跳转到视频播放页面
  router.push({
    path: '/video-player',
    query: {
      title: courseTitle,
      type: 'live-replay',
      from: 'live'
    }
  })
}

const viewScheduleDetail = (scheduleId) => {
  ElMessage.info('查看直播详情')
  // 这里可以显示直播详情弹窗
}

const handleCountdownFinish = () => {
  ElMessage.success('直播即将开始！')
  // 刷新页面数据
}

const handleSizeChange = (val) => {
  pageSize.value = val
  currentPage.value = 1
}

const handleCurrentChange = (val) => {
  currentPage.value = val
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

onMounted(() => {
  generateWeekSchedule()
  loading.value = true
  setTimeout(() => {
    loading.value = false
  }, 500)
})
</script>

<style lang="scss" scoped>
.live-courses-page {
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
  padding: 60px 0;
  text-align: center;
  
  h1 {
    font-size: 2.5rem;
    margin-bottom: 10px;
    font-weight: 600;
  }
  
  p {
    font-size: 1.1rem;
    opacity: 0.9;
  }
}

.section-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 24px;
  font-weight: 600;
  color: #333;
  margin-bottom: 30px;
  
  .live-icon {
    color: #ff4d4f;
    animation: pulse 2s infinite;
  }
  
  .el-icon {
    color: #667eea;
  }
}

@keyframes pulse {
  0% { opacity: 1; }
  50% { opacity: 0.5; }
  100% { opacity: 1; }
}

.live-now-section {
  padding: 40px 0;
  background: white;
  
  .live-courses {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
    gap: 30px;
  }
}

.live-course-card {
  background: white;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 8px 25px rgba(255, 77, 79, 0.15);
  border: 2px solid #ff4d4f;
  cursor: pointer;
  transition: all 0.3s ease;
  
  &:hover {
    transform: translateY(-8px);
    box-shadow: 0 15px 35px rgba(255, 77, 79, 0.25);
  }
  
  .course-image {
    position: relative;
    height: 200px;
    overflow: hidden;
    
    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
    
    .live-badge {
      position: absolute;
      top: 15px;
      left: 15px;
      background: #ff4d4f;
      color: white;
      padding: 6px 12px;
      border-radius: 20px;
      font-size: 14px;
      font-weight: 500;
      display: flex;
      align-items: center;
      gap: 6px;
      
      .live-dot {
        width: 8px;
        height: 8px;
        background: white;
        border-radius: 50%;
        animation: pulse 1.5s infinite;
      }
    }
    
    .viewer-count {
      position: absolute;
      top: 15px;
      right: 15px;
      background: rgba(0, 0, 0, 0.7);
      color: white;
      padding: 6px 10px;
      border-radius: 15px;
      font-size: 12px;
      display: flex;
      align-items: center;
      gap: 4px;
    }
  }
  
  .course-content {
    padding: 25px;
    
    .course-title {
      font-size: 20px;
      font-weight: 600;
      color: #333;
      margin-bottom: 15px;
      line-height: 1.3;
    }
    
    .course-meta {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 15px;
      
      .instructor {
        display: flex;
        align-items: center;
        gap: 8px;
        
        .instructor-avatar {
          width: 32px;
          height: 32px;
          border-radius: 50%;
          object-fit: cover;
        }
        
        span {
          font-weight: 500;
          color: #333;
        }
      }
      
      .live-time {
        display: flex;
        align-items: center;
        gap: 4px;
        color: #666;
        font-size: 14px;
      }
    }
    
    .course-description {
      color: #666;
      line-height: 1.6;
      margin-bottom: 20px;
    }
  }
}

.upcoming-section,
.replay-section {
  padding: 40px 0;
  
  .section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 30px;
    
    .filter-controls {
      display: flex;
      gap: 15px;
      align-items: center;
    }
  }
  
  .upcoming-courses,
  .replay-courses {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
    gap: 24px;
  }
}

.upcoming-course-card,
.replay-course-card {
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
    
    .countdown-badge {
      position: absolute;
      top: 15px;
      right: 15px;
      background: #1890ff;
      color: white;
      padding: 6px 12px;
      border-radius: 6px;
      font-size: 14px;
      font-weight: 500;
      font-family: 'Courier New', monospace;
    }
    
    .replay-badge {
      position: absolute;
      top: 15px;
      left: 15px;
      background: #52c41a;
      color: white;
      padding: 4px 8px;
      border-radius: 4px;
      font-size: 12px;
      font-weight: 500;
    }
    
    .duration-badge {
      position: absolute;
      bottom: 10px;
      right: 10px;
      background: rgba(0, 0, 0, 0.7);
      color: white;
      padding: 4px 8px;
      border-radius: 4px;
      font-size: 12px;
    }
    
    .play-overlay {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: rgba(0, 0, 0, 0.5);
      display: flex;
      align-items: center;
      justify-content: center;
      opacity: 0;
      transition: opacity 0.3s ease;
      
      .play-icon {
        font-size: 48px;
        color: white;
      }
    }
    
    &:hover .play-overlay {
      opacity: 1;
    }
  }
  
  .course-content {
    padding: 20px;
    
    .course-title {
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
    
    .course-meta {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 12px;
      
      .instructor {
        display: flex;
        align-items: center;
        gap: 6px;
        
        .instructor-avatar {
          width: 24px;
          height: 24px;
          border-radius: 50%;
          object-fit: cover;
        }
        
        span {
          font-size: 14px;
          color: #666;
        }
      }
      
      .schedule-time,
      .live-date {
        display: flex;
        align-items: center;
        gap: 4px;
        color: #666;
        font-size: 12px;
      }
    }
    
    .course-description {
      color: #666;
      font-size: 14px;
      line-height: 1.5;
      margin-bottom: 15px;
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }
    
    .course-actions {
      display: flex;
      justify-content: space-between;
      align-items: center;
      
      .reservation-count {
        color: #999;
        font-size: 12px;
      }
    }
    
    .course-stats {
      display: flex;
      gap: 15px;
      
      .stat-item {
        display: flex;
        align-items: center;
        gap: 4px;
        color: #666;
        font-size: 12px;
      }
    }
  }
}

.schedule-section {
  padding: 40px 0;
  background: white;
  
  .schedule-calendar {
    background: #f8f9fa;
    border-radius: 12px;
    overflow: hidden;
    
    .calendar-header {
      display: grid;
      grid-template-columns: repeat(7, 1fr);
      background: #667eea;
      color: white;
      
      .day-header {
        padding: 15px;
        text-align: center;
        border-right: 1px solid rgba(255, 255, 255, 0.2);
        
        &:last-child {
          border-right: none;
        }
        
        &.today {
          background: rgba(255, 255, 255, 0.2);
        }
        
        .day-name {
          font-size: 14px;
          margin-bottom: 5px;
        }
        
        .day-date {
          font-size: 18px;
          font-weight: 600;
        }
      }
    }
    
    .calendar-content {
      display: grid;
      grid-template-columns: repeat(7, 1fr);
      min-height: 200px;
      
      .day-column {
        border-right: 1px solid #e9ecef;
        padding: 10px;
        
        &:last-child {
          border-right: none;
        }
        
        .schedule-item {
          background: white;
          border-radius: 6px;
          padding: 8px;
          margin-bottom: 8px;
          border-left: 3px solid #667eea;
          cursor: pointer;
          transition: all 0.2s ease;
          
          &:hover {
            background: #f0f9ff;
            transform: translateX(2px);
          }
          
          .schedule-time {
            font-size: 12px;
            color: #667eea;
            font-weight: 500;
            margin-bottom: 2px;
          }
          
          .schedule-title {
            font-size: 13px;
            font-weight: 500;
            color: #333;
            margin-bottom: 2px;
            line-height: 1.2;
          }
          
          .schedule-instructor {
            font-size: 11px;
            color: #999;
          }
        }
      }
    }
  }
}

.pagination-wrapper {
  display: flex;
  justify-content: center;
  margin-top: 40px;
}

// 响应式设计
@media (max-width: 768px) {
  .page-header {
    padding: 40px 0;
    
    h1 {
      font-size: 2rem;
    }
  }
  
  .section-header {
    flex-direction: column !important;
    gap: 15px !important;
    align-items: stretch !important;
    
    .filter-controls {
      flex-direction: column !important;
      gap: 10px !important;
    }
  }
  
  .live-courses {
    grid-template-columns: 1fr !important;
  }
  
  .upcoming-courses,
  .replay-courses {
    grid-template-columns: 1fr !important;
  }
  
  .schedule-calendar {
    .calendar-header {
      grid-template-columns: repeat(7, 1fr) !important;
      
      .day-header {
        padding: 10px 5px !important;
        
        .day-name {
          font-size: 12px !important;
        }
        
        .day-date {
          font-size: 14px !important;
        }
      }
    }
    
    .calendar-content {
      grid-template-columns: repeat(7, 1fr) !important;
      
      .day-column {
        padding: 5px !important;
        
        .schedule-item {
          padding: 6px !important;
          
          .schedule-title {
            font-size: 11px !important;
          }
        }
      }
    }
  }
}
</style>