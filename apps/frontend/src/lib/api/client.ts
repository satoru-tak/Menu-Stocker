import axios from 'axios';

/**
 * API クライアント（Axios インスタンス）
 * 共通設定とインターセプターを一元管理
 */
export const apiClient = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000',
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 10000, // 10秒
});

// リクエストインターセプター
apiClient.interceptors.request.use(
  (config) => {
    // 認証トークンの付与は authStore 設定後に追加
    // const token = useAuthStore.getState().token;
    // if (token) {
    //   config.headers.Authorization = `Bearer ${token}`;
    // }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// レスポンスインターセプター
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    // 401 Unauthorized の場合はログアウト処理
    // if (error.response?.status === 401) {
    //   useAuthStore.getState().logout();
    //   window.location.href = '/login';
    // }

    // エラーログ（開発時のみ）
    if (process.env.NODE_ENV === 'development') {
      console.error('API Error:', error.response?.data || error.message);
    }

    return Promise.reject(error);
  }
);
