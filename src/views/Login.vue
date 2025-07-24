<template>
  <div class="auth-page">
    <div class="auth-container">
      <div class="auth-card">
        <!-- Logo 和标题 -->
        <div class="auth-header">
          <img src="/logo.svg" alt="解构建筑小教室" class="logo" />
          <h2>{{ isRegisterMode ? '完善信息' : '欢迎使用' }}</h2>
          <p>{{ isRegisterMode ? '请完善您的注册信息' : '请输入手机号登录或注册' }}</p>
        </div>

        <!-- 统一的认证表单 -->
        <el-form
          ref="authFormRef"
          :model="authForm"
          :rules="authRules"
          class="auth-form"
          @submit.prevent="handleAuth"
        >
          <!-- 手机号输入 -->
          <el-form-item prop="phone">
            <el-input
              v-model="authForm.phone"
              placeholder="请输入手机号"
              size="large"
              :prefix-icon="Phone"
              :disabled="isRegisterMode"
            />
          </el-form-item>

          <!-- 验证码输入 -->
          <el-form-item prop="verifyCode">
            <div class="code-input">
              <el-input
                v-model="authForm.verifyCode"
                placeholder="请输入验证码"
                size="large"
                :prefix-icon="Message"
              />
              <el-button
                size="large"
                :disabled="codeCountdown > 0 || !authForm.phone"
                @click="sendVerifyCode"
              >
                {{ codeCountdown > 0 ? `${codeCountdown}s后重发` : '发送验证码' }}
              </el-button>
            </div>
          </el-form-item>

          <!-- 注册模式下的额外字段 -->
          <template v-if="isRegisterMode">
            <el-form-item prop="username">
              <el-input
                v-model="authForm.username"
                placeholder="请输入用户名"
                size="large"
                :prefix-icon="User"
              />
            </el-form-item>

            <el-form-item prop="email">
              <el-input
                v-model="authForm.email"
                placeholder="请输入邮箱（可选）"
                size="large"
                :prefix-icon="Message"
              />
            </el-form-item>

            <el-form-item prop="agreement">
              <el-checkbox v-model="authForm.agreement">
                我已阅读并同意
                <el-link type="primary" @click="showTerms = true">《用户协议》</el-link>
                和
                <el-link type="primary" @click="showPrivacy = true">《隐私政策》</el-link>
              </el-checkbox>
            </el-form-item>
          </template>

          <!-- 登录模式下的选项 -->
          <template v-else>
            <el-form-item>
              <div class="login-options">
                <el-checkbox v-model="authForm.remember">记住我</el-checkbox>
              </div>
            </el-form-item>
          </template>

          <el-form-item>
            <el-button
              type="primary"
              size="large"
              class="auth-btn"
              :loading="loading"
              @click="handleAuth"
            >
              {{ isRegisterMode ? '完成注册' : '登录/注册' }}
            </el-button>
          </el-form-item>

          <!-- 返回按钮（注册模式下显示） -->
          <el-form-item v-if="isRegisterMode">
            <el-button
              size="large"
              class="back-btn"
              @click="resetToLoginMode"
            >
              返回登录
            </el-button>
          </el-form-item>
        </el-form>

        <!-- 其他登录方式 -->
        <div v-if="!isRegisterMode" class="other-auth">
          <div class="divider">
            <span>或</span>
          </div>
          <div class="social-auth">
            <el-button class="social-btn wechat" @click="handleSocialAuth('wechat')">
              <img src="/icons/wechat-icon.svg" alt="微信" />
              微信登录
            </el-button>
            <el-button class="social-btn qq" @click="handleSocialAuth('qq')">
              <img src="/icons/qq.svg" alt="QQ" />
              QQ登录
            </el-button>
          </div>
        </div>
      </div>
    </div>

    <!-- 用户协议对话框 -->
    <el-dialog
      v-model="showTerms"
      title="用户协议"
      width="600px"
      :before-close="handleCloseTerms"
    >
      <div class="terms-content">
        <h3>1. 服务条款</h3>
        <p>欢迎使用解构建筑小教室在线学习平台。在使用我们的服务前，请仔细阅读本用户协议。</p>
        
        <h3>2. 账户注册</h3>
        <p>用户需要提供真实、准确的个人信息进行注册。用户对账户安全负责，不得将账户转让给他人使用。</p>
        
        <h3>3. 服务使用</h3>
        <p>用户应当合法使用平台服务，不得进行任何违法违规行为，包括但不限于传播不良信息、侵犯他人权益等。</p>
        
        <h3>4. 知识产权</h3>
        <p>平台上的所有课程内容、教学资料等均受知识产权保护，用户仅可用于个人学习，不得用于商业用途。</p>
        
        <h3>5. 免责声明</h3>
        <p>平台对服务的及时性、安全性、准确性不作担保，用户使用服务产生的风险由用户自行承担。</p>
      </div>
      <template #footer>
        <el-button @click="showTerms = false">关闭</el-button>
      </template>
    </el-dialog>

    <!-- 隐私政策对话框 -->
    <el-dialog
      v-model="showPrivacy"
      title="隐私政策"
      width="600px"
      :before-close="handleClosePrivacy"
    >
      <div class="privacy-content">
        <h3>1. 信息收集</h3>
        <p>我们会收集您在注册和使用服务过程中提供的个人信息，包括姓名、手机号、邮箱等。</p>
        
        <h3>2. 信息使用</h3>
        <p>我们使用收集的信息来提供、维护和改进我们的服务，包括课程推荐、学习进度跟踪等。</p>
        
        <h3>3. 信息保护</h3>
        <p>我们采用行业标准的安全措施保护您的个人信息，防止未经授权的访问、使用或泄露。</p>
        
        <h3>4. 信息共享</h3>
        <p>除法律要求外，我们不会向第三方出售、出租或以其他方式披露您的个人信息。</p>
        
        <h3>5. Cookie使用</h3>
        <p>我们使用Cookie来改善用户体验，您可以通过浏览器设置管理Cookie偏好。</p>
      </div>
      <template #footer>
        <el-button @click="showPrivacy = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { User, Lock, Phone, Message } from '@element-plus/icons-vue'

const router = useRouter()

// 状态管理
const isRegisterMode = ref(false)
const loading = ref(false)
const codeCountdown = ref(0)
const showTerms = ref(false)
const showPrivacy = ref(false)
const authFormRef = ref()

// 表单数据
const authForm = reactive({
  phone: '',
  verifyCode: '',
  username: '',
  email: '',
  remember: false,
  agreement: false
})

// 动态验证规则
const authRules = computed(() => {
  const baseRules = {
    phone: [
      { required: true, message: '请输入手机号', trigger: 'blur' },
      {
        pattern: /^1[3-9]\d{9}$/,
        message: '请输入正确的手机号格式',
        trigger: 'blur'
      }
    ],
    verifyCode: [
      { required: true, message: '请输入验证码', trigger: 'blur' },
      { len: 6, message: '验证码为6位数字', trigger: 'blur' }
    ]
  }

  if (isRegisterMode.value) {
    return {
      ...baseRules,
      username: [
        { required: true, message: '请输入用户名', trigger: 'blur' },
        { min: 2, max: 20, message: '用户名长度在2-20个字符', trigger: 'blur' },
        {
          pattern: /^[a-zA-Z0-9\u4e00-\u9fa5_-]+$/,
          message: '用户名只能包含字母、数字、中文、下划线和连字符',
          trigger: 'blur'
        }
      ],
      email: [
        {
          type: 'email',
          message: '请输入正确的邮箱格式',
          trigger: 'blur'
        }
      ],
      agreement: [
        {
          validator: (rule, value, callback) => {
            if (!value) {
              callback(new Error('请阅读并同意用户协议和隐私政策'))
            } else {
              callback()
            }
          },
          trigger: 'change'
        }
      ]
    }
  }

  return baseRules
})

// 发送验证码
const sendVerifyCode = async () => {
  if (!authForm.phone) {
    ElMessage.warning('请先输入手机号')
    return
  }
  
  if (!/^1[3-9]\d{9}$/.test(authForm.phone)) {
    ElMessage.warning('请输入正确的手机号格式')
    return
  }
  
  try {
    // 模拟API调用检查手机号是否已注册
    await new Promise(resolve => setTimeout(resolve, 500))
    
    // 模拟：随机决定是否已注册（实际应该调用API）
    const isRegistered = Math.random() > 0.5
    
    if (!isRegistered && !isRegisterMode.value) {
      // 手机号未注册，切换到注册模式
      isRegisterMode.value = true
      ElMessage.info('检测到该手机号未注册，请完善注册信息')
    }
    
    // 开始倒计时
    codeCountdown.value = 60
    const timer = setInterval(() => {
      codeCountdown.value--
      if (codeCountdown.value <= 0) {
        clearInterval(timer)
      }
    }, 1000)
    
    ElMessage.success('验证码已发送到您的手机')
    
  } catch (error) {
    console.error('发送验证码失败:', error)
    ElMessage.error('发送验证码失败，请重试')
  }
}

// 统一的认证处理
const handleAuth = async () => {
  if (!authFormRef.value) return
  
  try {
    await authFormRef.value.validate()
    loading.value = true
    
    // 模拟API调用
    await new Promise(resolve => setTimeout(resolve, 1500))
    
    if (isRegisterMode.value) {
      // 注册流程
      ElMessage.success('注册成功！正在为您登录...')
    } else {
      // 登录流程
      ElMessage.success('登录成功！')
    }
    
    // 保存登录状态
    const userInfo = {
      phone: authForm.phone,
      username: authForm.username || '用户' + Math.floor(Math.random() * 1000),
      email: authForm.email || '',
      avatar: '/default-avatar.svg',
      loginTime: new Date().toISOString()
    }
    localStorage.setItem('userInfo', JSON.stringify(userInfo))
    localStorage.setItem('isLoggedIn', 'true')
    
    // 跳转到首页或之前的页面
    const redirect = router.currentRoute.value.query.redirect || '/'
    router.push(redirect)
    
  } catch (error) {
    console.error('认证失败:', error)
    ElMessage.error(isRegisterMode.value ? '注册失败，请重试' : '登录失败，请检查验证码')
  } finally {
    loading.value = false
  }
}

// 重置到登录模式
const resetToLoginMode = () => {
  isRegisterMode.value = false
  // 清空注册相关字段
  authForm.username = ''
  authForm.email = ''
  authForm.agreement = false
  // 保留手机号和验证码
}

// 社交登录
const handleSocialAuth = (type) => {
  ElMessage.info(`${type === 'wechat' ? '微信' : 'QQ'}登录功能开发中...`)
}

const handleCloseTerms = () => {
  showTerms.value = false
}

const handleClosePrivacy = () => {
  showPrivacy.value = false
}
</script>

<style lang="scss" scoped>
.auth-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.auth-container {
  width: 100%;
  max-width: 450px;
}

.auth-card {
  background: white;
  border-radius: 12px;
  padding: 40px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

.auth-header {
  text-align: center;
  margin-bottom: 30px;
  
  .logo {
    height: 50px;
    margin-bottom: 20px;
  }
  
  h2 {
    color: #333;
    margin-bottom: 8px;
    font-size: 24px;
    font-weight: 600;
    transition: all 0.3s ease;
  }
  
  p {
    color: #666;
    font-size: 14px;
    transition: all 0.3s ease;
  }
}

.auth-form {
  .el-form-item {
    margin-bottom: 20px;
  }
  
  .code-input {
    display: flex;
    gap: 10px;
    
    .el-input {
      flex: 1;
    }
    
    .el-button {
      white-space: nowrap;
    }
  }
  
  .login-options {
    display: flex;
    justify-content: space-between;
    align-items: center;
    width: 100%;
  }
  
  .auth-btn {
    width: 100%;
    height: 44px;
    font-size: 16px;
    font-weight: 500;
  }
  
  .back-btn {
    width: 100%;
    height: 40px;
    margin-top: 10px;
  }
}

.other-auth {
  margin: 30px 0 0 0;
  
  .divider {
    text-align: center;
    position: relative;
    margin-bottom: 20px;
    
    &::before {
      content: '';
      position: absolute;
      top: 50%;
      left: 0;
      right: 0;
      height: 1px;
      background: #e4e7ed;
    }
    
    span {
      background: white;
      padding: 0 15px;
      color: #909399;
      font-size: 14px;
    }
  }
  
  .social-auth {
    display: flex;
    gap: 12px;
    
    .social-btn {
      flex: 1;
      height: 40px;
      border: 1px solid #dcdfe6;
      background: white;
      color: #606266;
      
      img {
        width: 18px;
        height: 18px;
        margin-right: 6px;
      }
      
      &:hover {
        border-color: #409eff;
        color: #409eff;
      }
    }
  }
}

.terms-content,
.privacy-content {
  max-height: 400px;
  overflow-y: auto;
  
  h3 {
    color: #333;
    margin: 20px 0 10px 0;
    font-size: 16px;
    
    &:first-child {
      margin-top: 0;
    }
  }
  
  p {
    color: #666;
    line-height: 1.6;
    margin-bottom: 15px;
  }
}

// 响应式设计
@media (max-width: 480px) {
  .auth-page {
    padding: 10px;
  }
  
  .auth-card {
    padding: 30px 20px;
  }
  
  .social-auth {
    flex-direction: column;
  }
  
  .code-input {
    flex-direction: column;
    
    .el-button {
      margin-top: 10px;
    }
  }
}
</style>