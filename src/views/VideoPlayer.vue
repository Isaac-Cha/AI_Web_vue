<template>
  <div class="video-player-page">
    <div v-loading="loading" class="video-container">
      <!-- 视频播放器 -->
      <div class="video-wrapper">
        <div class="video-header">
          <div class="breadcrumb">
            <el-breadcrumb separator="/">
              <el-breadcrumb-item :to="{ path: '/' }">首页</el-breadcrumb-item>
              <el-breadcrumb-item :to="{ path: returnPath }">{{ returnText }}</el-breadcrumb-item>
              <el-breadcrumb-item>视频播放</el-breadcrumb-item>
            </el-breadcrumb>
          </div>
          <h1 class="video-title">{{ videoTitle }}</h1>
        </div>
        
        <div class="video-player" :class="{ playing: isPlaying }">
          <video
            ref="videoRef"
            :src="videoUrl"
            :poster="videoPoster"
            controls
            preload="metadata"
            @loadstart="onVideoLoadStart"
            @loadeddata="onVideoLoaded"
            @error="onVideoError"
            @play="onVideoPlay"
            @pause="onVideoPause"
            @ended="onVideoEnded"
          >
            您的浏览器不支持视频播放
          </video>
          
          <!-- 视频控制覆盖层 -->
          <div v-if="!isPlaying || showControls" class="video-controls-overlay">
            <div class="control-buttons">
              <el-button
                :icon="isPlaying ? 'VideoPause' : 'VideoPlay'"
                :disabled="loading"
                circle
                size="large"
                @click="togglePlay"
              />
            </div>
          </div>
        </div>
        
        <!-- 视频信息 -->
        <div class="video-info">
          <div class="video-meta">
            <div class="meta-item">
              <el-icon><Clock /></el-icon>
              <span>时长：{{ formatDuration(videoDuration) }}</span>
            </div>
            <div class="meta-item">
              <el-icon><User /></el-icon>
              <span>讲师：{{ instructor }}</span>
            </div>
            <div class="meta-item">
              <el-icon><View /></el-icon>
              <span>{{ viewCount }}次观看</span>
            </div>
          </div>
          
          <div class="video-description">
            <h3>课程介绍</h3>
            <p>{{ videoDescription }}</p>
          </div>
        </div>
      </div>
      
      <!-- 侧边栏 -->
      <div class="sidebar">
        <!-- 课程章节 -->
        <div class="course-chapters">
          <h3>课程章节</h3>
          <div class="chapter-list">
            <div
              v-for="(chapter, index) in chapters"
              :key="chapter.id"
              class="chapter-item"
              :class="{ active: currentChapter === chapter.id }"
              @click="playChapter(chapter)"
            >
              <div class="chapter-number">{{ index + 1 }}</div>
              <div class="chapter-info">
                <h4>{{ chapter.title }}</h4>
                <span class="chapter-duration">{{ chapter.duration }}</span>
              </div>
              <el-icon class="play-icon"><VideoPlay /></el-icon>
            </div>
          </div>
        </div>
        
        <!-- 相关推荐 -->
        <div class="related-videos">
          <h3>相关推荐</h3>
          <div class="related-list">
            <div
              v-for="video in relatedVideos"
              :key="video.id"
              class="related-item"
              @click="playRelatedVideo(video)"
            >
              <img :src="video.thumbnail" :alt="video.title" />
              <div class="related-info">
                <h4>{{ video.title }}</h4>
                <p>{{ video.instructor }}</p>
                <span class="duration">{{ video.duration }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Clock, User, View, VideoPlay } from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()

// 响应式数据
const loading = ref(true)
const videoRef = ref(null)
const isPlaying = ref(false)
const showControls = ref(false)
const videoDuration = ref(0)
const currentChapter = ref('1')

// 视频信息
const videoTitle = ref('')
const videoUrl = ref('https://www.w3schools.com/html/mov_bbb.mp4')
const videoPoster = ref('https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=800&h=450&fit=crop&crop=center')
const videoDescription = ref('')
const instructor = ref('')
const viewCount = ref(0)

// 导航信息
const returnPath = ref('/courses')
const returnText = ref('课程中心')

// 课程章节
const chapters = ref([
  {
    id: '1',
    title: 'AutoCAD界面介绍',
    duration: '15:30',
    url: 'https://www.w3schools.com/html/mov_bbb.mp4'
  },
  {
    id: '2',
    title: '基本操作和设置',
    duration: '20:45',
    url: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4'
  },
  {
    id: '3',
    title: '坐标系统详解',
    duration: '25:20',
    url: 'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4'
  },
  {
    id: '4',
    title: '绘图工具详解',
    duration: '30:15',
    url: 'https://www.w3schools.com/html/movie.mp4'
  }
])

// 相关视频
const relatedVideos = ref([
  {
    id: 'r1',
    title: 'SketchUp建筑建模入门',
    instructor: '李工程师',
    duration: '45:30',
    thumbnail: 'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=200&h=120&fit=crop&crop=center'
  },
  {
    id: 'r2',
    title: '建筑设计原理与方法',
    instructor: '王教授',
    duration: '60:20',
    thumbnail: 'https://images.unsplash.com/photo-1448630360428-65456885c650?w=200&h=120&fit=crop&crop=center'
  },
  {
    id: 'r3',
    title: 'Revit BIM建筑信息建模',
    instructor: '张建筑师',
    duration: '55:45',
    thumbnail: 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=200&h=120&fit=crop&crop=center'
  }
])

// 计算属性
const currentVideo = computed(() => {
  return chapters.value.find(chapter => chapter.id === currentChapter.value)
})

// 方法
const initializeVideo = () => {
  const { title, type, from } = route.query
  
  // 设置视频标题
  videoTitle.value = title || 'AutoCAD建筑制图基础 - 第1章'
  
  // 设置返回路径
  if (from === 'live') {
    returnPath.value = '/live'
    returnText.value = '直播中心'
  } else if (from === 'free') {
    returnPath.value = '/free'
    returnText.value = '免费课程'
  } else {
    returnPath.value = '/courses'
    returnText.value = '课程中心'
  }
  
  // 设置视频信息
  videoDescription.value = '本节课将详细介绍AutoCAD的界面布局和基本操作，帮助初学者快速上手软件的使用。'
  instructor.value = '张建筑师'
  viewCount.value = 1234
  
  // 初始状态设置
  loading.value = false
  showControls.value = true
  isPlaying.value = false
}

const formatDuration = (seconds) => {
  if (!seconds) return '00:00'
  const mins = Math.floor(seconds / 60)
  const secs = Math.floor(seconds % 60)
  return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
}

const togglePlay = () => {
  if (!videoRef.value) return
  
  if (isPlaying.value) {
    videoRef.value.pause()
  } else {
    videoRef.value.play()
  }
}

const playChapter = (chapter) => {
  currentChapter.value = chapter.id
  videoTitle.value = chapter.title
  videoUrl.value = chapter.url
  
  // 更新视频源
  if (videoRef.value) {
    videoRef.value.src = chapter.url
    videoRef.value.load()
  }
}

const playRelatedVideo = (video) => {
  // 跳转到相关视频
  router.push({
    path: '/video-player',
    query: {
      title: video.title,
      type: 'course',
      from: route.query.from || 'courses'
    }
  })
}

// 视频事件处理
const onVideoLoadStart = () => {
  loading.value = true
  showControls.value = true
}

const onVideoLoaded = () => {
  loading.value = false
  showControls.value = true
  if (videoRef.value) {
    videoDuration.value = videoRef.value.duration
  }
}

const onVideoError = () => {
  loading.value = false
  showControls.value = true
  ElMessage.error('视频加载失败，请稍后重试')
}

const onVideoPlay = () => {
  isPlaying.value = true
  // 播放时隐藏控制按钮，3秒后自动隐藏
  showControls.value = false
  setTimeout(() => {
    if (isPlaying.value) {
      showControls.value = false
    }
  }, 3000)
}

const onVideoPause = () => {
  isPlaying.value = false
  showControls.value = true
}

const onVideoEnded = () => {
  isPlaying.value = false
  showControls.value = true
  
  // 自动播放下一章节
  const currentIndex = chapters.value.findIndex(chapter => chapter.id === currentChapter.value)
  if (currentIndex < chapters.value.length - 1) {
    const nextChapter = chapters.value[currentIndex + 1]
    setTimeout(() => {
      playChapter(nextChapter)
    }, 2000)
  }
}

// 生命周期
onMounted(() => {
  initializeVideo()
})

onUnmounted(() => {
  if (videoRef.value) {
    videoRef.value.pause()
  }
})
</script>

<style scoped>
.video-player-page {
  min-height: 100vh;
  background: #f5f5f5;
  padding: 20px 0;
}

.video-container {
  max-width: 1400px;
  margin: 0 auto;
  display: grid;
  grid-template-columns: 1fr 350px;
  gap: 30px;
  padding: 0 20px;
}

.video-wrapper {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.video-header {
  padding: 20px 30px;
  border-bottom: 1px solid #eee;
}

.breadcrumb {
  margin-bottom: 15px;
}

.video-title {
  font-size: 24px;
  font-weight: 600;
  color: #333;
  margin: 0;
}

.video-player {
  position: relative;
  background: #000;
}

.video-player video {
  width: 100%;
  height: auto;
  min-height: 500px;
  display: block;
}

.video-controls-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0, 0, 0, 0.3);
  opacity: 1;
  transition: opacity 0.3s ease;
  pointer-events: auto;
}

.video-player:hover .video-controls-overlay {
  opacity: 1;
}

/* 当视频播放时，只有在hover时才显示控制层 */
.video-player.playing .video-controls-overlay {
  opacity: 0;
  pointer-events: none;
}

.video-player.playing:hover .video-controls-overlay {
  opacity: 1;
  pointer-events: auto;
}

.control-buttons .el-button {
  background: rgba(255, 255, 255, 0.9);
  border: none;
  font-size: 24px;
}

.video-info {
  padding: 30px;
}

.video-meta {
  display: flex;
  gap: 30px;
  margin-bottom: 25px;
  padding-bottom: 20px;
  border-bottom: 1px solid #eee;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #666;
  font-size: 14px;
}

.meta-item .el-icon {
  color: #409eff;
}

.video-description h3 {
  font-size: 18px;
  font-weight: 600;
  color: #333;
  margin-bottom: 15px;
}

.video-description p {
  color: #666;
  line-height: 1.6;
  margin: 0;
}

.sidebar {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.course-chapters,
.related-videos {
  background: white;
  border-radius: 12px;
  padding: 25px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.course-chapters h3,
.related-videos h3 {
  font-size: 18px;
  font-weight: 600;
  color: #333;
  margin-bottom: 20px;
}

.chapter-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.chapter-item {
  display: flex;
  align-items: center;
  gap: 15px;
  padding: 15px;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 1px solid #eee;
}

.chapter-item:hover {
  background: #f8f9fa;
  border-color: #409eff;
}

.chapter-item.active {
  background: #e3f2fd;
  border-color: #409eff;
}

.chapter-number {
  width: 30px;
  height: 30px;
  background: #409eff;
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  font-size: 14px;
  flex-shrink: 0;
}

.chapter-item.active .chapter-number {
  background: #1976d2;
}

.chapter-info {
  flex: 1;
}

.chapter-info h4 {
  font-size: 14px;
  font-weight: 500;
  color: #333;
  margin: 0 0 5px 0;
}

.chapter-duration {
  font-size: 12px;
  color: #666;
}

.play-icon {
  color: #409eff;
  font-size: 18px;
}

.related-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.related-item {
  display: flex;
  gap: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  padding: 10px;
  border-radius: 8px;
}

.related-item:hover {
  background: #f8f9fa;
}

.related-item img {
  width: 80px;
  height: 50px;
  border-radius: 6px;
  object-fit: cover;
  flex-shrink: 0;
}

.related-info {
  flex: 1;
}

.related-info h4 {
  font-size: 13px;
  font-weight: 500;
  color: #333;
  margin: 0 0 5px 0;
  line-height: 1.3;
}

.related-info p {
  font-size: 12px;
  color: #666;
  margin: 0 0 3px 0;
}

.related-info .duration {
  font-size: 11px;
  color: #999;
}

@media (max-width: 1024px) {
  .video-container {
    grid-template-columns: 1fr;
    gap: 20px;
  }
  
  .sidebar {
    order: -1;
  }
}

@media (max-width: 768px) {
  .video-container {
    padding: 0 15px;
  }
  
  .video-header {
    padding: 15px 20px;
  }
  
  .video-title {
    font-size: 20px;
  }
  
  .video-info {
    padding: 20px;
  }
  
  .video-meta {
    flex-direction: column;
    gap: 15px;
  }
  
  .course-chapters,
  .related-videos {
    padding: 20px;
  }
}
</style>