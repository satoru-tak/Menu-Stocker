/**
 * API レスポンスの共通型
 * Backend の JSON レスポンス形式と対応
 */

// 単一リソースのレスポンス
export interface ApiResponse<T> {
  data: T;
}

// ページネーション付きレスポンス
export interface PaginatedResponse<T> {
  data: T[];
  meta: PaginationMeta;
}

// ページネーションメタ情報
export interface PaginationMeta {
  currentPage: number;
  totalPages: number;
  totalCount: number;
  perPage: number;
}

// エラーレスポンス
export interface ApiError {
  error: {
    type: string;
    message: string;
    details?: Record<string, string[]>;
  };
}

// API エラーかどうかを判定
export function isApiError(error: unknown): error is { response: { data: ApiError } } {
  return (
    typeof error === 'object' &&
    error !== null &&
    'response' in error &&
    typeof (error as { response: unknown }).response === 'object' &&
    (error as { response: { data: unknown } }).response !== null &&
    'data' in (error as { response: { data: unknown } }).response
  );
}
