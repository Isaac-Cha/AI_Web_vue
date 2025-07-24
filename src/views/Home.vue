<template>
  <div class="home-page">
    <!-- 轮播图 -->
    <HeroBanner :banners="banners" />
    
    <!-- 热门课程 -->
    <section class="section">
      <div class="container">
        <SectionTitle
          title="热门课程"
          subtitle="精选优质课程，助力技能提升"
        />
        <CourseGrid :courses="hotCourses" />
        <div class="section-more">
          <el-button type="primary" @click="$router.push('/courses')">
            查看更多课程
          </el-button>
        </div>
      </div>
    </section>
    
    <!-- 直播预告 -->
    <section class="section bg-gray">
      <div class="container">
        <SectionTitle
          title="直播预告"
          subtitle="实时互动，在线答疑"
        />
        <LivePreviewCard :lives="upcomingLives" />
        <div class="section-more">
          <el-button type="primary" @click="$router.push('/live')">
            查看更多直播
          </el-button>
        </div>
      </div>
    </section>
    
    <!-- 明星教师 -->
    <section class="section">
      <div class="container">
        <SectionTitle
          title="明星教师"
          subtitle="专业导师，倾囊相授"
        />
        <TeacherCard :teachers="starTeachers" />
        <div class="section-more">
          <el-button type="primary" @click="$router.push('/teachers')">
            查看更多教师
          </el-button>
        </div>
      </div>
    </section>
    
    <!-- 免费资源 -->
    <section class="section bg-gray">
      <div class="container">
        <SectionTitle
          title="免费资源"
          subtitle="精品资源，免费下载"
        />
        <FreeResourceGrid :resources="freeResources" />
        <div class="section-more">
          <el-button type="primary" @click="$router.push('/resources')">
            查看更多资源
          </el-button>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import HeroBanner from '@/components/home/HeroBanner.vue'
import SectionTitle from '@/components/common/SectionTitle.vue'
import CourseGrid from '@/components/course/CourseGrid.vue'
import LivePreviewCard from '@/components/live/LivePreviewCard.vue'
import TeacherCard from '@/components/teacher/TeacherCard.vue'
import FreeResourceGrid from '@/components/resource/FreeResourceGrid.vue'

// 响应式数据
const banners = ref([])
const hotCourses = ref([])
const upcomingLives = ref([])
const starTeachers = ref([])
const freeResources = ref([])

// 模拟数据
const initData = () => {
  // 轮播图数据
  banners.value = [
    {
      id: 1,
      title: '建筑设计基础课程',
      subtitle: '从零开始学习建筑设计，掌握专业技能',
      image: 'https://picsum.photos/1200/500?random=1',
      action: '/course/1',
      actionText: '立即学习',
      secondaryAction: '/free',
      secondaryActionText: '免费试听'
    },
    {
      id: 2,
      title: 'CAD制图精通班',
      subtitle: '专业CAD技能培训，快速提升制图能力',
      image: 'https://picsum.photos/1200/500?random=2',
      action: '/course/2',
      actionText: '查看课程',
      secondaryAction: '/live',
      secondaryActionText: '观看直播'
    },
    {
      id: 3,
      title: '3D建模实战课',
      subtitle: '掌握三维建模技术，打造专业作品',
      image: 'https://picsum.photos/1200/500?random=3',
      action: '/course/3',
      actionText: '开始学习',
      secondaryAction: '/community',
      secondaryActionText: '加入社区'
    }
  ]
  
  // 热门课程数据
  hotCourses.value = [
    {
      id: 1,
      title: '建筑设计基础入门',
      description: '从基础概念到实际应用，全面掌握建筑设计核心知识',
      cover: 'https://picsum.photos/300/200?random=11',
      teacher: {
        name: '张建筑',
        avatar: 'https://picsum.photos/40/40?random=21'
      },
      students: 1234,
      price: 299,
      originalPrice: 399,
      rating: 4.8,
      isVip: false,
      isFree: false
    },
    {
      id: 2,
      title: 'CAD制图从入门到精通',
      description: '系统学习CAD软件操作，掌握专业制图技能',
      cover: 'https://picsum.photos/300/200?random=12',
      teacher: {
        name: '李工程',
        avatar: 'https://picsum.photos/40/40?random=22'
      },
      students: 2156,
      price: 399,
      originalPrice: 599,
      rating: 4.9,
      isVip: false,
      isFree: false
    },
    {
      id: 3,
      title: '3D建模实战训练',
      description: '通过实际项目学习3D建模技术，提升专业技能',
      cover: 'https://picsum.photos/300/200?random=13',
      teacher: {
        name: '王设计',
        avatar: 'https://picsum.photos/40/40?random=23'
      },
      students: 987,
      price: 0,
      originalPrice: 0,
      rating: 4.7,
      isVip: true,
      isFree: false
    }
  ]
  
  // 直播预告数据
  upcomingLives.value = [
    {
      id: 1,
      title: '建筑设计趋势分析',
      cover: 'https://picsum.photos/320/180?random=31',
      teacher: {
        name: '张建筑',
        avatar: 'https://picsum.photos/40/40?random=21'
      },
      time: new Date(Date.now() + 2 * 60 * 60 * 1000),
      isLive: false,
      viewers: 0
    },
    {
      id: 2,
      title: 'CAD技巧分享直播',
      cover: 'https://picsum.photos/320/180?random=32',
      teacher: {
        name: '李工程',
        avatar: 'https://picsum.photos/40/40?random=22'
      },
      time: new Date(),
      isLive: true,
      viewers: 1234
    }
  ]
  
  // 明星教师数据
  starTeachers.value = [
    {
      id: 1,
      name: '张建筑',
      title: '高级建筑师',
      avatar: 'https://picsum.photos/80/80?random=41',
      introduction: '拥有15年建筑设计经验，参与多个大型项目设计',
      studentCount: 5678,
      courseCount: 12,
      rating: 4.9,
      specialties: ['建筑设计', '规划设计', '方案设计'],
      isOnline: true,
      isFollowed: false
    },
    {
      id: 2,
      name: '李工程',
      title: 'CAD专家',
      avatar: 'https://picsum.photos/80/80?random=42',
      introduction: '专业CAD培训师，帮助数千学员掌握制图技能',
      studentCount: 8901,
      courseCount: 8,
      rating: 4.8,
      specialties: ['CAD制图', '工程制图', '技术绘图'],
      isOnline: false,
      isFollowed: true
    },
    {
      id: 3,
      name: '王设计',
      title: '3D建模师',
      avatar: 'https://picsum.photos/80/80?random=43',
      introduction: '资深3D建模专家，擅长建筑可视化表现',
      studentCount: 3456,
      courseCount: 6,
      rating: 4.7,
      specialties: ['3D建模', '渲染表现', '动画制作'],
      isOnline: true,
      isFollowed: false
    }
  ]
  
  // 免费资源数据
  freeResources.value = [
    {
      id: 1,
      title: '建筑设计规范手册',
      description: '最新建筑设计规范汇总，包含各类建筑设计标准',
      thumbnail: 'https://picsum.photos/280/180?random=51',
      type: 'template',
      format: 'pdf',
      size: 15728640, // 15MB
      downloadCount: 2345,
      tags: ['规范', '设计', '标准']
    },
    {
      id: 2,
      title: 'CAD常用图块库',
      description: '精选CAD常用图块，提高制图效率',
      thumbnail: 'https://picsum.photos/280/180?random=52',
      type: 'material',
      format: 'dwg',
      size: 52428800, // 50MB
      downloadCount: 4567,
      tags: ['CAD', '图块', '素材']
    },
    {
      id: 3,
      title: '建筑材质贴图包',
      description: '高质量建筑材质贴图，适用于各种渲染软件',
      thumbnail: 'https://picsum.photos/280/180?random=53',
      type: 'material',
      format: 'zip',
      size: 104857600, // 100MB
      downloadCount: 1890,
      tags: ['材质', '贴图', '渲染']
    }
  ]
}

onMounted(() => {
  initData()
})
</script>

<style lang="scss" scoped>
.home-page {
  .section {
    padding: 60px 0;
    
    &.bg-gray {
      background: #f8f9fa;
    }
    
    @media (max-width: 768px) {
      padding: 40px 0;
    }
  }
  
  .container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
  }
  
  .section-more {
    text-align: center;
    margin-top: 40px;
    
    @media (max-width: 768px) {
      margin-top: 30px;
    }
  }
}
</style>