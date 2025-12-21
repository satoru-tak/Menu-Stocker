'use client';

import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';
import { useState } from 'react';

interface QueryProviderProps {
  children: React.ReactNode;
}

/**
 * TanStack Query のプロバイダー
 * データ取得のキャッシュと状態管理を提供
 */
export function QueryProvider({ children }: QueryProviderProps) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            // エラー時のリトライ回数
            retry: 1,
            // データが古いとみなすまでの時間（5分）
            staleTime: 1000 * 60 * 5,
            // ウィンドウフォーカス時の再取得を無効化
            refetchOnWindowFocus: false,
          },
          mutations: {
            // ミューテーションはリトライしない
            retry: false,
          },
        },
      })
  );

  return (
    <QueryClientProvider client={queryClient}>
      {children}
      {process.env.NODE_ENV === 'development' && (
        <ReactQueryDevtools initialIsOpen={false} />
      )}
    </QueryClientProvider>
  );
}
