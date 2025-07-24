import { defineStore } from 'pinia'
import { login, logout, getUserInfo } from '@/api/auth'

export const useUserStore = defineStore('user', {
  state: () => ({
    token: localStorage.getItem('token') || '',
    userInfo: null,
    isLoggedIn: false
  }),
  
  getters: {
    avatar: (state) => state.userInfo?.avatar || '/default-avatar.png',
    username: (state) => state.userInfo?.username || '未登录',
    vipLevel: (state) => state.userInfo?.vipLevel || 0
  },
  
  actions: {
    async login(credentials) {
      try {
        const response = await login(credentials)
        this.token = response.data.token
        this.isLoggedIn = true
        localStorage.setItem('token', this.token)
        await this.fetchUserInfo()
        return response
      } catch (error) {
        throw error
      }
    },
    
    async logout() {
      try {
        await logout()
      } catch (error) {
        console.error('Logout error:', error)
      } finally {
        this.token = ''
        this.userInfo = null
        this.isLoggedIn = false
        localStorage.removeItem('token')
      }
    },
    
    async fetchUserInfo() {
      try {
        const response = await getUserInfo()
        this.userInfo = response.data
      } catch (error) {
        console.error('Fetch user info error:', error)
      }
    },
    
    init() {
      if (this.token) {
        this.isLoggedIn = true
        this.fetchUserInfo()
      }
    }
  }
})