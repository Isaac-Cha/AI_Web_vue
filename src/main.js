import { createApp } from 'vue'
import { createPinia } from 'pinia'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'
import zhCn from 'element-plus/dist/locale/zh-cn.mjs'
import { inject } from '@vercel/analytics'

// 导入全局样式
import './styles/index.scss'

import App from './App.vue'
import router from './router'
import { useDeviceStore } from './stores/device'

const app = createApp(App)

// 注册所有图标
for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
  app.component(key, component)
}

const pinia = createPinia()
app.use(pinia)
app.use(router)
app.use(ElementPlus, {
  locale: zhCn,
})

// 初始化device store
const deviceStore = useDeviceStore()
deviceStore.init()

// 初始化Vercel Analytics
inject()

app.mount('#app')