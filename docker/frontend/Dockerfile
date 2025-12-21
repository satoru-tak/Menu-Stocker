# Frontend (Next.js) Dockerfile

# ベースステージ
FROM node:20-alpine AS base

# 作業ディレクトリの設定
WORKDIR /app

# 開発ステージ
FROM base AS development

# 依存関係のインストール
COPY package.json package-lock.json* ./
RUN npm ci

# アプリケーションのコピー
COPY . .

# ポートの公開
EXPOSE 3000

# 開発サーバーの起動
CMD ["npm", "run", "dev"]

# 依存関係ステージ
FROM base AS deps

# 依存関係のインストール
COPY package.json package-lock.json* ./
RUN npm ci

# ビルドステージ
FROM base AS builder

# 依存関係をコピー
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# 環境変数の設定（ビルド時）
ENV NEXT_TELEMETRY_DISABLED 1
ENV NODE_ENV production

# Next.js のビルド
RUN npm run build

# 本番ステージ
FROM base AS production

# 環境変数の設定
ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

# 非rootユーザーの作成
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# ビルド成果物をコピー
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

# ポートの公開
EXPOSE 3000

# 環境変数の設定（実行時）
ENV PORT 3000
ENV HOSTNAME "0.0.0.0"

# ヘルスチェック
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/api/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# 起動コマンド
CMD ["node", "server.js"]
