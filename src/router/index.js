import { createRouter, createWebHashHistory } from 'vue-router'
import Home from '../views/Home.vue'
import Login from '../views/Login.vue'
import Courses from '../views/Courses.vue'
import CourseDetail from '../views/CourseDetail.vue'
import Free from '../views/Free.vue'
import Live from '../views/Live.vue'
import LiveDetail from '../views/LiveDetail.vue'
import Community from '../views/Community.vue'
import Cart from '../views/Cart.vue'
import VideoPlayer from '../views/VideoPlayer.vue'

// 路由配置
const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home,
    meta: { title: '首页' }
  },
  {
    path: '/courses',
    name: 'Courses',
    component: Courses,
    meta: { title: '课程中心' }
  },
  {
    path: '/course/:id',
    name: 'CourseDetail',
    component: CourseDetail,
    meta: { title: '课程详情' }
  },
  {
    path: '/free',
    name: 'FreeResources',
    component: Free,
    meta: { title: '免费资源' }
  },
  {
    path: '/live',
    name: 'Live',
    component: Live,
    meta: { title: '直播课程' }
  },
  {
    path: '/live/:id',
    name: 'LiveDetail',
    component: LiveDetail,
    meta: { title: '直播详情' }
  },
  {
    path: '/community',
    name: 'Community',
    component: Community,
    meta: { title: '学习社区' }
  },
  {
    path: '/cart',
    name: 'Cart',
    component: Cart,
    meta: { title: '购物车' }
  },
  {
    path: '/video-player',
    name: 'VideoPlayer',
    component: VideoPlayer,
    meta: { title: '视频播放' }
  },
  {
    path: '/login',
    name: 'Login',
    component: Login,
    meta: { title: '登录' }
  }
]

const router = createRouter({
  history: createWebHashHistory(),
  routes,
  scrollBehavior(to, from, savedPosition) {
    if (savedPosition) {
      return savedPosition
    } else {
      return { top: 0 }
    }
  }
})

// 路由守卫
router.beforeEach((to, from, next) => {
  // 设置页面标题
  document.title = to.meta.title ? `${to.meta.title} - 解构建筑小教室` : '解构建筑小教室'
  
  next()
})

export default router