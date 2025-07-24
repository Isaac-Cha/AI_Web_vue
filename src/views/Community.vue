<template>
  <div class="community-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="container">
        <h1>学习社区</h1>
        <p>与同行交流学习心得，分享设计作品，共同成长</p>
      </div>
    </div>

    <!-- 社区导航 -->
    <div class="community-nav">
      <div class="container">
        <div class="nav-tabs">
          <div
            v-for="tab in navTabs"
            :key="tab.key"
            class="nav-tab"
            :class="{ active: activeTab === tab.key }"
            @click="switchTab(tab.key)"
          >
            <el-icon>
              <component :is="tab.icon" />
            </el-icon>
            <span>{{ tab.label }}</span>
            <el-badge v-if="tab.count" :value="tab.count" class="tab-badge" />
          </div>
        </div>
        
        <div class="nav-actions">
          <el-button type="primary" @click="showPostDialog = true">
            <el-icon><EditPen /></el-icon>
            发布动态
          </el-button>
        </div>
      </div>
    </div>

    <!-- 社区内容 -->
    <div class="community-content">
      <div class="container">
        <div class="content-layout">
          <!-- 主要内容区域 -->
          <div class="main-content">
            <!-- 热门话题 -->
            <div v-if="activeTab === 'all'" class="hot-topics-section">
              <h3 class="section-title">
                <el-icon><Promotion /></el-icon>
                热门话题
              </h3>
              <div class="hot-topics">
                <div
                  v-for="topic in hotTopics"
                  :key="topic.id"
                  class="topic-tag"
                  @click="filterByTopic(topic.name)"
                >
                  #{{ topic.name }}
                  <span class="topic-count">{{ topic.count }}</span>
                </div>
              </div>
            </div>

            <!-- 筛选和排序 -->
            <div class="filter-section">
              <div class="filter-left">
                <el-select v-model="sortBy" placeholder="排序方式" size="small">
                  <el-option label="最新发布" value="latest" />
                  <el-option label="最多点赞" value="likes" />
                  <el-option label="最多评论" value="comments" />
                  <el-option label="最多浏览" value="views" />
                </el-select>
                
                <el-select v-model="categoryFilter" placeholder="分类筛选" size="small" clearable>
                  <el-option label="全部分类" value="" />
                  <el-option label="作品展示" value="showcase" />
                  <el-option label="学习心得" value="experience" />
                  <el-option label="技术讨论" value="tech" />
                  <el-option label="求助问答" value="help" />
                </el-select>
              </div>
              
              <div class="filter-right">
                <el-input
                  v-model="searchKeyword"
                  placeholder="搜索社区内容"
                  :prefix-icon="Search"
                  size="small"
                  style="width: 250px;"
                  @keyup.enter="handleSearch"
                />
              </div>
            </div>

            <!-- 动态列表 -->
            <div v-loading="loading" class="posts-list">
              <div
                v-for="post in filteredPosts"
                :key="post.id"
                class="post-card"
                @click="viewPost(post.id)"
              >
                <div class="post-header">
                  <div class="user-info">
                    <img :src="post.userAvatar" :alt="post.username" class="user-avatar" />
                    <div class="user-details">
                      <span class="username">{{ post.username }}</span>
                      <span class="user-title">{{ post.userTitle }}</span>
                    </div>
                  </div>
                  <div class="post-meta">
                    <span class="post-time">{{ formatTime(post.createTime) }}</span>
                    <el-tag :type="getCategoryType(post.category)" size="small">
                      {{ getCategoryLabel(post.category) }}
                    </el-tag>
                  </div>
                </div>

                <div class="post-content">
                  <h3 class="post-title">{{ post.title }}</h3>
                  <p class="post-excerpt">{{ post.excerpt }}</p>
                  
                  <!-- 图片展示 -->
                  <div v-if="post.images && post.images.length > 0" class="post-images">
                    <div
                      v-for="(image, index) in post.images.slice(0, 3)"
                      :key="index"
                      class="image-item"
                      @click.stop="previewImage(post.images, index)"
                    >
                      <img :src="image" :alt="`图片${index + 1}`" />
                      <div v-if="index === 2 && post.images.length > 3" class="more-images">
                        +{{ post.images.length - 3 }}
                      </div>
                    </div>
                  </div>
                  
                  <!-- 话题标签 -->
                  <div v-if="post.topics && post.topics.length > 0" class="post-topics">
                    <span
                      v-for="topic in post.topics"
                      :key="topic"
                      class="topic-tag small"
                      @click.stop="filterByTopic(topic)"
                    >
                      #{{ topic }}
                    </span>
                  </div>
                </div>

                <div class="post-footer">
                  <div class="post-stats">
                    <div class="stat-item" @click.stop="toggleLike(post.id)">
                      <el-icon :class="{ liked: post.isLiked }">
                        <component :is="post.isLiked ? 'StarFilled' : 'Star'" />
                      </el-icon>
                      <span>{{ post.likes }}</span>
                    </div>
                    <div class="stat-item" @click.stop="viewPost(post.id)">
                      <el-icon><ChatDotRound /></el-icon>
                      <span>{{ post.comments }}</span>
                    </div>
                    <div class="stat-item">
                      <el-icon><View /></el-icon>
                      <span>{{ post.views }}</span>
                    </div>
                    <div class="stat-item" @click.stop="sharePost(post.id)">
                      <el-icon><Share /></el-icon>
                      <span>分享</span>
                    </div>
                  </div>
                  
                  <div class="post-actions">
                    <el-button
                      size="small"
                      @click.stop="toggleCollect(post.id)"
                      :type="post.isCollected ? 'primary' : 'default'"
                    >
                      <el-icon>
                        <component :is="post.isCollected ? 'StarFilled' : 'Star'" />
                      </el-icon>
                      {{ post.isCollected ? '已收藏' : '收藏' }}
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
                :page-sizes="[10, 20, 30]"
                :total="filteredPosts.length"
                layout="total, sizes, prev, pager, next, jumper"
                @size-change="handleSizeChange"
                @current-change="handleCurrentChange"
              />
            </div>
          </div>

          <!-- 侧边栏 -->
          <div class="sidebar">
            <!-- 用户信息卡片 -->
            <div class="user-card">
              <div v-if="isLoggedIn" class="logged-user">
                <img :src="currentUser.avatar" :alt="currentUser.name" class="user-avatar" />
                <div class="user-info">
                  <h4>{{ currentUser.name }}</h4>
                  <p>{{ currentUser.title }}</p>
                </div>
                <div class="user-stats">
                  <div class="stat">
                    <span class="number">{{ currentUser.posts }}</span>
                    <span class="label">动态</span>
                  </div>
                  <div class="stat">
                    <span class="number">{{ currentUser.followers }}</span>
                    <span class="label">粉丝</span>
                  </div>
                  <div class="stat">
                    <span class="number">{{ currentUser.following }}</span>
                    <span class="label">关注</span>
                  </div>
                </div>
              </div>
              <div v-else class="guest-user">
                <p>登录后可参与社区互动</p>
                <el-button type="primary" @click="goToLogin">立即登录</el-button>
              </div>
            </div>

            <!-- 活跃用户 -->
            <div class="active-users">
              <h3>活跃用户</h3>
              <div class="user-list">
                <div
                  v-for="user in activeUsers"
                  :key="user.id"
                  class="user-item"
                  @click="viewUserProfile(user.id)"
                >
                  <img :src="user.avatar" :alt="user.name" class="user-avatar" />
                  <div class="user-info">
                    <span class="username">{{ user.name }}</span>
                    <span class="user-title">{{ user.title }}</span>
                  </div>
                  <el-button
                    size="small"
                    :type="user.isFollowing ? 'default' : 'primary'"
                    @click.stop="toggleFollow(user.id)"
                  >
                    {{ user.isFollowing ? '已关注' : '关注' }}
                  </el-button>
                </div>
              </div>
            </div>

            <!-- 推荐话题 -->
            <div class="recommended-topics">
              <h3>推荐话题</h3>
              <div class="topic-list">
                <div
                  v-for="topic in recommendedTopics"
                  :key="topic.id"
                  class="topic-item"
                  @click="filterByTopic(topic.name)"
                >
                  <span class="topic-name">#{{ topic.name }}</span>
                  <span class="topic-count">{{ topic.count }}条动态</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 发布动态对话框 -->
    <el-dialog
      v-model="showPostDialog"
      title="发布动态"
      width="600px"
      :before-close="handleClosePostDialog"
    >
      <div class="post-form">
        <el-form :model="postForm" label-width="80px">
          <el-form-item label="分类">
            <el-select v-model="postForm.category" placeholder="选择分类">
              <el-option label="作品展示" value="showcase" />
              <el-option label="学习心得" value="experience" />
              <el-option label="技术讨论" value="tech" />
              <el-option label="求助问答" value="help" />
            </el-select>
          </el-form-item>
          
          <el-form-item label="标题">
            <el-input v-model="postForm.title" placeholder="请输入标题" maxlength="50" show-word-limit />
          </el-form-item>
          
          <el-form-item label="内容">
            <el-input
              v-model="postForm.content"
              type="textarea"
              :rows="6"
              placeholder="分享你的想法..."
              maxlength="1000"
              show-word-limit
            />
          </el-form-item>
          
          <el-form-item label="话题">
            <el-input
              v-model="postForm.topics"
              placeholder="添加话题，用空格分隔，如：AutoCAD 建筑设计"
            />
          </el-form-item>
          
          <el-form-item label="图片">
            <el-upload
              v-model:file-list="postForm.images"
              action="#"
              list-type="picture-card"
              :auto-upload="false"
              :limit="9"
              accept="image/*"
            >
              <el-icon><Plus /></el-icon>
            </el-upload>
          </el-form-item>
        </el-form>
      </div>
      
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showPostDialog = false">取消</el-button>
          <el-button type="primary" @click="submitPost" :loading="submitting">
            发布
          </el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElImageViewer } from 'element-plus'
import {
  EditPen, Search, Promotion, Star, ChatDotRound,
  View, Share, StarFilled, Plus, Collection, TrendCharts,
  User, QuestionFilled
} from '@element-plus/icons-vue'

const router = useRouter()

// 响应式数据
const loading = ref(false)
const submitting = ref(false)
const showPostDialog = ref(false)
const activeTab = ref('all')
const searchKeyword = ref('')
const sortBy = ref('latest')
const categoryFilter = ref('')
const currentPage = ref(1)
const pageSize = ref(10)

// 导航标签
const navTabs = ref([
  { key: 'all', label: '全部', icon: 'Collection', count: null },
  { key: 'following', label: '关注', icon: 'User', count: 12 },
  { key: 'trending', label: '热门', icon: 'TrendCharts', count: null },
  { key: 'help', label: '求助', icon: 'QuestionFilled', count: 5 }
])

// 当前用户信息
const isLoggedIn = computed(() => localStorage.getItem('isLoggedIn'))
const currentUser = ref({
  name: '建筑设计师',
  title: '高级建筑师',
  avatar: '/avatars/current-user.jpg',
  posts: 23,
  followers: 156,
  following: 89
})

// 发布表单
const postForm = reactive({
  category: '',
  title: '',
  content: '',
  topics: '',
  images: []
})

// 热门话题
const hotTopics = ref([
  { id: 1, name: 'AutoCAD技巧', count: 234 },
  { id: 2, name: '建筑设计', count: 189 },
  { id: 3, name: 'Revit建模', count: 156 },
  { id: 4, name: '作品分享', count: 145 },
  { id: 5, name: '学习心得', count: 123 }
])

// 推荐话题
const recommendedTopics = ref([
  { id: 1, name: 'SketchUp技巧', count: 89 },
  { id: 2, name: '建筑摄影', count: 67 },
  { id: 3, name: '设计理论', count: 54 },
  { id: 4, name: '软件学习', count: 43 }
])

// 活跃用户
const activeUsers = ref([
  {
    id: 1,
    name: '张建筑师',
    title: '资深建筑师',
    avatar: '/avatars/user-1.jpg',
    isFollowing: false
  },
  {
    id: 2,
    name: '李设计师',
    title: '室内设计师',
    avatar: '/avatars/user-2.jpg',
    isFollowing: true
  },
  {
    id: 3,
    name: '王工程师',
    title: '结构工程师',
    avatar: '/avatars/user-3.jpg',
    isFollowing: false
  }
])

// 社区动态数据
const posts = ref([
  {
    id: 1,
    username: '建筑新手小白',
    userTitle: '建筑学学生',
    userAvatar: '/avatars/user-1.jpg',
    title: '分享我的第一个AutoCAD作品 - 小户型住宅设计',
    excerpt: '经过一个月的学习，终于完成了我的第一个完整的建筑设计作品。这是一个60平米的小户型住宅设计，虽然还有很多不足，但对于初学者来说已经很满意了...',
    content: '完整内容...',
    category: 'showcase',
    topics: ['AutoCAD', '住宅设计', '新手作品'],
    images: [
      '/posts/post-1-1.jpg',
      '/posts/post-1-2.jpg',
      '/posts/post-1-3.jpg'
    ],
    createTime: '2024-01-20 14:30:00',
    likes: 45,
    comments: 12,
    views: 234,
    isLiked: false,
    isCollected: false
  },
  {
    id: 2,
    username: '资深设计师老王',
    userTitle: '高级建筑师',
    userAvatar: '/avatars/user-2.jpg',
    title: 'Revit建模技巧分享：如何快速创建复杂的建筑结构',
    excerpt: '在使用Revit进行建筑建模时，经常会遇到一些复杂的结构需要处理。今天分享几个实用的技巧，可以大大提高建模效率...',
    content: '完整内容...',
    category: 'tech',
    topics: ['Revit', '建模技巧', '效率提升'],
    images: [
      '/posts/post-2-1.jpg',
      '/posts/post-2-2.jpg'
    ],
    createTime: '2024-01-20 10:15:00',
    likes: 128,
    comments: 34,
    views: 567,
    isLiked: true,
    isCollected: true
  },
  {
    id: 3,
    username: '建筑学研究生',
    userTitle: '建筑学硕士',
    userAvatar: '/avatars/user-3.jpg',
    title: '求助：关于建筑制图规范的几个问题',
    excerpt: '最近在学习建筑制图规范，遇到了几个问题想请教大家。主要是关于标注和图层管理方面的...',
    content: '完整内容...',
    category: 'help',
    topics: ['制图规范', '求助', '标注'],
    images: [],
    createTime: '2024-01-19 16:45:00',
    likes: 23,
    comments: 18,
    views: 156,
    isLiked: false,
    isCollected: false
  },
  {
    id: 4,
    username: '设计工作室',
    userTitle: '建筑设计工作室',
    userAvatar: '/avatars/studio-1.jpg',
    title: '现代简约风格别墅设计案例分析',
    excerpt: '这是我们工作室最近完成的一个现代简约风格别墅项目。整个设计注重空间的流动性和自然光的运用...',
    content: '完整内容...',
    category: 'showcase',
    topics: ['别墅设计', '现代简约', '案例分析'],
    images: [
      '/posts/post-4-1.jpg',
      '/posts/post-4-2.jpg',
      '/posts/post-4-3.jpg',
      '/posts/post-4-4.jpg'
    ],
    createTime: '2024-01-19 09:20:00',
    likes: 89,
    comments: 25,
    views: 445,
    isLiked: false,
    isCollected: true
  }
])

// 计算属性
const filteredPosts = computed(() => {
  let result = posts.value

  // 根据活跃标签筛选
  if (activeTab.value === 'following') {
    // 这里应该筛选关注用户的动态
    result = result.filter(post => post.username === '资深设计师老王')
  } else if (activeTab.value === 'trending') {
    // 按热度排序
    result = result.sort((a, b) => (b.likes + b.comments) - (a.likes + a.comments))
  } else if (activeTab.value === 'help') {
    result = result.filter(post => post.category === 'help')
  }

  // 关键词搜索
  if (searchKeyword.value) {
    result = result.filter(post =>
      post.title.toLowerCase().includes(searchKeyword.value.toLowerCase()) ||
      post.excerpt.toLowerCase().includes(searchKeyword.value.toLowerCase()) ||
      post.topics.some(topic => topic.toLowerCase().includes(searchKeyword.value.toLowerCase()))
    )
  }

  // 分类筛选
  if (categoryFilter.value) {
    result = result.filter(post => post.category === categoryFilter.value)
  }

  // 排序
  switch (sortBy.value) {
    case 'likes':
      result.sort((a, b) => b.likes - a.likes)
      break
    case 'comments':
      result.sort((a, b) => b.comments - a.comments)
      break
    case 'views':
      result.sort((a, b) => b.views - a.views)
      break
    default: // latest
      result.sort((a, b) => new Date(b.createTime) - new Date(a.createTime))
  }

  return result
})

// 方法
const switchTab = (tabKey) => {
  activeTab.value = tabKey
  currentPage.value = 1
}

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

const formatTime = (timeString) => {
  const date = new Date(timeString)
  const now = new Date()
  const diff = now - date
  
  if (diff < 60000) { // 1分钟内
    return '刚刚'
  } else if (diff < 3600000) { // 1小时内
    return `${Math.floor(diff / 60000)}分钟前`
  } else if (diff < 86400000) { // 1天内
    return `${Math.floor(diff / 3600000)}小时前`
  } else {
    return date.toLocaleDateString('zh-CN')
  }
}

const getCategoryType = (category) => {
  const types = {
    showcase: 'success',
    experience: 'info',
    tech: 'warning',
    help: 'danger'
  }
  return types[category] || 'info'
}

const getCategoryLabel = (category) => {
  const labels = {
    showcase: '作品展示',
    experience: '学习心得',
    tech: '技术讨论',
    help: '求助问答'
  }
  return labels[category] || '其他'
}

const filterByTopic = (topicName) => {
  searchKeyword.value = topicName
  handleSearch()
}

const viewPost = (postId) => {
  ElMessage.info(`查看动态详情: ${postId}`)
  // 这里可以跳转到动态详情页
}

const toggleLike = async (postId) => {
  if (!isLoggedIn.value) {
    ElMessage.warning('请先登录后再点赞')
    return
  }
  
  const post = posts.value.find(p => p.id === postId)
  if (post) {
    post.isLiked = !post.isLiked
    post.likes += post.isLiked ? 1 : -1
    ElMessage.success(post.isLiked ? '点赞成功' : '取消点赞')
  }
}

const toggleCollect = async (postId) => {
  if (!isLoggedIn.value) {
    ElMessage.warning('请先登录后再收藏')
    return
  }
  
  const post = posts.value.find(p => p.id === postId)
  if (post) {
    post.isCollected = !post.isCollected
    ElMessage.success(post.isCollected ? '收藏成功' : '取消收藏')
  }
}

const sharePost = (postId) => {
  ElMessage.success('分享链接已复制到剪贴板')
  // 这里可以实现分享功能
}

const previewImage = (images, index) => {
  // 使用Element Plus的图片预览组件
  ElImageViewer({
    urlList: images,
    initialIndex: index
  })
}

const toggleFollow = async (userId) => {
  if (!isLoggedIn.value) {
    ElMessage.warning('请先登录后再关注')
    return
  }
  
  const user = activeUsers.value.find(u => u.id === userId)
  if (user) {
    user.isFollowing = !user.isFollowing
    ElMessage.success(user.isFollowing ? '关注成功' : '取消关注')
  }
}

const viewUserProfile = (userId) => {
  ElMessage.info(`查看用户资料: ${userId}`)
  // 这里可以跳转到用户资料页
}

const goToLogin = () => {
  router.push('/login')
}

const handleClosePostDialog = (done) => {
  if (postForm.title || postForm.content) {
    ElMessageBox.confirm('确定要关闭吗？未保存的内容将丢失。', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }).then(() => {
      resetPostForm()
      done()
    }).catch(() => {})
  } else {
    done()
  }
}

const resetPostForm = () => {
  Object.assign(postForm, {
    category: '',
    title: '',
    content: '',
    topics: '',
    images: []
  })
}

const submitPost = async () => {
  if (!isLoggedIn.value) {
    ElMessage.warning('请先登录后再发布')
    return
  }
  
  if (!postForm.title || !postForm.content) {
    ElMessage.warning('请填写标题和内容')
    return
  }
  
  submitting.value = true
  
  try {
    // 模拟提交
    await new Promise(resolve => setTimeout(resolve, 1500))
    
    // 添加新动态到列表
    const newPost = {
      id: Date.now(),
      username: currentUser.value.name,
      userTitle: currentUser.value.title,
      userAvatar: currentUser.value.avatar,
      title: postForm.title,
      excerpt: postForm.content.substring(0, 100) + '...',
      content: postForm.content,
      category: postForm.category,
      topics: postForm.topics ? postForm.topics.split(' ').filter(t => t) : [],
      images: postForm.images.map(file => URL.createObjectURL(file.raw)),
      createTime: new Date().toISOString(),
      likes: 0,
      comments: 0,
      views: 0,
      isLiked: false,
      isCollected: false
    }
    
    posts.value.unshift(newPost)
    
    ElMessage.success('发布成功！')
    showPostDialog.value = false
    resetPostForm()
  } catch (error) {
    ElMessage.error('发布失败，请重试')
  } finally {
    submitting.value = false
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
.community-page {
  min-height: 100vh;
  background: #f8f9fa;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

.page-header {
  background: linear-gradient(135deg, #1890ff 0%, #36cfc9 100%);
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

.community-nav {
  background: white;
  border-bottom: 1px solid #e9ecef;
  padding: 20px 0;
  
  .container {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  
  .nav-tabs {
    display: flex;
    gap: 30px;
    
    .nav-tab {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 10px 15px;
      border-radius: 8px;
      cursor: pointer;
      transition: all 0.3s ease;
      position: relative;
      
      &:hover {
        background: #f0f9ff;
        color: #1890ff;
      }
      
      &.active {
        background: #1890ff;
        color: white;
      }
      
      .tab-badge {
        margin-left: 5px;
      }
    }
  }
}

.community-content {
  padding: 30px 0;
  
  .content-layout {
    display: grid;
    grid-template-columns: 1fr 300px;
    gap: 30px;
  }
}

.hot-topics-section {
  background: white;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 20px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  
  .section-title {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 16px;
    font-weight: 600;
    color: #333;
    margin-bottom: 15px;
    
    .el-icon {
      color: #ff4d4f;
    }
  }
  
  .hot-topics {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    
    .topic-tag {
      background: #f0f9ff;
      color: #1890ff;
      padding: 6px 12px;
      border-radius: 20px;
      font-size: 14px;
      cursor: pointer;
      transition: all 0.2s ease;
      
      &:hover {
        background: #1890ff;
        color: white;
      }
      
      .topic-count {
        margin-left: 5px;
        opacity: 0.7;
      }
    }
  }
}

.filter-section {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  
  .filter-left {
    display: flex;
    gap: 15px;
  }
}

.posts-list {
  .post-card {
    background: white;
    border-radius: 12px;
    padding: 20px;
    margin-bottom: 20px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
    cursor: pointer;
    transition: all 0.3s ease;
    
    &:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
    }
    
    .post-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 15px;
      
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
          
          .user-title {
            font-size: 12px;
            color: #999;
          }
        }
      }
      
      .post-meta {
        display: flex;
        align-items: center;
        gap: 10px;
        
        .post-time {
          font-size: 12px;
          color: #999;
        }
      }
    }
    
    .post-content {
      margin-bottom: 15px;
      
      .post-title {
        font-size: 18px;
        font-weight: 600;
        color: #333;
        margin-bottom: 10px;
        line-height: 1.4;
      }
      
      .post-excerpt {
        color: #666;
        line-height: 1.6;
        margin-bottom: 15px;
      }
      
      .post-images {
        display: flex;
        gap: 8px;
        margin-bottom: 15px;
        
        .image-item {
          position: relative;
          width: 120px;
          height: 90px;
          border-radius: 8px;
          overflow: hidden;
          cursor: pointer;
          
          img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.3s ease;
          }
          
          &:hover img {
            transform: scale(1.1);
          }
          
          .more-images {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.7);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            font-weight: 600;
          }
        }
      }
      
      .post-topics {
        display: flex;
        flex-wrap: wrap;
        gap: 6px;
        
        .topic-tag.small {
          background: #f0f0f0;
          color: #666;
          padding: 3px 8px;
          border-radius: 12px;
          font-size: 12px;
          cursor: pointer;
          
          &:hover {
            background: #1890ff;
            color: white;
          }
        }
      }
    }
    
    .post-footer {
      display: flex;
      justify-content: space-between;
      align-items: center;
      
      .post-stats {
        display: flex;
        gap: 20px;
        
        .stat-item {
          display: flex;
          align-items: center;
          gap: 4px;
          color: #666;
          font-size: 14px;
          cursor: pointer;
          transition: color 0.2s ease;
          
          &:hover {
            color: #1890ff;
          }
          
          &.liked {
            color: #ff4d4f;
          }
        }
      }
    }
  }
}

.sidebar {
  .user-card,
  .active-users,
  .recommended-topics {
    background: white;
    border-radius: 12px;
    padding: 20px;
    margin-bottom: 20px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
    
    h3 {
      font-size: 16px;
      font-weight: 600;
      color: #333;
      margin-bottom: 15px;
    }
  }
  
  .user-card {
    .logged-user {
      text-align: center;
      
      .user-avatar {
        width: 60px;
        height: 60px;
        border-radius: 50%;
        object-fit: cover;
        margin-bottom: 10px;
      }
      
      .user-info {
        margin-bottom: 15px;
        
        h4 {
          font-size: 16px;
          font-weight: 600;
          color: #333;
          margin-bottom: 5px;
        }
        
        p {
          color: #666;
          font-size: 14px;
        }
      }
      
      .user-stats {
        display: flex;
        justify-content: space-around;
        
        .stat {
          text-align: center;
          
          .number {
            display: block;
            font-size: 18px;
            font-weight: 600;
            color: #1890ff;
          }
          
          .label {
            font-size: 12px;
            color: #999;
          }
        }
      }
    }
    
    .guest-user {
      text-align: center;
      
      p {
        color: #666;
        margin-bottom: 15px;
      }
    }
  }
  
  .active-users {
    .user-list {
      .user-item {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 10px 0;
        border-bottom: 1px solid #f0f0f0;
        cursor: pointer;
        
        &:last-child {
          border-bottom: none;
        }
        
        &:hover {
          background: #f8f9fa;
        }
        
        .user-avatar {
          width: 36px;
          height: 36px;
          border-radius: 50%;
          object-fit: cover;
        }
        
        .user-info {
          flex: 1;
          
          .username {
            display: block;
            font-weight: 500;
            color: #333;
            font-size: 14px;
          }
          
          .user-title {
            font-size: 12px;
            color: #999;
          }
        }
      }
    }
  }
  
  .recommended-topics {
    .topic-list {
      .topic-item {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 8px 0;
        cursor: pointer;
        transition: background-color 0.2s ease;
        
        &:hover {
          background: #f8f9fa;
        }
        
        .topic-name {
          color: #1890ff;
          font-weight: 500;
        }
        
        .topic-count {
          font-size: 12px;
          color: #999;
        }
      }
    }
  }
}

.pagination-wrapper {
  display: flex;
  justify-content: center;
  margin-top: 30px;
}

.post-form {
  .el-upload {
    :deep(.el-upload--picture-card) {
      width: 80px;
      height: 80px;
    }
  }
}

// 响应式设计
@media (max-width: 768px) {
  .page-header {
    padding: 40px 0;
    
    h1 {
      font-size: 2rem;
    }
  }
  
  .community-nav {
    .container {
      flex-direction: column !important;
      gap: 15px !important;
    }
    
    .nav-tabs {
      flex-wrap: wrap !important;
      gap: 15px !important;
    }
  }
  
  .content-layout {
    grid-template-columns: 1fr !important;
    gap: 20px !important;
  }
  
  .filter-section {
    flex-direction: column !important;
    gap: 15px !important;
    align-items: stretch !important;
  }
  
  .post-images {
    .image-item {
      width: 100px !important;
      height: 75px !important;
    }
  }
  
  .post-stats {
    gap: 15px !important;
  }
}
</style>