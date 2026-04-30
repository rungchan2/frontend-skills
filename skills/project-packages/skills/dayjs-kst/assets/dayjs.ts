import dayjs from "dayjs"
import utc from "dayjs/plugin/utc"
import timezone from "dayjs/plugin/timezone"
import "dayjs/locale/ko"

// 모든 컴포넌트/서버 코드는 이 파일에서 dayjs를 import 해야 한다.
// 직접 `import dayjs from "dayjs"` 하면 plugin/locale이 적용되지 않은 인스턴스가 생긴다.

dayjs.extend(utc)
dayjs.extend(timezone)
dayjs.locale("ko")
dayjs.tz.setDefault("Asia/Seoul")

/**
 * YYYY-MM-DD 같은 date-only 문자열을 timezone shift 없이 파싱.
 * 로컬 타임존이 KST가 아닌 환경(서버 등)에서도 같은 날짜를 보장.
 */
export const parseDateOnly = (dateString: string | null | undefined) => {
  if (!dateString) return null
  return dayjs.utc(dateString)
}

export const formatDateOnly = (
  date: Date | dayjs.Dayjs | null | undefined,
): string | null => {
  if (!date) return null
  return dayjs(date).format("YYYY-MM-DD")
}

/** created_at, updated_at 등 ISO timestamp 파싱. */
export const parseTimestamp = (timestamp: string | null | undefined) => {
  if (!timestamp) return null
  return dayjs(timestamp)
}

/**
 * Date + "HH:mm" 시간 문자열을 합쳐 KST 기준 ISO 문자열로 반환.
 * time 미지정 시 자정(00:00).
 */
export const formatDateTime = (
  date: Date | dayjs.Dayjs,
  time?: string,
): string => {
  const d = dayjs.tz(dayjs(date))
  if (time) {
    const [hours, minutes] = time.split(":")
    return d
      .hour(parseInt(hours) || 0)
      .minute(parseInt(minutes) || 0)
      .second(0)
      .format()
  }
  return d.hour(0).minute(0).second(0).format()
}

/** "HH:mm" 형태로 시각만 추출. */
export const extractTime = (
  date: Date | dayjs.Dayjs | string | null | undefined,
): string => {
  if (!date) return ""
  return dayjs(date).format("HH:mm")
}

export default dayjs
