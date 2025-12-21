'use client';

import { QueryProvider } from './QueryProvider';

interface ProvidersProps {
  children: React.ReactNode;
}

/**
 * アプリケーション全体のプロバイダーを統合
 * 新しいプロバイダーを追加する場合はここにネスト
 */
export function Providers({ children }: ProvidersProps) {
  return <QueryProvider>{children}</QueryProvider>;
}
