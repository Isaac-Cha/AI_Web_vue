<template>
  <div class="free-courses-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="container">
        <h1>免费课程</h1>
        <p>精选优质免费课程，零成本开启您的建筑设计学习之旅</p>
      </div>
    </div>

    <!-- 课程筛选 -->
    <div class="filter-section">
      <div class="container">
        <div class="filter-bar">
          <div class="filter-group">
            <label>课程分类：</label>
            <el-select v-model="filters.category" placeholder="全部分类" clearable>
              <el-option label="全部分类" value="" />
              <el-option label="建筑设计基础" value="basic" />
              <el-option label="软件技能" value="software" />
              <el-option label="设计理论" value="theory" />
              <el-option label="实战项目" value="project" />
            </el-select>
          </div>
          
          <div class="filter-group">
            <label>难度等级：</label>
            <el-select v-model="filters.level" placeholder="全部等级" clearable>
              <el-option label="全部等级" value="" />
              <el-option label="入门" value="beginner" />
              <el-option label="进阶" value="intermediate" />
              <el-option label="高级" value="advanced" />
            </el-select>
          </div>
          
          <div class="search-group">
            <el-input
              v-model="searchKeyword"
              placeholder="搜索免费课程"
              :prefix-icon="Search"
              @keyup.enter="handleSearch"
            />
            <el-button type="primary" @click="handleSearch">搜索</el-button>
          </div>
        </div>
      </div>
    </div>

    <!-- 推荐免费课程 -->
    <div class="featured-section">
      <div class="container">
        <h2 class="section-title">
          <el-icon><Star /></el-icon>
          推荐免费课程
        </h2>
        <div class="featured-courses">
          <div
            v-for="course in featuredCourses"
            :key="course.id"
            class="featured-course-card"
            @click="goToCourseDetail(course.id)"
          >
            <div class="course-image">
              <img :src="course.image" :alt="course.title" />
              <div class="course-badge">免费</div>
              <div class="course-overlay">
                <el-button type="primary" size="large">
                  <el-icon><VideoPlay /></el-icon>
                  开始学习
                </el-button>
              </div>
            </div>
            <div class="course-content">
              <h3 class="course-title">{{ course.title }}</h3>
              <p class="course-description">{{ course.description }}</p>
              <div class="course-meta">
                <div class="instructor">
                  <el-icon><User /></el-icon>
                  {{ course.instructor }}
                </div>
                <div class="students">
                  <el-icon><View /></el-icon>
                  {{ course.students }}人学习
                </div>
                <div class="rating">
                  <el-rate
                    v-model="course.rating"
                    disabled
                    size="small"
                    show-score
                    text-color="#ff9900"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 免费课程列表 -->
    <div class="courses-section">
      <div class="container">
        <div class="section-header">
          <h2 class="section-title">
            <el-icon><Collection /></el-icon>
            全部免费课程
          </h2>
          <div class="result-info">
            <span>共 {{ filteredCourses.length }} 门免费课程</span>
            <el-select v-model="sortBy" placeholder="排序方式" size="small">
              <el-option label="最新发布" value="latest" />
              <el-option label="最受欢迎" value="popular" />
              <el-option label="评分最高" value="rating" />
            </el-select>
          </div>
        </div>

        <div v-loading="loading" class="courses-grid">
          <div
            v-for="course in paginatedCourses"
            :key="course.id"
            class="course-card"
            @click="goToCourseDetail(course.id)"
          >
            <div class="course-image">
              <img :src="course.image" :alt="course.title" />
              <div class="course-badge">免费</div>
              <div class="course-duration">{{ course.duration }}</div>
            </div>
            
            <div class="course-content">
              <h3 class="course-title">{{ course.title }}</h3>
              <p class="course-description">{{ course.description }}</p>
              
              <div class="course-meta">
                <div class="meta-row">
                  <span class="instructor">{{ course.instructor }}</span>
                  <span class="students">{{ course.students }}人学习</span>
                </div>
                <div class="meta-row">
                  <el-rate
                    v-model="course.rating"
                    disabled
                    size="small"
                    show-score
                    text-color="#ff9900"
                    score-template="{value}"
                  />
                  <span class="lessons">{{ course.lessons }}节课</span>
                </div>
              </div>
              
              <div class="course-footer">
                <div class="course-tags">
                  <el-tag
                    v-for="tag in course.tags.slice(0, 2)"
                    :key="tag"
                    size="small"
                    type="info"
                    effect="plain"
                  >
                    {{ tag }}
                  </el-tag>
                </div>
                <el-button
                  type="primary"
                  size="small"
                  @click.stop="startLearning(course.id)"
                >
                  开始学习
                </el-button>
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
            :total="filteredCourses.length"
            layout="total, sizes, prev, pager, next, jumper"
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
          />
        </div>
      </div>
    </div>

    <!-- 学习路径推荐 -->
    <div class="learning-path-section">
      <div class="container">
        <h2 class="section-title">
          <el-icon><Guide /></el-icon>
          免费学习路径
        </h2>
        <div class="learning-paths">
          <div
            v-for="path in learningPaths"
            :key="path.id"
            class="path-card"
          >
            <div class="path-header">
              <h3>{{ path.title }}</h3>
              <p>{{ path.description }}</p>
            </div>
            <div class="path-courses">
              <div
                v-for="(course, index) in path.courses"
                :key="course.id"
                class="path-course"
                @click="goToCourseDetail(course.id)"
              >
                <div class="course-number">{{ index + 1 }}</div>
                <div class="course-info">
                  <h4>{{ course.title }}</h4>
                  <span class="course-duration">{{ course.duration }}</span>
                </div>
                <el-icon class="arrow-icon"><ArrowRight /></el-icon>
              </div>
            </div>
            <div class="path-footer">
              <span class="path-duration">总时长：{{ path.totalDuration }}</span>
              <el-button type="primary" @click="startLearningPath(path.id)">
                开始学习路径
              </el-button>
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
import { ElMessage } from 'element-plus'
import {
  Search, Star, VideoPlay, User, View, Collection,
  Guide, ArrowRight
} from '@element-plus/icons-vue'

const router = useRouter()

// 响应式数据
const loading = ref(false)
const searchKeyword = ref('')
const sortBy = ref('latest')
const currentPage = ref(1)
const pageSize = ref(12)

const filters = reactive({
  category: '',
  level: ''
})

// 推荐免费课程数据
const featuredCourses = ref([
  {
    id: 3,
    title: '建筑设计原理与方法',
    description: '深入理解建筑设计的基本原理，掌握设计方法和思维',
    image: 'https://images.unsplash.com/photo-1448630360428-65456885c650?w=400&h=300&fit=crop&crop=center',
    instructor: '王教授',
    students: 2156,
    rating: 4.9,
    category: 'theory',
    level: 'intermediate'
  },
  {
    id: 6,
    title: '建筑手绘表现技法',
    description: '学习建筑手绘技巧，提升设计表现能力',
    image: 'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=400&h=300&fit=crop&crop=center',
    instructor: '赵老师',
    students: 1567,
    rating: 4.4,
    category: 'basic',
    level: 'beginner'
  }
])

// 免费课程数据
const freeCourses = ref([
  {
    id: 3,
    title: '建筑设计原理与方法',
    description: '深入理解建筑设计的基本原理，掌握设计方法和思维',
    image: 'https://images.unsplash.com/photo-1448630360428-65456885c650?w=400&h=300&fit=crop&crop=center',
    instructor: '王教授',
    students: 2156,
    rating: 4.9,
    duration: '8小时',
    lessons: 24,
    category: 'theory',
    level: 'intermediate',
    tags: ['设计理论', '建筑原理', '设计方法']
  },
  {
    id: 6,
    title: '建筑手绘表现技法',
    description: '学习建筑手绘技巧，提升设计表现能力',
    image: 'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=400&h=300&fit=crop&crop=center',
    instructor: '赵老师',
    students: 1567,
    rating: 4.4,
    duration: '6小时',
    lessons: 18,
    category: 'basic',
    level: 'beginner',
    tags: ['手绘技法', '表现技巧', '基础技能']
  },
  {
    id: 7,
    title: '建筑摄影入门',
    description: '学习建筑摄影的基本技巧和构图方法',
    image: 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=400&h=300&fit=crop&crop=center',
    instructor: '李摄影师',
    students: 892,
    rating: 4.3,
    duration: '4小时',
    lessons: 12,
    category: 'basic',
    level: 'beginner',
    tags: ['建筑摄影', '构图技巧', '摄影基础']
  },
  {
    id: 8,
    title: '建筑材料认知',
    description: '了解常见建筑材料的特性和应用',
    image: 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=400&h=300&fit=crop&crop=center',
    instructor: '陈工程师',
    students: 1234,
    rating: 4.6,
    duration: '5小时',
    lessons: 15,
    category: 'theory',
    level: 'beginner',
    tags: ['建筑材料', '材料特性', '工程知识']
  },
  {
    id: 9,
    title: '建筑史概论',
    description: '回顾建筑发展历程，了解各时期建筑特色',
    image: 'https://images.unsplash.com/photo-1520637836862-4d197d17c93a?w=400&h=300&fit=crop&crop=center',
    instructor: '张教授',
    students: 1678,
    rating: 4.7,
    duration: '10小时',
    lessons: 30,
    category: 'theory',
    level: 'intermediate',
    tags: ['建筑史', '建筑文化', '历史知识']
  },
  {
    id: 10,
    title: '建筑制图规范',
    description: '掌握建筑制图的基本规范和标准',
    image: 'https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=400&h=300&fit=crop&crop=center',
    instructor: '刘工程师',
    students: 2045,
    rating: 4.8,
    duration: '7小时',
    lessons: 21,
    category: 'basic',
    level: 'beginner',
    tags: ['制图规范', '技术标准', '工程制图']
  }
])

// 学习路径数据
const learningPaths = ref([
  {
    id: 1,
    title: '建筑设计入门路径',
    description: '适合零基础学员，从基础理论到实践应用',
    totalDuration: '25小时',
    courses: [
      { id: 6, title: '建筑手绘表现技法', duration: '6小时' },
      { id: 8, title: '建筑材料认知', duration: '5小时' },
      { id: 10, title: '建筑制图规范', duration: '7小时' },
      { id: 3, title: '建筑设计原理与方法', duration: '8小时' }
    ]
  },
  {
    id: 2,
    title: '建筑理论进阶路径',
    description: '深入学习建筑理论知识，提升设计思维',
    totalDuration: '18小时',
    courses: [
      { id: 9, title: '建筑史概论', duration: '10小时' },
      { id: 3, title: '建筑设计原理与方法', duration: '8小时' }
    ]
  }
])

// 计算属性
const filteredCourses = computed(() => {
  let result = freeCourses.value

  // 关键词搜索
  if (searchKeyword.value) {
    result = result.filter(course =>
      course.title.toLowerCase().includes(searchKeyword.value.toLowerCase()) ||
      course.description.toLowerCase().includes(searchKeyword.value.toLowerCase()) ||
      course.tags.some(tag => tag.toLowerCase().includes(searchKeyword.value.toLowerCase()))
    )
  }

  // 分类筛选
  if (filters.category) {
    result = result.filter(course => course.category === filters.category)
  }

  // 难度筛选
  if (filters.level) {
    result = result.filter(course => course.level === filters.level)
  }

  // 排序
  switch (sortBy.value) {
    case 'popular':
      result.sort((a, b) => b.students - a.students)
      break
    case 'rating':
      result.sort((a, b) => b.rating - a.rating)
      break
    default: // latest
      result.sort((a, b) => b.id - a.id)
  }

  return result
})

const paginatedCourses = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  const end = start + pageSize.value
  return filteredCourses.value.slice(start, end)
})

// 方法
const handleSearch = () => {
  currentPage.value = 1
}

const handleSizeChange = (val) => {
  pageSize.value = val
  currentPage.value = 1
}

const handleCurrentChange = (val) => {
  currentPage.value = val
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

const goToCourseDetail = (courseId) => {
  router.push(`/course/${courseId}`)
}

const startLearning = (courseId) => {
  const isLoggedIn = localStorage.getItem('isLoggedIn')
  if (!isLoggedIn) {
    ElMessage.warning('请先登录后再开始学习')
    router.push('/login')
    return
  }
  
  // 获取课程信息
  const course = [...featuredCourses.value, ...freeCourses.value].find(c => c.id === courseId)
  const courseTitle = course ? course.title : '免费课程学习'
  
  ElMessage.success('开始学习免费课程')
  // 跳转到视频播放页面
  router.push({
    path: '/video-player',
    query: {
      title: courseTitle,
      type: 'free-course',
      from: 'free'
    }
  })
}

const startLearningPath = (pathId) => {
  const isLoggedIn = localStorage.getItem('isLoggedIn')
  if (!isLoggedIn) {
    ElMessage.warning('请先登录后再开始学习路径')
    router.push('/login')
    return
  }
  
  const path = learningPaths.value.find(p => p.id === pathId)
  if (path && path.courses.length > 0) {
    ElMessage.success(`开始学习路径：${path.title}`)
    // 跳转到视频播放页面
    router.push({
      path: '/video-player',
      query: {
        title: path.title,
        type: 'learning-path',
        from: 'free'
      }
    })
  }
}

onMounted(() => {
  loading.value = true
  setTimeout(() => {
    loading.value = false
  }, 500)
})
</script>

<style lang="scss" scoped>
.free-courses-page {
  min-height: 100vh;
  background: #f8f9fa;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

.page-header {
  background: linear-gradient(135deg, #52c41a 0%, #73d13d 100%);
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

.filter-section {
  background: white;
  padding: 20px 0;
  border-bottom: 1px solid #e9ecef;
  
  .filter-bar {
    display: flex;
    align-items: center;
    gap: 20px;
    flex-wrap: wrap;
    
    .filter-group {
      display: flex;
      align-items: center;
      gap: 8px;
      
      label {
        font-weight: 500;
        color: #333;
        white-space: nowrap;
      }
      
      .el-select {
        width: 140px;
      }
    }
    
    .search-group {
      display: flex;
      gap: 10px;
      margin-left: auto;
      
      .el-input {
        width: 250px;
      }
    }
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
  
  .el-icon {
    color: #52c41a;
  }
}

.featured-section {
  padding: 40px 0;
  background: white;
  
  .featured-courses {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
    gap: 30px;
  }
}

.featured-course-card {
  background: white;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  cursor: pointer;
  
  &:hover {
    transform: translateY(-8px);
    box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15);
  }
  
  .course-image {
    position: relative;
    height: 220px;
    overflow: hidden;
    
    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      transition: transform 0.3s ease;
    }
    
    &:hover img {
      transform: scale(1.1);
    }
    
    .course-badge {
      position: absolute;
      top: 15px;
      right: 15px;
      background: #52c41a;
      color: white;
      padding: 6px 12px;
      border-radius: 20px;
      font-size: 14px;
      font-weight: 500;
    }
    
    .course-overlay {
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
    }
    
    &:hover .course-overlay {
      opacity: 1;
    }
  }
  
  .course-content {
    padding: 25px;
    
    .course-title {
      font-size: 20px;
      font-weight: 600;
      color: #333;
      margin-bottom: 10px;
      line-height: 1.3;
    }
    
    .course-description {
      color: #666;
      line-height: 1.6;
      margin-bottom: 20px;
    }
    
    .course-meta {
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: 15px;
      
      .instructor,
      .students {
        display: flex;
        align-items: center;
        gap: 5px;
        color: #666;
        font-size: 14px;
      }
      
      .rating {
        .el-rate {
          height: 16px;
        }
      }
    }
  }
}

.courses-section {
  padding: 40px 0;
  
  .section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 30px;
    
    .result-info {
      display: flex;
      align-items: center;
      gap: 15px;
      
      span {
        color: #666;
        font-size: 14px;
      }
      
      .el-select {
        width: 150px;
      }
    }
  }
  
  .courses-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 24px;
    margin-bottom: 40px;
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
    height: 160px;
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
      top: 10px;
      right: 10px;
      background: #52c41a;
      color: white;
      padding: 4px 8px;
      border-radius: 4px;
      font-size: 12px;
      font-weight: 500;
    }
    
    .course-duration {
      position: absolute;
      bottom: 10px;
      left: 10px;
      background: rgba(0, 0, 0, 0.7);
      color: white;
      padding: 4px 8px;
      border-radius: 4px;
      font-size: 12px;
    }
  }
  
  .course-content {
    padding: 18px;
    
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
    
    .course-meta {
      margin-bottom: 15px;
      
      .meta-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 8px;
        
        &:last-child {
          margin-bottom: 0;
        }
        
        .instructor,
        .students,
        .lessons {
          color: #666;
          font-size: 12px;
        }
        
        .el-rate {
          height: 14px;
        }
      }
    }
    
    .course-footer {
      display: flex;
      justify-content: space-between;
      align-items: center;
      
      .course-tags {
        display: flex;
        gap: 5px;
        flex: 1;
        
        .el-tag {
          font-size: 11px;
        }
      }
    }
  }
}

.learning-path-section {
  padding: 40px 0;
  background: white;
  
  .learning-paths {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
    gap: 30px;
  }
}

.path-card {
  background: #f8f9fa;
  border-radius: 12px;
  padding: 25px;
  border: 2px solid #e9ecef;
  transition: all 0.3s ease;
  
  &:hover {
    border-color: #52c41a;
    box-shadow: 0 4px 15px rgba(82, 196, 26, 0.1);
  }
  
  .path-header {
    margin-bottom: 20px;
    
    h3 {
      font-size: 18px;
      font-weight: 600;
      color: #333;
      margin-bottom: 8px;
    }
    
    p {
      color: #666;
      line-height: 1.5;
    }
  }
  
  .path-courses {
    margin-bottom: 20px;
    
    .path-course {
      display: flex;
      align-items: center;
      gap: 15px;
      padding: 12px;
      background: white;
      border-radius: 8px;
      margin-bottom: 10px;
      cursor: pointer;
      transition: all 0.2s ease;
      
      &:hover {
        background: #f0f9ff;
        transform: translateX(5px);
      }
      
      &:last-child {
        margin-bottom: 0;
      }
      
      .course-number {
        width: 24px;
        height: 24px;
        background: #52c41a;
        color: white;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 12px;
        font-weight: 600;
        flex-shrink: 0;
      }
      
      .course-info {
        flex: 1;
        
        h4 {
          font-size: 14px;
          font-weight: 500;
          color: #333;
          margin-bottom: 2px;
        }
        
        .course-duration {
          font-size: 12px;
          color: #999;
        }
      }
      
      .arrow-icon {
        color: #52c41a;
        font-size: 16px;
      }
    }
  }
  
  .path-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    
    .path-duration {
      color: #666;
      font-size: 14px;
      font-weight: 500;
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
  .filter-bar {
    flex-direction: column;
    align-items: stretch !important;
    gap: 15px !important;
    
    .filter-group {
      justify-content: space-between;
      
      .el-select {
        width: 200px !important;
      }
    }
    
    .search-group {
      margin-left: 0 !important;
      
      .el-input {
        width: 100% !important;
      }
    }
  }
  
  .section-header {
    flex-direction: column !important;
    gap: 15px !important;
    align-items: stretch !important;
  }
  
  .featured-courses {
    grid-template-columns: 1fr !important;
  }
  
  .courses-grid {
    grid-template-columns: 1fr !important;
  }
  
  .learning-paths {
    grid-template-columns: 1fr !important;
  }
  
  .page-header {
    padding: 40px 0;
    
    h1 {
      font-size: 2rem;
    }
  }
  
  .featured-course-card {
    .course-meta {
      flex-direction: column !important;
      gap: 10px !important;
      align-items: flex-start !important;
    }
  }
}
</style>