<template>
  <div class="courses-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="container">
        <h1>课程中心</h1>
        <p>专业的建筑设计课程，助您成为建筑设计专家</p>
      </div>
    </div>

    <!-- 筛选区域 -->
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
          
          <div class="filter-group">
            <label>价格范围：</label>
            <el-select v-model="filters.price" placeholder="全部价格" clearable>
              <el-option label="全部价格" value="" />
              <el-option label="免费" value="free" />
              <el-option label="0-100元" value="0-100" />
              <el-option label="100-500元" value="100-500" />
              <el-option label="500元以上" value="500+" />
            </el-select>
          </div>
          
          <div class="search-group">
            <el-input
              v-model="searchKeyword"
              placeholder="搜索课程名称或关键词"
              :prefix-icon="Search"
              @keyup.enter="handleSearch"
            />
            <el-button type="primary" @click="handleSearch">搜索</el-button>
          </div>
        </div>
      </div>
    </div>

    <!-- 课程列表 -->
    <div class="courses-section">
      <div class="container">
        <div class="courses-header">
          <div class="result-info">
            <span>共找到 {{ filteredCourses.length }} 门课程</span>
          </div>
          <div class="sort-options">
            <el-select v-model="sortBy" placeholder="排序方式">
              <el-option label="最新发布" value="latest" />
              <el-option label="最受欢迎" value="popular" />
              <el-option label="价格从低到高" value="price-asc" />
              <el-option label="价格从高到低" value="price-desc" />
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
              <div class="course-badge" v-if="course.isFree">免费</div>
              <div class="course-badge hot" v-if="course.isHot">热门</div>
            </div>
            
            <div class="course-content">
              <h3 class="course-title">{{ course.title }}</h3>
              <p class="course-description">{{ course.description }}</p>
              
              <div class="course-meta">
                <div class="course-info">
                  <span class="instructor">{{ course.instructor }}</span>
                  <span class="students">{{ course.students }}人学习</span>
                </div>
                <div class="course-rating">
                  <el-rate
                    v-model="course.rating"
                    disabled
                    show-score
                    text-color="#ff9900"
                    score-template="{value}"
                  />
                </div>
              </div>
              
              <div class="course-footer">
                <div class="course-price">
                  <span v-if="course.isFree" class="free-price">免费</span>
                  <template v-else>
                    <span class="current-price">¥{{ course.price }}</span>
                    <span v-if="course.originalPrice" class="original-price">¥{{ course.originalPrice }}</span>
                  </template>
                </div>
                <div class="course-actions">
                  <el-button
                    v-if="course.isFree"
                    type="primary"
                    size="small"
                    @click.stop="startLearning(course.id)"
                  >
                    开始学习
                  </el-button>
                  <el-button
                    v-else
                    type="primary"
                    size="small"
                    @click.stop="addToCart(course.id)"
                  >
                    加入购物车
                  </el-button>
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
            :page-sizes="[12, 24, 36, 48]"
            :total="filteredCourses.length"
            layout="total, sizes, prev, pager, next, jumper"
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Search } from '@element-plus/icons-vue'

const router = useRouter()

// 响应式数据
const loading = ref(false)
const searchKeyword = ref('')
const sortBy = ref('latest')
const currentPage = ref(1)
const pageSize = ref(12)

const filters = reactive({
  category: '',
  level: '',
  price: ''
})

// 模拟课程数据
const courses = ref([
  {
    id: 1,
    title: 'AutoCAD建筑制图基础',
    description: '从零开始学习AutoCAD，掌握建筑制图的基本技能和规范',
    image: 'https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=400&h=300&fit=crop&crop=center',
    instructor: '张建筑',
    students: 1234,
    rating: 4.8,
    price: 299,
    originalPrice: 399,
    category: 'software',
    level: 'beginner',
    isFree: false,
    isHot: true
  },
  {
    id: 2,
    title: 'SketchUp建筑建模入门',
    description: '学习SketchUp软件，快速创建建筑三维模型',
    image: 'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=400&h=300&fit=crop&crop=center',
    instructor: '李设计',
    students: 856,
    rating: 4.6,
    price: 199,
    originalPrice: null,
    category: 'software',
    level: 'beginner',
    isFree: false,
    isHot: false
  },
  {
    id: 3,
    title: '建筑设计原理与方法',
    description: '深入理解建筑设计的基本原理，掌握设计方法和思维',
    image: 'https://images.unsplash.com/photo-1448630360428-65456885c650?w=400&h=300&fit=crop&crop=center',
    instructor: '王教授',
    students: 2156,
    rating: 4.9,
    price: 0,
    originalPrice: null,
    category: 'theory',
    level: 'intermediate',
    isFree: true,
    isHot: true
  },
  {
    id: 4,
    title: 'Revit BIM建筑信息建模',
    description: '学习Revit软件，掌握BIM建筑信息建模技术',
    image: 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=400&h=300&fit=crop&crop=center',
    instructor: '陈工程师',
    students: 967,
    rating: 4.7,
    price: 599,
    originalPrice: 799,
    category: 'software',
    level: 'advanced',
    isFree: false,
    isHot: false
  },
  {
    id: 5,
    title: '住宅建筑设计实战',
    description: '通过实际项目案例，学习住宅建筑的设计流程和要点',
    image: 'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=400&h=300&fit=crop&crop=center',
    instructor: '刘建筑师',
    students: 743,
    rating: 4.5,
    price: 899,
    originalPrice: 1199,
    category: 'project',
    level: 'advanced',
    isFree: false,
    isHot: false
  },
  {
    id: 6,
    title: '建筑手绘表现技法',
    description: '学习建筑手绘技巧，提升设计表现能力',
    image: 'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=400&h=300&fit=crop&crop=center',
    instructor: '赵老师',
    students: 1567,
    rating: 4.4,
    price: 0,
    originalPrice: null,
    category: 'basic',
    level: 'beginner',
    isFree: true,
    isHot: false
  }
])

// 计算属性
const filteredCourses = computed(() => {
  let result = courses.value

  // 关键词搜索
  if (searchKeyword.value) {
    result = result.filter(course =>
      course.title.toLowerCase().includes(searchKeyword.value.toLowerCase()) ||
      course.description.toLowerCase().includes(searchKeyword.value.toLowerCase())
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

  // 价格筛选
  if (filters.price) {
    switch (filters.price) {
      case 'free':
        result = result.filter(course => course.isFree)
        break
      case '0-100':
        result = result.filter(course => !course.isFree && course.price <= 100)
        break
      case '100-500':
        result = result.filter(course => !course.isFree && course.price > 100 && course.price <= 500)
        break
      case '500+':
        result = result.filter(course => !course.isFree && course.price > 500)
        break
    }
  }

  // 排序
  switch (sortBy.value) {
    case 'popular':
      result.sort((a, b) => b.students - a.students)
      break
    case 'price-asc':
      result.sort((a, b) => a.price - b.price)
      break
    case 'price-desc':
      result.sort((a, b) => b.price - a.price)
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
  // 滚动到顶部
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

const goToCourseDetail = (courseId) => {
  router.push(`/course/${courseId}`)
}

const startLearning = (courseId) => {
  // 检查登录状态
  const isLoggedIn = localStorage.getItem('isLoggedIn')
  if (!isLoggedIn) {
    ElMessage.warning('请先登录后再开始学习')
    router.push('/login')
    return
  }
  
  // 获取课程信息
  const course = filteredCourses.value.find(c => c.id === courseId)
  const courseTitle = course ? course.title : '课程学习'
  
  ElMessage.success('开始学习课程')
  // 跳转到视频播放页面
  router.push({
    path: '/video-player',
    query: {
      title: courseTitle,
      type: 'course',
      from: 'courses'
    }
  })
}

const addToCart = (courseId) => {
  // 检查登录状态
  const isLoggedIn = localStorage.getItem('isLoggedIn')
  if (!isLoggedIn) {
    ElMessage.warning('请先登录后再添加到购物车')
    router.push('/login')
    return
  }
  
  // 模拟添加到购物车
  ElMessage.success('已添加到购物车')
}

onMounted(() => {
  // 页面加载时的初始化操作
  loading.value = true
  setTimeout(() => {
    loading.value = false
  }, 500)
})
</script>

<style lang="scss" scoped>
.courses-page {
  min-height: 100vh;
  background: #f8f9fa;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

.page-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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

.courses-section {
  padding: 30px 0;
  
  .courses-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 30px;
    
    .result-info {
      color: #666;
      font-size: 14px;
    }
    
    .sort-options {
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
      right: 12px;
      background: #52c41a;
      color: white;
      padding: 4px 8px;
      border-radius: 4px;
      font-size: 12px;
      font-weight: 500;
      
      &.hot {
        background: #ff4d4f;
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
    
    .course-description {
      color: #666;
      font-size: 14px;
      line-height: 1.5;
      margin-bottom: 16px;
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }
    
    .course-meta {
      margin-bottom: 16px;
      
      .course-info {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 8px;
        
        .instructor {
          color: #333;
          font-size: 14px;
          font-weight: 500;
        }
        
        .students {
          color: #999;
          font-size: 12px;
        }
      }
      
      .course-rating {
        .el-rate {
          height: 16px;
        }
      }
    }
    
    .course-footer {
      display: flex;
      justify-content: space-between;
      align-items: center;
      
      .course-price {
        .free-price {
          color: #52c41a;
          font-weight: 600;
          font-size: 16px;
        }
        
        .current-price {
          color: #ff4d4f;
          font-weight: 600;
          font-size: 18px;
        }
        
        .original-price {
          color: #999;
          font-size: 14px;
          text-decoration: line-through;
          margin-left: 8px;
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
  
  .courses-header {
    flex-direction: column;
    gap: 15px;
    align-items: stretch !important;
  }
  
  .courses-grid {
    grid-template-columns: 1fr !important;
  }
  
  .page-header {
    padding: 40px 0;
    
    h1 {
      font-size: 2rem;
    }
  }
}
</style>