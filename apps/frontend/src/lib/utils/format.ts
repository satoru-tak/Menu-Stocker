/**
 * 日付をフォーマット
 * @example formatDate('2024-01-01') // '2024年1月1日'
 */
export function formatDate(date: string | Date): string {
  return new Intl.DateTimeFormat('ja-JP', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  }).format(new Date(date));
}

/**
 * 日時をフォーマット
 * @example formatDateTime('2024-01-01T12:00:00') // '2024年1月1日 12:00'
 */
export function formatDateTime(date: string | Date): string {
  return new Intl.DateTimeFormat('ja-JP', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  }).format(new Date(date));
}

/**
 * 調理時間をフォーマット
 * @example formatCookingTime(90) // '1時間30分'
 */
export function formatCookingTime(minutes: number): string {
  if (minutes < 60) {
    return `${minutes}分`;
  }
  const hours = Math.floor(minutes / 60);
  const mins = minutes % 60;
  return mins > 0 ? `${hours}時間${mins}分` : `${hours}時間`;
}

/**
 * 数値をカンマ区切りでフォーマット
 * @example formatNumber(1000) // '1,000'
 */
export function formatNumber(value: number): string {
  return new Intl.NumberFormat('ja-JP').format(value);
}
