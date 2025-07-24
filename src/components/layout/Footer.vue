<template>
  <footer class="footer">
    <div class="container">
      <!-- PC端布局 -->
      <div v-if="!isMobile" class="footer-content">
        <div class="footer-section">
          <h3>关于我们</h3>
          <ul>
            <li><a href="/about">公司介绍</a></li>
            <li><a href="/team">师资团队</a></li>
            <li><a href="/contact">联系我们</a></li>
            <li><a href="/jobs">招聘信息</a></li>
          </ul>
        </div>
        
        <div class="footer-section">
          <h3>学习服务</h3>
          <ul>
            <li><a href="/courses">课程中心</a></li>
            <li><a href="/free">免费资源</a></li>
            <li><a href="/live">直播课程</a></li>
            <li><a href="/community">学习社区</a></li>
          </ul>
        </div>
        
        <div class="footer-section">
          <h3>用户服务</h3>
          <ul>
            <li><a href="/help">帮助中心</a></li>
            <li><a href="/privacy">隐私政策</a></li>
            <li><a href="/terms">服务条款</a></li>
            <li><a href="/feedback">意见反馈</a></li>
          </ul>
        </div>
        
        <div class="footer-section contact-info">
          <h3>联系方式</h3>
          <div class="contact-item">
            <el-icon><Phone /></el-icon>
            <span>400-123-4567</span>
          </div>
          <div class="contact-item">
            <el-icon><Message /></el-icon>
            <span>service@jiegoujianzhu.com</span>
          </div>
          <div class="social-links">
            <a href="#" class="social-link">
              <img src="/icons/wechat-icon.svg" alt="微信" />
            </a>
            <a href="#" class="social-link">
              <img src="/icons/weibo.svg" alt="微博" />
            </a>
            <a href="#" class="social-link">
              <img src="/icons/qq.svg" alt="QQ" />
            </a>
          </div>
        </div>
      </div>
      
      <!-- 移动端布局 -->
      <div v-else class="mobile-footer">
        <div class="quick-links">
          <a href="/about">关于我们</a>
          <a href="/help">帮助中心</a>
          <a href="/contact">联系我们</a>
          <a href="/feedback">意见反馈</a>
        </div>
        
        <div class="contact-mobile">
          <div class="contact-item">
            <el-icon><Phone /></el-icon>
            <span>400-123-4567</span>
          </div>
          <div class="social-links">
            <a href="#" class="social-link">
              <img src="/icons/wechat-icon.svg" alt="微信" />
            </a>
            <a href="#" class="social-link">
              <img src="/icons/weibo.svg" alt="微博" />
            </a>
          </div>
        </div>
      </div>
      
      <!-- 版权信息 -->
      <div class="footer-bottom">
        <div class="copyright">
          <p>&copy; 2024 解构建筑小教室. All rights reserved.</p>
          <p>京ICP备12345678号-1 | 京公网安备11010802012345号</p>
        </div>
      </div>
    </div>
  </footer>
</template>

<script setup>
import { computed } from 'vue'
import { useDeviceStore } from '@/stores/device'
import { Phone, Message } from '@element-plus/icons-vue'

const deviceStore = useDeviceStore()
const isMobile = computed(() => deviceStore.isMobile)
</script>

<style lang="scss" scoped>
.footer {
  background: #2c3e50;
  color: #ecf0f1;
  margin-top: auto;
  
  .container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 40px 20px 20px;
  }
  
  .footer-content {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 40px;
    margin-bottom: 30px;
    
    .footer-section {
      h3 {
        color: #fff;
        margin-bottom: 20px;
        font-size: 16px;
        font-weight: 600;
      }
      
      ul {
        list-style: none;
        padding: 0;
        
        li {
          margin-bottom: 12px;
          
          a {
            color: #bdc3c7;
            text-decoration: none;
            transition: color 0.3s;
            
            &:hover {
              color: #3498db;
            }
          }
        }
      }
      
      &.contact-info {
        .contact-item {
          display: flex;
          align-items: center;
          margin-bottom: 15px;
          color: #bdc3c7;
          
          .el-icon {
            margin-right: 8px;
            color: #3498db;
          }
        }
        
        .social-links {
          display: flex;
          gap: 15px;
          margin-top: 20px;
          
          .social-link {
            img {
              width: 32px;
              height: 32px;
              transition: opacity 0.3s;
              
              &:hover {
                opacity: 0.8;
              }
            }
          }
        }
      }
    }
  }
  
  .mobile-footer {
    .quick-links {
      display: flex;
      flex-wrap: wrap;
      gap: 20px;
      margin-bottom: 25px;
      padding-bottom: 20px;
      border-bottom: 1px solid #34495e;
      
      a {
        color: #bdc3c7;
        text-decoration: none;
        font-size: 14px;
        
        &:hover {
          color: #3498db;
        }
      }
    }
    
    .contact-mobile {
      text-align: center;
      margin-bottom: 20px;
      
      .contact-item {
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 15px;
        color: #bdc3c7;
        
        .el-icon {
          margin-right: 8px;
          color: #3498db;
        }
      }
      
      .social-links {
        display: flex;
        justify-content: center;
        gap: 20px;
        
        .social-link {
          img {
            width: 28px;
            height: 28px;
          }
        }
      }
    }
  }
  
  .footer-bottom {
    border-top: 1px solid #34495e;
    padding-top: 20px;
    text-align: center;
    
    .copyright {
      p {
        margin: 5px 0;
        color: #95a5a6;
        font-size: 12px;
        
        @media (max-width: 768px) {
          font-size: 11px;
        }
      }
    }
  }
  
  @media (max-width: 768px) {
    .container {
      padding: 30px 15px 15px;
    }
  }
}
</style>