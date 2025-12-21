/**
 * アプリケーション共通の型定義
 */

// ページネーション
export interface PaginationParams {
  page?: number;
  perPage?: number;
}

// ソート
export interface SortParams {
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

// 検索
export interface SearchParams {
  q?: string;
}

// 共通のクエリパラメータ
export interface QueryParams extends PaginationParams, SortParams, SearchParams {}
