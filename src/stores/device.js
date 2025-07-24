import { defineStore } from 'pinia'

export const useDeviceStore = defineStore('device', {
  state: () => ({
    isMobile: false,
    screenWidth: 0
  }),
  
  actions: {
    updateDevice() {
      this.screenWidth = window.innerWidth
      this.isMobile = window.innerWidth <= 768
    },
    
    init() {
      this.updateDevice()
      window.addEventListener('resize', this.updateDevice)
    }
  }
})