<template>
  <div class="cart-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="container">
        <h1>购物车</h1>
        <p>管理您的课程订单</p>
      </div>
    </div>

    <div class="container">
      <div v-if="!isLoggedIn" class="login-prompt">
        <div class="prompt-content">
          <el-icon size="64" color="#ccc"><ShoppingCart /></el-icon>
          <h3>请先登录查看购物车</h3>
          <p>登录后可以查看和管理您的课程订单</p>
          <el-button type="primary" size="large" @click="goToLogin">
            立即登录
          </el-button>
        </div>
      </div>

      <div v-else-if="cartItems.length === 0" class="empty-cart">
        <div class="empty-content">
          <el-icon size="64" color="#ccc"><ShoppingCart /></el-icon>
          <h3>购物车是空的</h3>
          <p>快去选择您感兴趣的课程吧</p>
          <el-button type="primary" size="large" @click="goToCourses">
            浏览课程
          </el-button>
        </div>
      </div>

      <div v-else class="cart-content">
        <div class="cart-layout">
          <!-- 购物车列表 -->
          <div class="cart-list">
            <div class="cart-header">
              <el-checkbox
                v-model="selectAll"
                :indeterminate="isIndeterminate"
                @change="handleSelectAll"
              >
                全选
              </el-checkbox>
              <span class="item-count">共 {{ cartItems.length }} 件商品</span>
              <el-button
                type="danger"
                text
                :disabled="selectedItems.length === 0"
                @click="handleBatchDelete"
              >
                <el-icon><Delete /></el-icon>
                删除选中
              </el-button>
            </div>

            <div class="cart-items">
              <div
                v-for="item in cartItems"
                :key="item.id"
                class="cart-item"
                :class="{ selected: selectedItems.includes(item.id) }"
              >
                <div class="item-checkbox">
                  <el-checkbox
                    :model-value="selectedItems.includes(item.id)"
                    @change="(checked) => handleItemSelect(item.id, checked)"
                  />
                </div>

                <div class="item-image">
                  <img :src="item.image" :alt="item.title" />
                  <div v-if="item.isLive" class="live-badge">直播</div>
                </div>

                <div class="item-info">
                  <h3 class="item-title">{{ item.title }}</h3>
                  <p class="item-instructor">讲师：{{ item.instructor }}</p>
                  <div class="item-tags">
                    <el-tag v-if="item.difficulty" size="small" type="info">
                      {{ getDifficultyLabel(item.difficulty) }}
                    </el-tag>
                    <el-tag v-if="item.duration" size="small">
                      {{ item.duration }}
                    </el-tag>
                    <el-tag v-if="item.category" size="small" type="success">
                      {{ item.category }}
                    </el-tag>
                  </div>
                  
                  <!-- 课程特色 -->
                  <div v-if="item.features && item.features.length > 0" class="item-features">
                    <span
                      v-for="feature in item.features"
                      :key="feature"
                      class="feature-tag"
                    >
                      {{ feature }}
                    </span>
                  </div>
                </div>

                <div class="item-price">
                  <div class="current-price">¥{{ item.currentPrice }}</div>
                  <div v-if="item.originalPrice > item.currentPrice" class="original-price">
                    ¥{{ item.originalPrice }}
                  </div>
                  <div v-if="item.discount" class="discount-info">
                    {{ item.discount }}折
                  </div>
                </div>

                <div class="item-actions">
                  <div class="quantity-control">
                    <el-input-number
                      v-model="item.quantity"
                      :min="1"
                      :max="10"
                      size="small"
                      @change="updateQuantity(item.id, $event)"
                    />
                  </div>
                  
                  <div class="action-buttons">
                    <el-button
                      size="small"
                      @click="moveToWishlist(item.id)"
                    >
                      <el-icon><Star /></el-icon>
                      移至收藏
                    </el-button>
                    <el-button
                      size="small"
                      type="danger"
                      text
                      @click="removeItem(item.id)"
                    >
                      <el-icon><Delete /></el-icon>
                      删除
                    </el-button>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- 订单摘要 -->
          <div class="order-summary">
            <div class="summary-card">
              <h3>订单摘要</h3>
              
              <div class="summary-details">
                <div class="detail-row">
                  <span>商品数量</span>
                  <span>{{ selectedItemsCount }} 件</span>
                </div>
                <div class="detail-row">
                  <span>商品总价</span>
                  <span>¥{{ originalTotal.toFixed(2) }}</span>
                </div>
                <div v-if="discountAmount > 0" class="detail-row discount">
                  <span>优惠金额</span>
                  <span>-¥{{ discountAmount.toFixed(2) }}</span>
                </div>
                <div class="detail-row total">
                  <span>应付总额</span>
                  <span class="total-price">¥{{ finalTotal.toFixed(2) }}</span>
                </div>
              </div>

              <!-- 优惠券 -->
              <div class="coupon-section">
                <h4>优惠券</h4>
                <div class="coupon-selector">
                  <el-select
                    v-model="selectedCoupon"
                    placeholder="选择优惠券"
                    clearable
                    @change="applyCoupon"
                  >
                    <el-option
                      v-for="coupon in availableCoupons"
                      :key="coupon.id"
                      :label="coupon.name"
                      :value="coupon.id"
                      :disabled="!coupon.applicable"
                    >
                      <div class="coupon-option">
                        <span class="coupon-name">{{ coupon.name }}</span>
                        <span class="coupon-desc">{{ coupon.description }}</span>
                      </div>
                    </el-option>
                  </el-select>
                </div>
              </div>

              <!-- 结算按钮 -->
              <div class="checkout-section">
                <el-button
                  type="primary"
                  size="large"
                  :disabled="selectedItems.length === 0"
                  :loading="checkoutLoading"
                  @click="handleCheckout"
                  block
                >
                  立即结算 ({{ selectedItemsCount }})
                </el-button>
                
                <div class="payment-methods">
                  <span>支持支付方式：</span>
                  <div class="payment-icons">
                    <el-icon><CreditCard /></el-icon>
                    <el-icon><Wallet /></el-icon>
                    <span>微信</span>
                    <span>支付宝</span>
                  </div>
                </div>
              </div>
            </div>

            <!-- 推荐课程 -->
            <div class="recommended-courses">
              <h3>推荐课程</h3>
              <div class="course-list">
                <div
                  v-for="course in recommendedCourses"
                  :key="course.id"
                  class="course-item"
                  @click="viewCourse(course.id)"
                >
                  <img :src="course.image" :alt="course.title" />
                  <div class="course-info">
                    <h4>{{ course.title }}</h4>
                    <p class="course-price">¥{{ course.price }}</p>
                    <el-button size="small" type="primary" @click.stop="addToCart(course.id)">
                      加入购物车
                    </el-button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 删除确认对话框 -->
    <el-dialog
      v-model="showDeleteDialog"
      title="确认删除"
      width="400px"
      center
    >
      <p>确定要删除选中的课程吗？</p>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showDeleteDialog = false">取消</el-button>
          <el-button type="danger" @click="confirmDelete">确定删除</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  ShoppingCart, Delete, Star, CreditCard, Wallet
} from '@element-plus/icons-vue'

const router = useRouter()

// 响应式数据
const checkoutLoading = ref(false)
const showDeleteDialog = ref(false)
const selectedItems = ref([])
const selectedCoupon = ref('')
const deleteTarget = ref(null) // 'single' | 'batch'
const deleteItemId = ref(null)

// 登录状态
const isLoggedIn = computed(() => localStorage.getItem('isLoggedIn'))

// 购物车数据
const cartItems = ref([
  {
    id: 1,
    title: 'AutoCAD 2024 建筑制图完全教程',
    instructor: '张建筑师',
    image: '/courses/autocad-2024.jpg',
    currentPrice: 299,
    originalPrice: 399,
    discount: 7.5,
    quantity: 1,
    duration: '40小时',
    difficulty: 'beginner',
    category: '建筑设计',
    isLive: false,
    features: ['终身访问', '课件下载', '作业批改']
  },
  {
    id: 2,
    title: 'Revit 建筑信息建模实战',
    instructor: '李工程师',
    image: '/courses/revit-bim.jpg',
    currentPrice: 399,
    originalPrice: 499,
    discount: 8,
    quantity: 1,
    duration: '35小时',
    difficulty: 'intermediate',
    category: 'BIM技术',
    isLive: true,
    features: ['直播互动', '项目实战', '证书认证']
  },
  {
    id: 3,
    title: 'SketchUp 建筑草图设计',
    instructor: '王设计师',
    image: '/courses/sketchup-design.jpg',
    currentPrice: 199,
    originalPrice: 199,
    quantity: 2,
    duration: '25小时',
    difficulty: 'beginner',
    category: '概念设计',
    isLive: false,
    features: ['案例丰富', '软件赠送']
  }
])

// 可用优惠券
const availableCoupons = ref([
  {
    id: 1,
    name: '新用户专享',
    description: '满300减50',
    discount: 50,
    minAmount: 300,
    applicable: true
  },
  {
    id: 2,
    name: '建筑专业券',
    description: '建筑类课程9折',
    discount: 0.9,
    type: 'percentage',
    applicable: true
  },
  {
    id: 3,
    name: '限时优惠',
    description: '满500减100',
    discount: 100,
    minAmount: 500,
    applicable: false
  }
])

// 推荐课程
const recommendedCourses = ref([
  {
    id: 101,
    title: '3ds Max 建筑渲染',
    image: '/courses/3dsmax-render.jpg',
    price: 349
  },
  {
    id: 102,
    title: 'Lumion 建筑动画',
    image: '/courses/lumion-animation.jpg',
    price: 279
  },
  {
    id: 103,
    title: 'Photoshop 建筑后期',
    image: '/courses/ps-architecture.jpg',
    price: 199
  }
])

// 计算属性
const selectAll = computed({
  get() {
    return selectedItems.value.length === cartItems.value.length && cartItems.value.length > 0
  },
  set(value) {
    if (value) {
      selectedItems.value = cartItems.value.map(item => item.id)
    } else {
      selectedItems.value = []
    }
  }
})

const isIndeterminate = computed(() => {
  return selectedItems.value.length > 0 && selectedItems.value.length < cartItems.value.length
})

const selectedItemsCount = computed(() => {
  return cartItems.value
    .filter(item => selectedItems.value.includes(item.id))
    .reduce((total, item) => total + item.quantity, 0)
})

const originalTotal = computed(() => {
  return cartItems.value
    .filter(item => selectedItems.value.includes(item.id))
    .reduce((total, item) => total + (item.currentPrice * item.quantity), 0)
})

const discountAmount = computed(() => {
  if (!selectedCoupon.value) return 0
  
  const coupon = availableCoupons.value.find(c => c.id === selectedCoupon.value)
  if (!coupon) return 0
  
  if (coupon.type === 'percentage') {
    return originalTotal.value * (1 - coupon.discount)
  } else {
    return originalTotal.value >= coupon.minAmount ? coupon.discount : 0
  }
})

const finalTotal = computed(() => {
  return Math.max(0, originalTotal.value - discountAmount.value)
})

// 方法
const handleSelectAll = (checked) => {
  if (checked) {
    selectedItems.value = cartItems.value.map(item => item.id)
  } else {
    selectedItems.value = []
  }
}

const handleItemSelect = (itemId, checked) => {
  if (checked) {
    selectedItems.value.push(itemId)
  } else {
    const index = selectedItems.value.indexOf(itemId)
    if (index > -1) {
      selectedItems.value.splice(index, 1)
    }
  }
}

const updateQuantity = (itemId, quantity) => {
  const item = cartItems.value.find(item => item.id === itemId)
  if (item) {
    item.quantity = quantity
    ElMessage.success('数量已更新')
  }
}

const removeItem = (itemId) => {
  deleteTarget.value = 'single'
  deleteItemId.value = itemId
  showDeleteDialog.value = true
}

const handleBatchDelete = () => {
  if (selectedItems.value.length === 0) {
    ElMessage.warning('请先选择要删除的课程')
    return
  }
  deleteTarget.value = 'batch'
  showDeleteDialog.value = true
}

const confirmDelete = () => {
  if (deleteTarget.value === 'single') {
    const index = cartItems.value.findIndex(item => item.id === deleteItemId.value)
    if (index > -1) {
      cartItems.value.splice(index, 1)
      // 从选中列表中移除
      const selectedIndex = selectedItems.value.indexOf(deleteItemId.value)
      if (selectedIndex > -1) {
        selectedItems.value.splice(selectedIndex, 1)
      }
      ElMessage.success('课程已删除')
    }
  } else if (deleteTarget.value === 'batch') {
    cartItems.value = cartItems.value.filter(item => !selectedItems.value.includes(item.id))
    selectedItems.value = []
    ElMessage.success('选中课程已删除')
  }
  
  showDeleteDialog.value = false
  deleteTarget.value = null
  deleteItemId.value = null
}

const moveToWishlist = async (itemId) => {
  try {
    // 模拟移至收藏
    await new Promise(resolve => setTimeout(resolve, 500))
    
    const item = cartItems.value.find(item => item.id === itemId)
    if (item) {
      // 从购物车中移除
      const index = cartItems.value.findIndex(item => item.id === itemId)
      cartItems.value.splice(index, 1)
      
      // 从选中列表中移除
      const selectedIndex = selectedItems.value.indexOf(itemId)
      if (selectedIndex > -1) {
        selectedItems.value.splice(selectedIndex, 1)
      }
      
      ElMessage.success(`《${item.title}》已移至收藏夹`)
    }
  } catch (error) {
    ElMessage.error('操作失败，请重试')
  }
}

const applyCoupon = (couponId) => {
  if (!couponId) {
    ElMessage.info('已取消使用优惠券')
    return
  }
  
  const coupon = availableCoupons.value.find(c => c.id === couponId)
  if (coupon && coupon.applicable) {
    if (coupon.minAmount && originalTotal.value < coupon.minAmount) {
      ElMessage.warning(`订单金额需满 ¥${coupon.minAmount} 才能使用此优惠券`)
      selectedCoupon.value = ''
      return
    }
    ElMessage.success(`已应用优惠券：${coupon.name}`)
  }
}

const handleCheckout = async () => {
  if (selectedItems.value.length === 0) {
    ElMessage.warning('请选择要结算的课程')
    return
  }
  
  checkoutLoading.value = true
  
  try {
    // 模拟结算过程
    await new Promise(resolve => setTimeout(resolve, 2000))
    
    ElMessage.success('订单创建成功，正在跳转到支付页面...')
    
    // 这里可以跳转到支付页面
    setTimeout(() => {
      ElMessage.info('跳转到支付页面（模拟）')
    }, 1000)
    
  } catch (error) {
    ElMessage.error('结算失败，请重试')
  } finally {
    checkoutLoading.value = false
  }
}

const addToCart = async (courseId) => {
  try {
    // 模拟添加到购物车
    await new Promise(resolve => setTimeout(resolve, 500))
    ElMessage.success('课程已添加到购物车')
  } catch (error) {
    ElMessage.error('添加失败，请重试')
  }
}

const viewCourse = (courseId) => {
  router.push(`/course/${courseId}`)
}

const goToLogin = () => {
  router.push('/login')
}

const goToCourses = () => {
  router.push('/courses')
}

const getDifficultyLabel = (difficulty) => {
  const labels = {
    beginner: '入门',
    intermediate: '进阶',
    advanced: '高级'
  }
  return labels[difficulty] || difficulty
}

onMounted(() => {
  // 初始化时选中所有商品
  if (isLoggedIn.value && cartItems.value.length > 0) {
    selectedItems.value = cartItems.value.map(item => item.id)
  }
})
</script>

<style lang="scss" scoped>
.cart-page {
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

.login-prompt,
.empty-cart {
  padding: 80px 0;
  text-align: center;
  
  .prompt-content,
  .empty-content {
    background: white;
    border-radius: 12px;
    padding: 60px 40px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
    max-width: 400px;
    margin: 0 auto;
    
    h3 {
      font-size: 1.5rem;
      color: #333;
      margin: 20px 0 10px;
    }
    
    p {
      color: #666;
      margin-bottom: 30px;
    }
  }
}

.cart-content {
  padding: 30px 0;
  
  .cart-layout {
    display: grid;
    grid-template-columns: 1fr 350px;
    gap: 30px;
  }
}

.cart-list {
  .cart-header {
    background: white;
    border-radius: 12px 12px 0 0;
    padding: 20px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-bottom: 1px solid #f0f0f0;
    
    .item-count {
      color: #666;
      font-size: 14px;
    }
  }
  
  .cart-items {
    background: white;
    border-radius: 0 0 12px 12px;
    
    .cart-item {
      display: grid;
      grid-template-columns: 40px 120px 1fr 120px 150px;
      gap: 20px;
      padding: 20px;
      border-bottom: 1px solid #f0f0f0;
      transition: all 0.3s ease;
      
      &:last-child {
        border-bottom: none;
      }
      
      &:hover {
        background: #f8f9fa;
      }
      
      &.selected {
        background: #f0f9ff;
      }
      
      .item-checkbox {
        display: flex;
        align-items: center;
      }
      
      .item-image {
        position: relative;
        
        img {
          width: 100%;
          height: 80px;
          object-fit: cover;
          border-radius: 8px;
        }
        
        .live-badge {
          position: absolute;
          top: 5px;
          left: 5px;
          background: #ff4d4f;
          color: white;
          padding: 2px 6px;
          border-radius: 4px;
          font-size: 10px;
        }
      }
      
      .item-info {
        .item-title {
          font-size: 16px;
          font-weight: 600;
          color: #333;
          margin-bottom: 8px;
          line-height: 1.4;
        }
        
        .item-instructor {
          color: #666;
          font-size: 14px;
          margin-bottom: 8px;
        }
        
        .item-tags {
          display: flex;
          gap: 6px;
          margin-bottom: 8px;
        }
        
        .item-features {
          display: flex;
          flex-wrap: wrap;
          gap: 6px;
          
          .feature-tag {
            background: #f0f9ff;
            color: #1890ff;
            padding: 2px 6px;
            border-radius: 4px;
            font-size: 12px;
          }
        }
      }
      
      .item-price {
        text-align: right;
        
        .current-price {
          font-size: 18px;
          font-weight: 600;
          color: #ff4d4f;
          margin-bottom: 5px;
        }
        
        .original-price {
          font-size: 14px;
          color: #999;
          text-decoration: line-through;
          margin-bottom: 5px;
        }
        
        .discount-info {
          font-size: 12px;
          color: #52c41a;
        }
      }
      
      .item-actions {
        display: flex;
        flex-direction: column;
        gap: 10px;
        
        .quantity-control {
          :deep(.el-input-number) {
            width: 100%;
            
            .el-input__inner {
              text-align: center;
            }
          }
        }
        
        .action-buttons {
          display: flex;
          flex-direction: column;
          gap: 5px;
          
          .el-button {
            padding: 5px 8px;
            font-size: 12px;
          }
        }
      }
    }
  }
}

.order-summary {
  .summary-card,
  .recommended-courses {
    background: white;
    border-radius: 12px;
    padding: 20px;
    margin-bottom: 20px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  }
  
  .summary-card {
    h3 {
      font-size: 18px;
      font-weight: 600;
      color: #333;
      margin-bottom: 20px;
    }
    
    .summary-details {
      .detail-row {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 10px 0;
        border-bottom: 1px solid #f0f0f0;
        
        &:last-child {
          border-bottom: none;
        }
        
        &.discount {
          color: #52c41a;
        }
        
        &.total {
          font-size: 16px;
          font-weight: 600;
          color: #333;
          padding-top: 15px;
          border-top: 2px solid #f0f0f0;
          
          .total-price {
            font-size: 20px;
            color: #ff4d4f;
          }
        }
      }
    }
    
    .coupon-section {
      margin: 20px 0;
      
      h4 {
        font-size: 14px;
        font-weight: 600;
        color: #333;
        margin-bottom: 10px;
      }
      
      .coupon-option {
        display: flex;
        flex-direction: column;
        
        .coupon-name {
          font-weight: 500;
        }
        
        .coupon-desc {
          font-size: 12px;
          color: #999;
        }
      }
    }
    
    .checkout-section {
      margin-top: 20px;
      
      .payment-methods {
        margin-top: 15px;
        text-align: center;
        font-size: 12px;
        color: #666;
        
        .payment-icons {
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 8px;
          margin-top: 5px;
          
          .el-icon {
            font-size: 16px;
          }
        }
      }
    }
  }
  
  .recommended-courses {
    h3 {
      font-size: 16px;
      font-weight: 600;
      color: #333;
      margin-bottom: 15px;
    }
    
    .course-list {
      .course-item {
        display: flex;
        gap: 10px;
        padding: 10px 0;
        border-bottom: 1px solid #f0f0f0;
        cursor: pointer;
        transition: background-color 0.2s ease;
        
        &:last-child {
          border-bottom: none;
        }
        
        &:hover {
          background: #f8f9fa;
        }
        
        img {
          width: 60px;
          height: 45px;
          object-fit: cover;
          border-radius: 6px;
        }
        
        .course-info {
          flex: 1;
          
          h4 {
            font-size: 14px;
            font-weight: 500;
            color: #333;
            margin-bottom: 5px;
            line-height: 1.3;
          }
          
          .course-price {
            font-size: 14px;
            color: #ff4d4f;
            font-weight: 600;
            margin-bottom: 8px;
          }
          
          .el-button {
            padding: 4px 8px;
            font-size: 12px;
          }
        }
      }
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
  
  .cart-layout {
    grid-template-columns: 1fr !important;
    gap: 20px !important;
  }
  
  .cart-item {
    grid-template-columns: 30px 80px 1fr !important;
    gap: 10px !important;
    
    .item-price,
    .item-actions {
      grid-column: 2 / -1 !important;
      margin-top: 10px !important;
    }
    
    .item-price {
      text-align: left !important;
    }
    
    .item-actions {
      flex-direction: row !important;
      align-items: center !important;
      
      .quantity-control {
        width: 100px !important;
      }
      
      .action-buttons {
        flex-direction: row !important;
        flex: 1 !important;
        justify-content: flex-end !important;
      }
    }
  }
  
  .cart-header {
    flex-direction: column !important;
    gap: 10px !important;
    align-items: stretch !important;
  }
}
</style>