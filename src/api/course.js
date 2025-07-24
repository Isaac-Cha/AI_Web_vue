import request from '@/utils/request'

// 获取课程列表
export const getCourseList = (params) => {
  return request({
    url: '/courses',
    method: 'get',
    params
  })
}

// 获取课程详情
export const getCourseDetail = (id) => {
  return request({
    url: `/courses/${id}`,
    method: 'get'
  })
}

// 获取课程章节
export const getCourseChapters = (courseId) => {
  return request({
    url: `/courses/${courseId}/chapters`,
    method: 'get'
  })
}

// 获取免费资源
export const getFreeResources = (params) => {
  return request({
    url: '/resources/free',
    method: 'get',
    params
  })
}

// 获取直播课程
export const getLiveCourses = (params) => {
  return request({
    url: '/live/courses',
    method: 'get',
    params
  })
}

// 购买课程
export const purchaseCourse = (data) => {
  return request({
    url: '/courses/purchase',
    method: 'post',
    data
  })
}