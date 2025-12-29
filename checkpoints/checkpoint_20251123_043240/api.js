import axios from 'axios';

// Use relative URL in production, absolute URL in development
const API_BASE_URL = process.env.REACT_APP_API_URL || 
  (process.env.NODE_ENV === 'production' ? '/api' : 'http://localhost:5000/api');

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add token to requests if available
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('adminToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Public API calls
export const publicAPI = {
  // Get all pages
  getPages: () => api.get('/pages'),
  
  // Get page by slug
  getPageBySlug: (slug) => api.get(`/pages/${slug}`),
  
  // Get navigation links
  getNavigationLinks: () => api.get('/navigation'),
  
  // Get site settings
  getSiteSettings: () => api.get('/settings'),

  // Get slider images
  getSliderImages: () => api.get('/slider'),
  
  // Get footer settings
  getFooterSettings: () => api.get('/footer'),
  
  // Get our work entries
  getOurWork: () => api.get('/our-work'),
  
  // Get gallery images
  getGalleryImages: (category = 'all') => api.get(`/gallery${category !== 'all' ? `?category=${category}` : ''}`),
  getGalleryCategories: () => api.get('/gallery/categories/list'),
  
  // Get blogs
  getBlogs: () => api.get('/blogs'),
  getBlogBySlug: (slug) => api.get(`/blogs/${slug}`),
  
  // Send contact message
  sendContactMessage: (messageData) => api.post('/contact', messageData),
  
  // Check if email exists
  checkEmailExists: (email) => api.post('/donations/check-email', { email }),
  
  // Update user details
  updateUserDetails: (userData) => api.post('/donations/update-user', userData),
  
  // Create Razorpay subscription
  createRazorpaySubscription: (subscriptionData) => api.post('/donations/razorpay/create-subscription', subscriptionData),
  
  // Create Cashfree order (legacy)
  createCashfreeOrder: (orderData) => api.post('/donations/cf/order', orderData),
  
  // Verify Cashfree payment (legacy)
  verifyCashfree: (data) => api.post('/donations/cf/verify', data),
};

// Admin API calls
export const adminAPI = {
  // Auth
  login: (credentials) => api.post('/admin/login', credentials),
  verifyToken: () => api.get('/admin/verify'),
  
  // Pages management
  getAllPages: () => api.get('/admin/pages'),
  createPage: (pageData) => api.post('/pages', pageData),
  updatePage: (id, pageData) => api.put(`/pages/${id}`, pageData),
  deletePage: (id) => api.delete(`/pages/${id}`),
  getPagesDropdown: () => api.get('/admin/pages/dropdown'),
  
  // Navigation management
  getAllNavigationLinks: () => api.get('/admin/navigation'),
  createNavigationLink: (linkData) => api.post('/navigation', linkData),
  updateNavigationLink: (id, linkData) => api.put(`/navigation/${id}`, linkData),
  deleteNavigationLink: (id) => api.delete(`/navigation/${id}`),
  updateSortOrder: (links) => api.put('/navigation/sort/update', { links }),
  
  // Site settings management
  getAllSiteSettings: () => api.get('/settings/admin'),
  updateSiteSetting: (key, value) => api.put(`/settings/${key}`, { value }),
  createSiteSetting: (settingData) => api.post('/settings', settingData),
  deleteSiteSetting: (key) => api.delete(`/settings/${key}`),
  uploadLogo: (formData) => api.post('/settings/upload-logo', formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  }),

  // Slider management
  getAllSliderImages: () => api.get('/slider/admin'),
  getSliderImage: (id) => api.get(`/slider/${id}`),
  createSliderImage: (formData) => api.post('/slider', formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  }),
  updateSliderImage: (id, formData) => api.put(`/slider/${id}`, formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  }),
  deleteSliderImage: (id) => api.delete(`/slider/${id}`),
  updateSliderSortOrder: (images) => api.put('/slider/sort/update', { images }),

  // Footer management
  getAllFooterSettings: () => api.get('/footer/admin'),
  getFooterSetting: (key) => api.get(`/footer/${key}`),
  createFooterSetting: (settingData) => api.post('/footer', settingData),
  updateFooterSetting: (key, settingData) => api.put(`/footer/${key}`, settingData),
  deleteFooterSetting: (key) => api.delete(`/footer/${key}`),
  bulkUpdateFooterSettings: (settings) => api.put('/footer/bulk/update', { settings }),

  // Our Work management
  getAllOurWork: () => api.get('/our-work/admin'),
  getOurWorkEntry: (id) => api.get(`/our-work/${id}`),
  createOurWorkEntry: (formData) => api.post('/our-work', formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  }),
  updateOurWorkEntry: (id, formData) => api.put(`/our-work/${id}`, formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  }),
  deleteOurWorkEntry: (id) => api.delete(`/our-work/${id}`),
  updateOurWorkSortOrder: (entries) => api.put('/our-work/sort/update', { entries }),

  // Gallery management
  getAllGalleryImages: () => api.get('/gallery/admin'),
  getGalleryImage: (id) => api.get(`/gallery/${id}`),
  createGalleryImage: (formData) => api.post('/gallery', formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  }),
  updateGalleryImage: (id, formData) => api.put(`/gallery/${id}`, formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  }),
  deleteGalleryImage: (id) => api.delete(`/gallery/${id}`),
  updateGallerySortOrder: (images) => api.put('/gallery/sort/update', { images }),

  // Blog management
  getAllBlogs: () => api.get('/blogs/admin/all'),
  getBlog: (id) => api.get(`/blogs/admin/${id}`),
  createBlog: (formData) => api.post('/blogs', formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  }),
  updateBlog: (id, formData) => api.put(`/blogs/${id}`, formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  }),
  deleteBlog: (id) => api.delete(`/blogs/${id}`),
  
  // Contact messages management
  listContactMessages: () => api.get('/contact/admin'),
  deleteContactMessage: (id) => api.delete(`/contact/admin/${id}`),
  exportContactCsv: () => api.get('/contact/admin/export', {
    responseType: 'blob'
  }),
  
  // Donations management
  getAllDonations: () => api.get('/donations/admin'),
  getPaymentTransactions: (donationId) => api.get(`/donations/admin/transactions/${donationId}`),
  getAllPaymentTransactions: () => api.get('/donations/admin/transactions'),
};

export default api;
