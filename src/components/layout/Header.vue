<template>
  <header class="header" :class="{ 'mobile': isMobile }">
    <div class="container">
      <!-- Logo -->
      <div class="logo">
        <router-link to="/">
          <img src="/logo.svg" alt="解构建筑小教室" />
          <span v-if="!isMobile">解构建筑小教室</span>
        </router-link>
      </div>
      
      <!-- PC端导航 -->
      <nav v-if="!isMobile" class="nav">
        <router-link to="/" class="nav-item">首页</router-link>
        <router-link to="/courses" class="nav-item">课程中心</router-link>
        <router-link to="/free" class="nav-item">免费资源</router-link>
        <router-link to="/live" class="nav-item">直播课程</router-link>
        <router-link to="/community" class="nav-item">学习社区</router-link>
      </nav>
      
      <!-- 用户操作区 -->
      <div class="user-actions">
        <!-- 搜索 -->
        <div v-if="!isMobile" class="search">
          <el-input
            v-model="searchKeyword"
            placeholder="搜索课程、资源..."
            @keyup.enter="handleSearch"
          >
            <template #suffix>
              <el-icon @click="handleSearch"><Search /></el-icon>
            </template>
          </el-input>
        </div>
        
        <!-- 购物车 -->
        <router-link to="/cart" class="cart-icon">
          <el-badge :value="cartCount" :hidden="cartCount === 0">
            <el-icon><ShoppingCart /></el-icon>
          </el-badge>
        </router-link>
        
        <!-- 用户信息 -->
        <div v-if="isLoggedIn" class="user-info">
          <el-dropdown @command="handleUserCommand">
            <div class="user-avatar">
              <img :src="userAvatar" :alt="username" />
              <span v-if="!isMobile">{{ username }}</span>
            </div>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">个人中心</el-dropdown-item>
                <el-dropdown-item command="orders">我的订单</el-dropdown-item>
                <el-dropdown-item command="courses">我的课程</el-dropdown-item>
                <el-dropdown-item divided command="logout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
        
        <!-- 登录/注册 -->
        <div v-else class="auth-buttons">
          <router-link to="/login" class="login-btn">登录</router-link>
        </div>
        
        <!-- 移动端菜单按钮 -->
        <el-icon v-if="isMobile" class="menu-icon" @click="showMobileMenu = true">
          <Menu />
        </el-icon>
      </div>
    </div>
    
    <!-- 移动端菜单抽屉 -->
    <el-drawer
      v-model="showMobileMenu"
      direction="rtl"
      size="280px"
      :with-header="false"
    >
      <div class="mobile-menu">
        <div class="menu-header">
          <div v-if="isLoggedIn" class="user-info">
            <img :src="userAvatar" :alt="username" class="avatar" />
            <span class="username">{{ username }}</span>
          </div>
          <div v-else class="auth-links">
            <router-link to="/login" @click="showMobileMenu = false">登录</router-link>
          </div>
        </div>
        
        <div class="menu-items">
          <router-link to="/" @click="showMobileMenu = false">首页</router-link>
          <router-link to="/courses" @click="showMobileMenu = false">课程中心</router-link>
          <router-link to="/free" @click="showMobileMenu = false">免费资源</router-link>
          <router-link to="/live" @click="showMobileMenu = false">直播课程</router-link>
          <router-link to="/community" @click="showMobileMenu = false">学习社区</router-link>
          
          <div v-if="isLoggedIn" class="user-menu">
            <router-link to="/profile" @click="showMobileMenu = false">个人中心</router-link>
            <router-link to="/profile/orders" @click="showMobileMenu = false">我的订单</router-link>
            <router-link to="/profile/courses" @click="showMobileMenu = false">我的课程</router-link>
            <a @click="handleLogout">退出登录</a>
          </div>
        </div>
      </div>
    </el-drawer>
  </header>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Search, ShoppingCart, Menu } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'

const router = useRouter()

const searchKeyword = ref('')
const showMobileMenu = ref(false)
const cartCount = ref(0)
const isMobile = ref(false)
const isLoggedIn = ref(false)
const username = ref('用户')
const userAvatar = ref('/default-avatar.svg')

// 检查登录状态
const checkLoginStatus = () => {
  const loginStatus = localStorage.getItem('isLoggedIn')
  const userInfo = localStorage.getItem('userInfo')
  
  if (loginStatus === 'true' && userInfo) {
    try {
      const user = JSON.parse(userInfo)
      isLoggedIn.value = true
      username.value = user.username || '用户'
      userAvatar.value = user.avatar || '/default-avatar.svg'
    } catch (error) {
      console.error('解析用户信息失败:', error)
      // 清除无效的登录状态
      localStorage.removeItem('isLoggedIn')
      localStorage.removeItem('userInfo')
    }
  }
}

// 检查是否为移动端
const checkMobile = () => {
  isMobile.value = window.innerWidth <= 768
}

// 组件挂载时检查登录状态和设备类型
onMounted(() => {
  checkLoginStatus()
  checkMobile()
  
  // 监听窗口大小变化
  window.addEventListener('resize', checkMobile)
  
  // 监听存储变化（用于跨标签页同步登录状态）
  window.addEventListener('storage', (e) => {
    if (e.key === 'isLoggedIn' || e.key === 'userInfo') {
      checkLoginStatus()
    }
  })
})

const handleSearch = () => {
  if (searchKeyword.value.trim()) {
    router.push({
      path: '/courses',
      query: { keyword: searchKeyword.value }
    })
  }
}

const handleUserCommand = (command) => {
  switch (command) {
    case 'profile':
      router.push('/profile')
      break
    case 'orders':
      router.push('/profile/orders')
      break
    case 'courses':
      router.push('/profile/courses')
      break
    case 'logout':
      handleLogout()
      break
  }
}

const handleLogout = async () => {
  try {
    // 清除登录状态
    localStorage.removeItem('isLoggedIn')
    localStorage.removeItem('userInfo')
    
    // 更新组件状态
    isLoggedIn.value = false
    username.value = '用户'
    userAvatar.value = '/default-avatar.svg'
    showMobileMenu.value = false
    
    ElMessage.success('已退出登录')
    
    // 跳转到首页
    router.push('/')
  } catch (error) {
    console.error('退出登录失败:', error)
    ElMessage.error('退出登录失败')
  }
}
</script>

<style lang="scss" scoped>
.header {
  background: #fff;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  position: sticky;
  top: 0;
  z-index: 1000;
  
  .container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    height: 70px;
  }
  
  .logo {
    a {
      display: flex;
      align-items: center;
      text-decoration: none;
      color: #333;
      font-size: 20px;
      font-weight: bold;
      
      img {
        height: 40px;
        margin-right: 10px;
      }
    }
  }
  
  .nav {
    display: flex;
    gap: 30px;
    
    .nav-item {
      text-decoration: none;
      color: #666;
      font-weight: 500;
      transition: color 0.3s;
      
      &:hover,
      &.router-link-active {
        color: #409eff;
      }
    }
  }
  
  .user-actions {
    display: flex;
    align-items: center;
    gap: 20px;
    
    .search {
      width: 250px;
      
      .el-input {
        border-radius: 20px;
      }
    }
    
    .cart-icon {
      color: #666;
      font-size: 20px;
      
      &:hover {
        color: #409eff;
      }
    }
    
    .user-info {
      .user-avatar {
        display: flex;
        align-items: center;
        cursor: pointer;
        
        img {
          width: 32px;
          height: 32px;
          border-radius: 50%;
          margin-right: 8px;
        }
      }
    }
    
    .auth-buttons {
      display: flex;
      gap: 15px;
      
      a {
        text-decoration: none;
        padding: 8px 16px;
        border-radius: 4px;
        transition: all 0.3s;
        
        &.login-btn {
          color: #409eff;
          border: 1px solid #409eff;
          
          &:hover {
            background: #409eff;
            color: white;
          }
        }
      }
    }
    
    .menu-icon {
      font-size: 24px;
      cursor: pointer;
      color: #666;
    }
  }
  
  // 移动端样式
  &.mobile {
    .container {
      padding: 0 15px;
      height: 60px;
    }
    
    .logo {
      a {
        font-size: 18px;
        
        img {
          height: 35px;
        }
      }
    }
  }
}

.mobile-menu {
  padding: 20px;
  
  .menu-header {
    padding-bottom: 20px;
    border-bottom: 1px solid #eee;
    margin-bottom: 20px;
    
    .user-info {
      display: flex;
      align-items: center;
      
      .avatar {
        width: 50px;
        height: 50px;
        border-radius: 50%;
        margin-right: 12px;
      }
      
      .username {
        font-size: 16px;
        font-weight: 500;
      }
    }
    
    .auth-links {
      display: flex;
      gap: 15px;
      
      a {
        text-decoration: none;
        color: #409eff;
        font-weight: 500;
      }
    }
  }
  
  .menu-items {
    a {
      display: block;
      padding: 15px 0;
      text-decoration: none;
      color: #333;
      font-size: 16px;
      border-bottom: 1px solid #f5f5f5;
      
      &:hover {
        color: #409eff;
      }
    }
    
    .user-menu {
      margin-top: 20px;
      padding-top: 20px;
      border-top: 1px solid #eee;
      
      a {
        color: #666;
        font-size: 14px;
        padding: 12px 0;
      }
    }
  }
}
</style>