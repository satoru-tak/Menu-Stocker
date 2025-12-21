# Next.js フロントエンド実装規約

## 1. アーキテクチャ概要

Menu Stocker Frontend は、**Bulletproof React** をベースにした機能ベース（Feature-based）アーキテクチャを採用しています。

### なぜこのアーキテクチャ？

| 理由 | 説明 |
|-----|------|
| **機能の独立性** | レシピ関連コードは全て `features/recipes/` に集約 |
| **チーム開発に最適** | 「この機能はこのフォルダ」が明確 |
| **削除が簡単** | 機能廃止時、フォルダごと削除可能 |
| **Rails との対応** | `features/recipes/` ↔ Backend の `Recipes::` が対応 |

### 技術スタック

| カテゴリ | ライブラリ | なぜ選んだ？ |
|---------|-----------|-------------|
| フレームワーク | Next.js 16 (App Router) | SSR/SSG、ルーティング、最適化が標準装備 |
| UI | React 19 | Server Components、最新機能 |
| スタイリング | Tailwind CSS 4 | ユーティリティファースト、高速開発 |
| データ取得 | TanStack Query | キャッシュ、再検証、ローディング状態の管理 |
| 状態管理 | Zustand | 軽量、シンプル、TypeScript 親和性 |
| フォーム | React Hook Form | パフォーマンス、バリデーション統合 |
| HTTP | Axios | インターセプター、エラーハンドリング |

## 2. ディレクトリ構成

```
src/
├── app/                      # Next.js App Router（ルーティングのみ）
│   ├── (auth)/              # 認証不要ページグループ
│   │   ├── login/
│   │   └── register/
│   ├── (main)/              # 認証必要ページグループ
│   │   ├── recipes/
│   │   │   ├── page.tsx         # 一覧
│   │   │   ├── new/page.tsx     # 新規作成
│   │   │   └── [id]/
│   │   │       ├── page.tsx     # 詳細
│   │   │       └── edit/page.tsx
│   │   ├── menus/
│   │   └── settings/
│   ├── layout.tsx           # ルートレイアウト
│   ├── page.tsx             # トップページ
│   └── globals.css
│
├── components/              # 共通コンポーネント
│   ├── ui/                  # 汎用UIパーツ（なぜ：再利用性）
│   │   ├── Button/
│   │   │   ├── Button.tsx
│   │   │   ├── Button.test.tsx
│   │   │   └── index.ts
│   │   ├── Input/
│   │   ├── Modal/
│   │   ├── Card/
│   │   ├── Loading/
│   │   └── ErrorMessage/
│   │
│   ├── layouts/             # レイアウト部品（なぜ：ページ構造の統一）
│   │   ├── Header/
│   │   ├── Sidebar/
│   │   ├── Footer/
│   │   └── MainLayout/
│   │
│   └── forms/               # フォーム共通部品（なぜ：入力UIの統一）
│       ├── FormField/
│       ├── FormError/
│       └── FormLabel/
│
├── features/                # 機能別モジュール（なぜ：機能の独立性）
│   ├── auth/               # 認証機能
│   │   ├── components/      # 認証専用コンポーネント
│   │   │   ├── LoginForm.tsx
│   │   │   └── RegisterForm.tsx
│   │   ├── hooks/           # 認証専用フック
│   │   │   ├── useAuth.ts
│   │   │   └── useLogin.ts
│   │   ├── api/             # 認証API呼び出し
│   │   │   └── authApi.ts
│   │   ├── stores/          # 認証状態（Zustand）
│   │   │   └── authStore.ts
│   │   ├── types/           # 認証関連型
│   │   │   └── index.ts
│   │   └── index.ts         # 公開API
│   │
│   ├── recipes/            # レシピ機能
│   │   ├── components/
│   │   │   ├── RecipeCard.tsx
│   │   │   ├── RecipeList.tsx
│   │   │   ├── RecipeDetail.tsx
│   │   │   ├── RecipeForm.tsx
│   │   │   └── IngredientList.tsx
│   │   ├── hooks/
│   │   │   ├── useRecipes.ts      # 一覧取得
│   │   │   ├── useRecipe.ts       # 詳細取得
│   │   │   ├── useCreateRecipe.ts # 作成
│   │   │   └── useUpdateRecipe.ts # 更新
│   │   ├── api/
│   │   │   └── recipesApi.ts
│   │   ├── types/
│   │   │   └── index.ts
│   │   └── index.ts
│   │
│   └── menus/              # メニュー機能
│       ├── components/
│       ├── hooks/
│       ├── api/
│       ├── types/
│       └── index.ts
│
├── hooks/                   # 共通カスタムフック（なぜ：ロジックの再利用）
│   ├── useDebounce.ts
│   ├── useLocalStorage.ts
│   └── useMediaQuery.ts
│
├── lib/                     # ユーティリティ（なぜ：純粋関数の集約）
│   ├── api/                 # API基盤
│   │   ├── client.ts        # Axios インスタンス
│   │   ├── endpoints.ts     # エンドポイント定義
│   │   └── types.ts         # API共通型
│   ├── utils/               # ユーティリティ関数
│   │   ├── format.ts        # フォーマッター
│   │   ├── validation.ts    # バリデーション
│   │   └── cn.ts            # Tailwind クラス結合
│   └── constants/           # 定数
│       └── app.ts
│
├── providers/               # Context Providers（なぜ：依存注入）
│   ├── QueryProvider.tsx    # TanStack Query
│   ├── AuthProvider.tsx     # 認証コンテキスト
│   └── index.tsx            # 統合プロバイダー
│
└── types/                   # 共通型定義（なぜ：型の一元管理）
    ├── api.ts               # APIレスポンス型
    ├── models.ts            # ドメインモデル型
    └── index.ts
```

## 3. 各層の責務と実装ルール

### 3.1 app/ （ルーティング層）

**責務**
- ページのルーティング定義
- レイアウトの適用
- メタデータの設定

**ルール**
- ビジネスロジックを書かない
- コンポーネントの組み立てのみ
- データ取得は `features/` の hooks を使用

```tsx
// app/(main)/recipes/page.tsx
// なぜ薄い実装？：ルーティングとUIの関心を分離するため
import { RecipeList } from '@/features/recipes';

export const metadata = {
  title: 'レシピ一覧 | Menu Stocker',
};

export default function RecipesPage() {
  return (
    <div className="container mx-auto py-8">
      <h1 className="text-2xl font-bold mb-6">レシピ一覧</h1>
      <RecipeList />
    </div>
  );
}
```

### 3.2 components/ （共通コンポーネント層）

**責務**
- 再利用可能なUIパーツの提供
- デザインシステムの実装

**ルール**
- ビジネスロジックを含まない
- Props でカスタマイズ可能に
- 1コンポーネント = 1ファイル + index.ts

```tsx
// components/ui/Button/Button.tsx
// なぜ variant パターン？：一貫したUIを保ちつつ柔軟性を確保
import { cn } from '@/lib/utils/cn';
import { ButtonHTMLAttributes, forwardRef } from 'react';

type ButtonVariant = 'primary' | 'secondary' | 'danger' | 'ghost';
type ButtonSize = 'sm' | 'md' | 'lg';

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  size?: ButtonSize;
  isLoading?: boolean;
}

const variantStyles: Record<ButtonVariant, string> = {
  primary: 'bg-blue-600 text-white hover:bg-blue-700',
  secondary: 'bg-gray-200 text-gray-800 hover:bg-gray-300',
  danger: 'bg-red-600 text-white hover:bg-red-700',
  ghost: 'bg-transparent hover:bg-gray-100',
};

const sizeStyles: Record<ButtonSize, string> = {
  sm: 'px-3 py-1.5 text-sm',
  md: 'px-4 py-2 text-base',
  lg: 'px-6 py-3 text-lg',
};

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ variant = 'primary', size = 'md', isLoading, className, children, disabled, ...props }, ref) => {
    return (
      <button
        ref={ref}
        className={cn(
          'rounded-md font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2',
          variantStyles[variant],
          sizeStyles[size],
          isLoading && 'opacity-50 cursor-not-allowed',
          className
        )}
        disabled={disabled || isLoading}
        {...props}
      >
        {isLoading ? (
          <span className="flex items-center gap-2">
            <span className="animate-spin">⏳</span>
            読み込み中...
          </span>
        ) : (
          children
        )}
      </button>
    );
  }
);

Button.displayName = 'Button';
```

```ts
// components/ui/Button/index.ts
export { Button } from './Button';
```

### 3.3 features/ （機能モジュール層）

**責務**
- 特定機能に関するコード全ての格納
- 機能の境界を明確化

**ルール**
- 他の feature を直接参照しない
- 公開APIは `index.ts` で明示
- Backend の namespace と対応させる

#### 3.3.1 feature/components/

```tsx
// features/recipes/components/RecipeCard.tsx
// なぜ feature 内にコンポーネント？：レシピ専用のUIを分離
import { Card } from '@/components/ui/Card';
import { Recipe } from '../types';

interface RecipeCardProps {
  recipe: Recipe;
  onClick?: () => void;
}

export function RecipeCard({ recipe, onClick }: RecipeCardProps) {
  return (
    <Card onClick={onClick} className="cursor-pointer hover:shadow-lg transition-shadow">
      {recipe.imageUrl && (
        <img
          src={recipe.imageUrl}
          alt={recipe.name}
          className="w-full h-48 object-cover rounded-t-lg"
        />
      )}
      <div className="p-4">
        <h3 className="font-bold text-lg">{recipe.name}</h3>
        <p className="text-gray-600 text-sm mt-1 line-clamp-2">
          {recipe.description}
        </p>
        <div className="flex items-center gap-4 mt-3 text-sm text-gray-500">
          <span>🕐 {recipe.cookingTime}分</span>
          <span>👥 {recipe.servingSize}人前</span>
        </div>
      </div>
    </Card>
  );
}
```

#### 3.3.2 feature/hooks/ （TanStack Query）

```tsx
// features/recipes/hooks/useRecipes.ts
// なぜ TanStack Query？：キャッシュ、再検証、ローディング状態を自動管理
import { useQuery } from '@tanstack/react-query';
import { recipesApi } from '../api/recipesApi';
import { RecipesQueryParams } from '../types';

export function useRecipes(params?: RecipesQueryParams) {
  return useQuery({
    // queryKey：キャッシュのキー。params が変わると再取得
    queryKey: ['recipes', params],
    // queryFn：実際のAPI呼び出し
    queryFn: () => recipesApi.getAll(params),
    // staleTime：このデータが「古い」とみなすまでの時間
    staleTime: 1000 * 60 * 5, // 5分
  });
}
```

```tsx
// features/recipes/hooks/useCreateRecipe.ts
// なぜ useMutation？：作成・更新・削除は副作用を伴うため
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { recipesApi } from '../api/recipesApi';
import { CreateRecipeInput } from '../types';

export function useCreateRecipe() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (input: CreateRecipeInput) => recipesApi.create(input),
    // 成功時にキャッシュを更新
    onSuccess: () => {
      // recipes 関連のキャッシュを全て無効化
      queryClient.invalidateQueries({ queryKey: ['recipes'] });
    },
  });
}
```

```tsx
// features/recipes/hooks/useRecipe.ts
import { useQuery } from '@tanstack/react-query';
import { recipesApi } from '../api/recipesApi';

export function useRecipe(id: number) {
  return useQuery({
    queryKey: ['recipes', id],
    queryFn: () => recipesApi.getById(id),
    // id が無い場合は実行しない
    enabled: !!id,
  });
}
```

#### 3.3.3 feature/api/

```tsx
// features/recipes/api/recipesApi.ts
// なぜ API を分離？：HTTP通信の詳細を隠蔽し、テストしやすくする
import { apiClient } from '@/lib/api/client';
import { ApiResponse, PaginatedResponse } from '@/lib/api/types';
import { Recipe, CreateRecipeInput, UpdateRecipeInput, RecipesQueryParams } from '../types';

const ENDPOINT = '/api/v1/recipes';

export const recipesApi = {
  // 一覧取得
  getAll: async (params?: RecipesQueryParams): Promise<PaginatedResponse<Recipe>> => {
    const { data } = await apiClient.get<PaginatedResponse<Recipe>>(ENDPOINT, { params });
    return data;
  },

  // 詳細取得
  getById: async (id: number): Promise<ApiResponse<Recipe>> => {
    const { data } = await apiClient.get<ApiResponse<Recipe>>(`${ENDPOINT}/${id}`);
    return data;
  },

  // 作成
  create: async (input: CreateRecipeInput): Promise<ApiResponse<Recipe>> => {
    const { data } = await apiClient.post<ApiResponse<Recipe>>(ENDPOINT, { recipe: input });
    return data;
  },

  // 更新
  update: async (id: number, input: UpdateRecipeInput): Promise<ApiResponse<Recipe>> => {
    const { data } = await apiClient.patch<ApiResponse<Recipe>>(`${ENDPOINT}/${id}`, { recipe: input });
    return data;
  },

  // 削除
  delete: async (id: number): Promise<void> => {
    await apiClient.delete(`${ENDPOINT}/${id}`);
  },
};
```

#### 3.3.4 feature/types/

```tsx
// features/recipes/types/index.ts
// なぜ型を分離？：TypeScript の型安全性を最大限活用

// ドメインモデル（Backend のレスポンスと対応）
export interface Recipe {
  id: number;
  name: string;
  description: string | null;
  cookingTime: number | null;
  difficulty: 1 | 2 | 3;
  servingSize: number;
  isFavorite: boolean;
  imageUrl: string | null;
  ingredients: Ingredient[];
  steps: Step[];
  createdAt: string;
  updatedAt: string;
}

export interface Ingredient {
  id: number;
  name: string;
  quantity: string | null;
  unit: string | null;
  optional: boolean;
  position: number;
}

export interface Step {
  id: number;
  position: number;
  description: string;
}

// API入力型（Backend の Form と対応）
export interface CreateRecipeInput {
  name: string;
  description?: string;
  cookingTime?: number;
  difficulty?: 1 | 2 | 3;
  servingSize?: number;
  ingredientsAttributes?: CreateIngredientInput[];
  stepsAttributes?: CreateStepInput[];
}

export interface UpdateRecipeInput extends Partial<CreateRecipeInput> {}

export interface CreateIngredientInput {
  name: string;
  quantity?: string;
  unit?: string;
  optional?: boolean;
  position?: number;
}

export interface CreateStepInput {
  position: number;
  description: string;
}

// クエリパラメータ
export interface RecipesQueryParams {
  q?: string;
  isFavorite?: boolean;
  difficulty?: number;
  page?: number;
  perPage?: number;
}
```

#### 3.3.5 feature/index.ts（公開API）

```tsx
// features/recipes/index.ts
// なぜ index.ts？：外部に公開するものを明示し、内部実装を隠蔽

// Components
export { RecipeCard } from './components/RecipeCard';
export { RecipeList } from './components/RecipeList';
export { RecipeDetail } from './components/RecipeDetail';
export { RecipeForm } from './components/RecipeForm';

// Hooks
export { useRecipes } from './hooks/useRecipes';
export { useRecipe } from './hooks/useRecipe';
export { useCreateRecipe } from './hooks/useCreateRecipe';
export { useUpdateRecipe } from './hooks/useUpdateRecipe';
export { useDeleteRecipe } from './hooks/useDeleteRecipe';

// Types
export type {
  Recipe,
  Ingredient,
  Step,
  CreateRecipeInput,
  UpdateRecipeInput,
  RecipesQueryParams,
} from './types';
```

### 3.4 stores/ （Zustand 状態管理）

**責務**
- グローバル状態の管理
- 認証状態、UI状態など

**ルール**
- サーバーデータは TanStack Query で管理
- Zustand は UI 状態・認証状態のみ

```tsx
// features/auth/stores/authStore.ts
// なぜ Zustand？：軽量でシンプル、ボイラープレートが少ない
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface User {
  id: number;
  email: string;
  name: string;
}

interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  setAuth: (user: User, token: string) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>()(
  // persist：localStorage に保存して永続化
  persist(
    (set) => ({
      user: null,
      token: null,
      isAuthenticated: false,

      setAuth: (user, token) =>
        set({
          user,
          token,
          isAuthenticated: true,
        }),

      logout: () =>
        set({
          user: null,
          token: null,
          isAuthenticated: false,
        }),
    }),
    {
      name: 'auth-storage',
      // token のみ永続化（セキュリティ考慮）
      partialize: (state) => ({ token: state.token }),
    }
  )
);
```

### 3.5 lib/ （ユーティリティ層）

#### API クライアント

```tsx
// lib/api/client.ts
// なぜ Axios インスタンス？：共通設定、インターセプターを一元管理
import axios from 'axios';
import { useAuthStore } from '@/features/auth/stores/authStore';

export const apiClient = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000',
  headers: {
    'Content-Type': 'application/json',
  },
});

// リクエストインターセプター：認証トークンを自動付与
apiClient.interceptors.request.use((config) => {
  const token = useAuthStore.getState().token;
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// レスポンスインターセプター：エラーハンドリング
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // 認証エラー時はログアウト
      useAuthStore.getState().logout();
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);
```

```tsx
// lib/api/types.ts
// API レスポンスの共通型（Backend と対応）
export interface ApiResponse<T> {
  data: T;
}

export interface PaginatedResponse<T> {
  data: T[];
  meta: {
    currentPage: number;
    totalPages: number;
    totalCount: number;
    perPage: number;
  };
}

export interface ApiError {
  error: {
    type: string;
    message: string;
    details?: Record<string, string[]>;
  };
}
```

#### ユーティリティ関数

```tsx
// lib/utils/cn.ts
// なぜ cn？：Tailwind のクラス名を条件付きで結合
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

```tsx
// lib/utils/format.ts
export function formatDate(date: string | Date): string {
  return new Intl.DateTimeFormat('ja-JP', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  }).format(new Date(date));
}

export function formatCookingTime(minutes: number): string {
  if (minutes < 60) {
    return `${minutes}分`;
  }
  const hours = Math.floor(minutes / 60);
  const mins = minutes % 60;
  return mins > 0 ? `${hours}時間${mins}分` : `${hours}時間`;
}
```

### 3.6 providers/ （プロバイダー層）

```tsx
// providers/QueryProvider.tsx
'use client';

import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';
import { useState } from 'react';

export function QueryProvider({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            // エラー時のリトライ回数
            retry: 1,
            // ウィンドウフォーカス時の再取得を無効化
            refetchOnWindowFocus: false,
          },
        },
      })
  );

  return (
    <QueryClientProvider client={queryClient}>
      {children}
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  );
}
```

```tsx
// providers/index.tsx
'use client';

import { QueryProvider } from './QueryProvider';
import { AuthProvider } from './AuthProvider';

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <QueryProvider>
      <AuthProvider>{children}</AuthProvider>
    </QueryProvider>
  );
}
```

## 4. フォーム実装パターン（React Hook Form）

```tsx
// features/recipes/components/RecipeForm.tsx
// なぜ React Hook Form？：パフォーマンス、バリデーション、型安全性
'use client';

import { useForm } from 'react-hook-form';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { FormField } from '@/components/forms/FormField';
import { CreateRecipeInput } from '../types';
import { useCreateRecipe } from '../hooks/useCreateRecipe';

interface RecipeFormProps {
  onSuccess?: () => void;
}

export function RecipeForm({ onSuccess }: RecipeFormProps) {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<CreateRecipeInput>({
    defaultValues: {
      name: '',
      description: '',
      cookingTime: undefined,
      difficulty: 1,
      servingSize: 2,
    },
  });

  const createRecipe = useCreateRecipe();

  const onSubmit = async (data: CreateRecipeInput) => {
    try {
      await createRecipe.mutateAsync(data);
      onSuccess?.();
    } catch (error) {
      // エラーハンドリング
      console.error('Failed to create recipe:', error);
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
      <FormField label="レシピ名" error={errors.name?.message} required>
        <Input
          {...register('name', {
            required: 'レシピ名を入力してください',
            maxLength: { value: 100, message: '100文字以内で入力してください' },
          })}
          placeholder="例: カレーライス"
        />
      </FormField>

      <FormField label="説明" error={errors.description?.message}>
        <textarea
          {...register('description')}
          className="w-full rounded-md border border-gray-300 p-2"
          rows={3}
          placeholder="レシピの説明を入力"
        />
      </FormField>

      <div className="grid grid-cols-2 gap-4">
        <FormField label="調理時間（分）" error={errors.cookingTime?.message}>
          <Input
            type="number"
            {...register('cookingTime', {
              valueAsNumber: true,
              min: { value: 1, message: '1以上で入力してください' },
            })}
          />
        </FormField>

        <FormField label="人数" error={errors.servingSize?.message}>
          <Input
            type="number"
            {...register('servingSize', {
              valueAsNumber: true,
              min: { value: 1, message: '1以上で入力してください' },
            })}
          />
        </FormField>
      </div>

      <Button type="submit" isLoading={isSubmitting}>
        レシピを作成
      </Button>
    </form>
  );
}
```

## 5. 命名規則

### ファイル名

| 種類 | 命名規則 | 例 |
|------|---------|-----|
| コンポーネント | PascalCase | `RecipeCard.tsx` |
| フック | camelCase (use 接頭辞) | `useRecipes.ts` |
| API | camelCase (xxxApi 接尾辞) | `recipesApi.ts` |
| ストア | camelCase (xxxStore 接尾辞) | `authStore.ts` |
| 型定義 | PascalCase | `types/index.ts` |
| ユーティリティ | camelCase | `format.ts` |

### 変数・関数名

```tsx
// コンポーネント: PascalCase
export function RecipeCard() {}

// フック: use 接頭辞 + PascalCase
export function useRecipes() {}
export function useCreateRecipe() {}

// イベントハンドラ: handle 接頭辞
const handleSubmit = () => {};
const handleClick = () => {};

// boolean: is/has/can 接頭辞
const isLoading = true;
const hasError = false;
const canEdit = true;

// API関数: 動詞で始める
recipesApi.getAll();
recipesApi.create();
recipesApi.update();
recipesApi.delete();
```

### Props の命名

```tsx
// イベント: on 接頭辞
interface ButtonProps {
  onClick?: () => void;
  onSubmit?: (data: FormData) => void;
}

// レンダープロップ: render 接頭辞
interface ListProps<T> {
  items: T[];
  renderItem: (item: T) => React.ReactNode;
}

// boolean: is/has 接頭辞（省略可能）
interface ModalProps {
  isOpen: boolean;      // 状態を表す
  disabled?: boolean;   // HTML 属性と対応する場合は省略可
}
```

## 6. テスト規約

### ディレクトリ構成

```
__tests__/                   # または各ファイルの隣に .test.tsx
├── components/
│   └── ui/
│       └── Button.test.tsx
├── features/
│   └── recipes/
│       ├── components/
│       │   └── RecipeCard.test.tsx
│       └── hooks/
│           └── useRecipes.test.tsx
└── lib/
    └── utils/
        └── format.test.ts
```

### テスト例

```tsx
// features/recipes/components/RecipeCard.test.tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { RecipeCard } from './RecipeCard';

const mockRecipe = {
  id: 1,
  name: 'カレーライス',
  description: 'スパイシーなカレー',
  cookingTime: 60,
  servingSize: 4,
  difficulty: 2,
  isFavorite: false,
  imageUrl: null,
  ingredients: [],
  steps: [],
  createdAt: '2024-01-01T00:00:00Z',
  updatedAt: '2024-01-01T00:00:00Z',
};

describe('RecipeCard', () => {
  it('レシピ名を表示する', () => {
    render(<RecipeCard recipe={mockRecipe} />);
    expect(screen.getByText('カレーライス')).toBeInTheDocument();
  });

  it('クリック時にコールバックを実行する', async () => {
    const handleClick = vi.fn();
    render(<RecipeCard recipe={mockRecipe} onClick={handleClick} />);

    await userEvent.click(screen.getByRole('article'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
});
```

## 7. import ルール

```tsx
// 1. React/Next.js
import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';

// 2. 外部ライブラリ
import { useQuery } from '@tanstack/react-query';
import { useForm } from 'react-hook-form';

// 3. 内部: components（共通）
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';

// 4. 内部: features（他の feature は避ける）
import { useAuth } from '@/features/auth';

// 5. 内部: lib
import { apiClient } from '@/lib/api/client';
import { formatDate } from '@/lib/utils/format';

// 6. 内部: types
import type { Recipe } from '../types';

// 7. スタイル（必要な場合）
import styles from './Component.module.css';
```

## 8. Backend との対応関係

| Frontend | Backend | 説明 |
|----------|---------|------|
| `features/recipes/` | `Recipes::` (namespace) | 機能の対応 |
| `useCreateRecipe` | `Recipes::CreateService` | 作成処理 |
| `recipesApi.ts` | `Api::V1::RecipesController` | API通信 |
| `CreateRecipeInput` | `Recipes::CreateForm` | 入力バリデーション |
| `Recipe` (型) | `RecipeResource` | レスポンス構造 |

---

**更新日**: 2025-12-22
**バージョン**: 1.0
